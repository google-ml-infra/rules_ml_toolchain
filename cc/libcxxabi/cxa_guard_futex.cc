// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ==============================================================================
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// Futex-based C++ ABI one-time construction (__cxa_guard_acquire,
// __cxa_guard_release, __cxa_guard_abort) matching LLVM libcxxabi's
// InitByteFutex (_LIBCXXABI_USE_FUTEX in libcxxabi/src/cxa_guard_impl.h).
//
// Guard Object Layout (Itanium 64-bit ABI):
// ---------------------------------------------------------------------------
// | a+0: guard byte | a+1: init byte | a+2: unused ... | a+4: thread-id ... |
// ---------------------------------------------------------------------------
//
// Unlike InitByteGlobalMutex, InitByteFutex stores all synchronization state in
// the guard variable itself and waits/wakes via the kernel futex syscall keyed
// on the guard object's address. Because it has zero per-DSO static mutex or
// condition variable state, hidden per-DSO copies of __cxa_guard_acquire
// (created via -Wl,--exclude-libs,libc++abi.a) are completely safe across
// shared libraries.

using uint8_t = __UINT8_TYPE__;
using uint32_t = __UINT32_TYPE__;
using uint64_t = __UINT64_TYPE__;

#if defined(__x86_64__)
constexpr long kSysFutex = 202;
constexpr long kSysGettid = 186;
#elif defined(__aarch64__)
constexpr long kSysFutex = 98;
constexpr long kSysGettid = 178;
#else
#error "Unsupported Linux architecture for InitByteFutex"
#endif

extern "C" long syscall(long number, ...) noexcept;
extern "C" long write(int fd, const void* buf, __SIZE_TYPE__ count) noexcept;

#if __has_feature(thread_sanitizer)
extern "C" void __tsan_acquire(void*);
extern "C" void __tsan_release(void*);
#else
#define __tsan_acquire(addr) ((void)0)
#define __tsan_release(addr) ((void)0)
#endif

namespace __cxxabiv1 {
namespace {

[[noreturn]] __attribute__((__cold__)) void AbortWithMessage(const char* msg, __SIZE_TYPE__ len) noexcept {
  static constexpr char kPrefix[] = "libc++abi: ";
  static constexpr char kSuffix[] = "\n";
  (void)write(2, kPrefix, sizeof(kPrefix) - 1);
  (void)write(2, msg, len);
  (void)write(2, kSuffix, sizeof(kSuffix) - 1);
  __builtin_abort();
}

#define ABORT_WITH_MESSAGE(msg) AbortWithMessage(msg, sizeof(msg) - 1)

template <class T, T (*Init)()>
struct LazyValue {
  LazyValue() : is_init(false) {}

  T& get() {
    if (!is_init) {
      value = Init();
      is_init = true;
    }
    return value;
  }

 private:
  T value;
  bool is_init = false;
};

template <class IntType>
class AtomicInt {
 public:
  explicit AtomicInt(IntType* b) : b_(b) {}
  AtomicInt(AtomicInt const&) = delete;
  AtomicInt& operator=(AtomicInt const&) = delete;

  IntType load(int ord) { return __atomic_load_n(b_, ord); }
  void store(IntType val, int ord) { __atomic_store_n(b_, val, ord); }
  IntType exchange(IntType new_val, int ord) { return __atomic_exchange_n(b_, new_val, ord); }
  bool compare_exchange(IntType* expected, IntType desired, int ord_success, int ord_failure) {
    return __atomic_compare_exchange_n(b_, expected, desired, false, ord_success, ord_failure);
  }

 private:
  IntType* b_;
};

uint32_t PlatformThreadID() {
  return static_cast<uint32_t>(syscall(kSysGettid));
}

static constexpr uint8_t UNSET = 0;
static constexpr uint8_t COMPLETE_BIT = (1 << 0);
static constexpr uint8_t PENDING_BIT = (1 << 1);
static constexpr uint8_t WAITING_BIT = (1 << 2);

struct GuardByte {
  GuardByte() = delete;
  GuardByte(GuardByte const&) = delete;
  GuardByte& operator=(GuardByte const&) = delete;

  explicit GuardByte(uint8_t* const guard_byte_address) : guard_byte(guard_byte_address) {}

  bool acquire() { return guard_byte.load(__ATOMIC_ACQUIRE) != UNSET; }
  void release() { guard_byte.store(COMPLETE_BIT, __ATOMIC_RELEASE); }
  void abort() {}

 private:
  AtomicInt<uint8_t> guard_byte;
};

void PlatformFutexWait(int* addr, int expect) {
  constexpr int WAIT = 0;
  syscall(kSysFutex, addr, WAIT, expect, 0);
  __tsan_acquire(addr);
}

void PlatformFutexWake(int* addr) {
  constexpr int WAKE = 1;
  __tsan_release(addr);
  syscall(kSysFutex, addr, WAKE, __INT_MAX__);
}

template <void (*Wait)(int*, int) = PlatformFutexWait, void (*Wake)(int*) = PlatformFutexWake,
          uint32_t (*GetThreadIDArg)() = PlatformThreadID>
struct InitByteFutex {
  explicit InitByteFutex(uint8_t* _init_byte_address, uint32_t* _thread_id_address)
      : init_byte(_init_byte_address),
        has_thread_id_support(_thread_id_address != nullptr && GetThreadIDArg != nullptr),
        thread_id(_thread_id_address),
        base_address(reinterpret_cast<int*>(_init_byte_address - 1)) {}

  bool acquire() {
    while (true) {
      uint8_t last_val = UNSET;
      if (init_byte.compare_exchange(&last_val, PENDING_BIT, __ATOMIC_ACQ_REL, __ATOMIC_ACQUIRE)) {
        if (has_thread_id_support) {
          thread_id.store(current_thread_id.get(), __ATOMIC_RELAXED);
        }
        return false;
      }

      if (last_val == COMPLETE_BIT)
        return true;

      if (last_val & PENDING_BIT) {
        if (has_thread_id_support && thread_id.load(__ATOMIC_RELAXED) == current_thread_id.get()) {
          ABORT_WITH_MESSAGE(
              "__cxa_guard_acquire detected recursive initialization: do you have a function-local static variable "
              "whose initialization depends on that function?");
        }

        if ((last_val & WAITING_BIT) == 0) {
          if (!init_byte.compare_exchange(&last_val, PENDING_BIT | WAITING_BIT, __ATOMIC_ACQ_REL, __ATOMIC_RELEASE)) {
            if (last_val == COMPLETE_BIT)
              return true;
            if (last_val == UNSET)
              continue;
          }
        }
        wait_on_initialization();
      }
    }
  }

  void release() {
    uint8_t old = init_byte.exchange(COMPLETE_BIT, __ATOMIC_ACQ_REL);
    if (old & WAITING_BIT)
      wake_all();
  }

  void abort() {
    if (has_thread_id_support)
      thread_id.store(0, __ATOMIC_RELAXED);

    uint8_t old = init_byte.exchange(UNSET, __ATOMIC_ACQ_REL);
    if (old & WAITING_BIT)
      wake_all();
  }

 private:
  void wait_on_initialization() { Wait(base_address, expected_value_for_futex(PENDING_BIT | WAITING_BIT)); }
  void wake_all() { Wake(base_address); }

  AtomicInt<uint8_t> init_byte;
  const bool has_thread_id_support;
  AtomicInt<uint32_t> thread_id;
  LazyValue<uint32_t, GetThreadIDArg> current_thread_id;
  int* const base_address;

  static int expected_value_for_futex(uint8_t b) {
    int dest_val = 0;
    __builtin_memcpy(reinterpret_cast<char*>(&dest_val) + 1, &b, 1);
    return dest_val;
  }
};

enum class AcquireResult {
  INIT_IS_DONE,
  INIT_IS_PENDING,
};
constexpr AcquireResult INIT_IS_DONE = AcquireResult::INIT_IS_DONE;
constexpr AcquireResult INIT_IS_PENDING = AcquireResult::INIT_IS_PENDING;

template <class InitByteT>
struct GuardObject {
  GuardObject() = delete;
  GuardObject(GuardObject const&) = delete;
  GuardObject& operator=(GuardObject const&) = delete;

 private:
  GuardByte guard_byte;
  InitByteT init_byte;

 public:
  explicit GuardObject(uint32_t* raw_guard_object)
      : guard_byte(reinterpret_cast<uint8_t*>(raw_guard_object)),
        init_byte(reinterpret_cast<uint8_t*>(raw_guard_object) + 1, nullptr) {}

  explicit GuardObject(uint64_t* raw_guard_object)
      : guard_byte(reinterpret_cast<uint8_t*>(raw_guard_object)),
        init_byte(reinterpret_cast<uint8_t*>(raw_guard_object) + 1,
                  reinterpret_cast<uint32_t*>(raw_guard_object) + 1) {}

  AcquireResult cxa_guard_acquire() {
    if (guard_byte.acquire() || init_byte.acquire())
      return INIT_IS_DONE;
    return INIT_IS_PENDING;
  }

  void cxa_guard_release() {
    guard_byte.release();
    init_byte.release();
  }

  void cxa_guard_abort() {
    guard_byte.abort();
    init_byte.abort();
  }
};

using SelectedImplementation = GuardObject<InitByteFutex<PlatformFutexWait, PlatformFutexWake, PlatformThreadID>>;

}  // namespace

using guard_type = uint64_t;

extern "C" {

__attribute__((__visibility__("default"), __cold__)) int __cxa_guard_acquire(guard_type* raw_guard_object) {
  SelectedImplementation imp(raw_guard_object);
  return static_cast<int>(imp.cxa_guard_acquire());
}

__attribute__((__visibility__("default"), __cold__)) void __cxa_guard_release(guard_type* raw_guard_object) {
  SelectedImplementation imp(raw_guard_object);
  imp.cxa_guard_release();
}

__attribute__((__visibility__("default"), __cold__)) void __cxa_guard_abort(guard_type* raw_guard_object) {
  SelectedImplementation imp(raw_guard_object);
  imp.cxa_guard_abort();
}

}  // extern "C"

}  // namespace __cxxabiv1
