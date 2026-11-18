// Copies an ar archive, moving the static constructors of its ELF64
// little-endian relocatable members from legacy .ctors sections into
// .init_array.
//
// Several of NVIDIA's static libraries (libnvJitLink_static.a,
// libnvptxcompiler_static.a, libnvrtc_static.a, libnvfatbin_static.a,
// libcudnn_graph_static.a) still register their constructors in .ctors.
// GNU ld folds .ctors into .init_array, but ld.lld keeps it as a separate
// output section that neither glibc nor musl run, so with lld those
// libraries' globals are never initialized (libnvJitLink_static.a then
// crashes on first use in pthread_mutex_lock(NULL)).
//
// .ctors runs last-to-first and .init_array first-to-last, so the entries
// and the relocations that fill them in are reversed, as GNU ld does. The
// rewrite keeps every member the same size: the section is renamed by
// overwriting the ".rela.ctors" string in .shstrtab with the equally long
// ".init_array" (relocation sections are tied to their target through
// sh_info, not their name), so member offsets and the archive's symbol
// index stay valid.
//
// Usage: ctors_to_init_array IN.a OUT.a

#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iterator>
#include <string>
#include <vector>

namespace {

constexpr uint32_t kShtRela = 4, kShtRel = 9, kShtInitArray = 14;

struct Shdr {
  uint32_t name, type;
  uint64_t flags, addr, offset, size;
  uint32_t link, info;
  uint64_t addralign, entsize;
};
static_assert(sizeof(Shdr) == 64, "unexpected Elf64_Shdr layout");

[[noreturn]] void Fail(const std::string& msg) {
  std::fprintf(stderr, "ctors_to_init_array: %s\n", msg.c_str());
  std::exit(1);
}

template <typename T>
T Load(const std::vector<uint8_t>& d, size_t at) {
  if (at + sizeof(T) > d.size()) Fail("truncated input");
  T v;
  std::memcpy(&v, d.data() + at, sizeof(T));
  return v;
}

template <typename T>
void Store(std::vector<uint8_t>& d, size_t at, const T& v) {
  std::memcpy(d.data() + at, &v, sizeof(T));
}

// Converts the member starting at `base`; returns whether it changed.
bool ConvertObject(std::vector<uint8_t>& d, size_t base, size_t end) {
  if (end - base < 64 || std::memcmp(d.data() + base, "\x7f" "ELF", 4) != 0 ||
      d[base + 4] != 2 /*ELFCLASS64*/ || d[base + 5] != 1 /*ELFDATA2LSB*/ ||
      Load<uint16_t>(d, base + 16) != 1 /*ET_REL*/) {
    return false;
  }
  const uint64_t shoff = Load<uint64_t>(d, base + 0x28);
  const uint16_t shentsize = Load<uint16_t>(d, base + 0x3A);
  uint64_t shnum = Load<uint16_t>(d, base + 0x3C);
  uint64_t shstrndx = Load<uint16_t>(d, base + 0x3E);
  if (shentsize != sizeof(Shdr)) Fail("unexpected section header size");
  auto hdr_at = [&](uint64_t i) { return base + shoff + i * sizeof(Shdr); };
  auto get = [&](uint64_t i) { return Load<Shdr>(d, hdr_at(i)); };
  // Extended numbering: counts that do not fit live in section header 0.
  if (shnum == 0) shnum = get(0).size;
  if (shstrndx == 0xFFFF) shstrndx = get(0).link;

  const Shdr strtab = get(shstrndx);
  const size_t str_begin = base + strtab.offset;
  const size_t str_end = str_begin + strtab.size;
  auto name_is = [&](const Shdr& h, const char* want) {
    const size_t n = std::strlen(want) + 1;
    return str_begin + h.name + n <= str_end &&
           std::memcmp(d.data() + str_begin + h.name, want, n) == 0;
  };

  std::vector<uint64_t> ctors;
  for (uint64_t i = 0; i < shnum; ++i) {
    if (name_is(get(i), ".ctors")) ctors.push_back(i);
  }
  if (ctors.empty()) return false;

  static const char kRelaCtors[] = "\0.rela.ctors";  // 13 bytes incl. both NULs
  auto it = std::search(d.begin() + str_begin, d.begin() + str_end,
                        kRelaCtors, kRelaCtors + sizeof(kRelaCtors));
  if (it == d.begin() + str_end) Fail("no .rela.ctors name to reuse");
  const uint32_t new_name =
      static_cast<uint32_t>(std::distance(d.begin() + str_begin, it) + 1);
  std::memcpy(d.data() + str_begin + new_name, ".init_array", 12);

  for (uint64_t ci : ctors) {
    Shdr h = get(ci);
    if (h.size % 8 != 0) Fail(".ctors size is not a multiple of 8");
    uint8_t* p = d.data() + base + h.offset;
    for (uint64_t lo = 0, hi = h.size - 8; lo < hi; lo += 8, hi -= 8) {
      std::swap_ranges(p + lo, p + lo + 8, p + hi);
    }
    h.name = new_name;
    h.type = kShtInitArray;
    Store(d, hdr_at(ci), h);
    for (uint64_t ri = 0; ri < shnum; ++ri) {
      Shdr r = get(ri);
      if ((r.type != kShtRela && r.type != kShtRel) || r.info != ci) continue;
      const uint64_t ent = r.type == kShtRela ? 24 : 16;
      for (uint64_t k = 0; k < r.size; k += ent) {
        const size_t at = base + r.offset + k;
        Store<uint64_t>(d, at, h.size - 8 - Load<uint64_t>(d, at));
      }
      r.name = 0;
      Store(d, hdr_at(ri), r);
    }
  }
  return true;
}

}  // namespace

int main(int argc, char** argv) {
  if (argc != 3) Fail("usage: ctors_to_init_array IN.a OUT.a");
  std::ifstream in(argv[1], std::ios::binary);
  if (!in) Fail(std::string("cannot read ") + argv[1]);
  std::vector<uint8_t> d((std::istreambuf_iterator<char>(in)),
                         std::istreambuf_iterator<char>());
  if (d.size() < 8 || std::memcmp(d.data(), "!<arch>\n", 8) != 0) {
    Fail(std::string(argv[1]) + " is not an ar archive");
  }
  for (size_t p = 8; p + 60 <= d.size();) {
    const size_t size = std::strtoull(
        std::string(d.begin() + p + 48, d.begin() + p + 58).c_str(), nullptr,
        10);
    if (p + 60 + size > d.size()) Fail("truncated archive member");
    ConvertObject(d, p + 60, p + 60 + size);
    p += 60 + size + (size & 1);
  }
  std::ofstream out(argv[2], std::ios::binary);
  out.write(reinterpret_cast<const char*>(d.data()), d.size());
  if (!out) Fail(std::string("cannot write ") + argv[2]);
  return 0;
}
