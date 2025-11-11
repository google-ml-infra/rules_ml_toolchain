# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================

load(
    "//third_party/rules_cc_toolchain/features:features.bzl",
    "cc_feature",
    "cc_toolchain_import_feature",
    "cc_toolchain_sysroot_feature",
)

#load(":sanitizer_feature.bzl", "cc_sanitizer_feature")

package(
    default_visibility = [
        "//cc/impls/darwin_aarch64_darwin_aarch64:__pkg__",
        "//cc/impls/linux_aarch64_linux_aarch64:__pkg__",
        "//cc/impls/linux_aarch64_linux_aarch64_cuda:__pkg__",
        "//cc/impls/linux_x86_64_darwin_aarch64:__pkg__",
        "//cc/impls/linux_x86_64_linux_aarch64:__pkg__",
        "//cc/impls/linux_x86_64_linux_x86_64:__pkg__",
        "//cc/impls/linux_x86_64_linux_x86_64_cuda:__pkg__",
        "//cc/impls/linux_x86_64_linux_x86_64_sycl:__pkg__",
    ],
)

cc_feature(
    name = "garbage_collect_symbols_mac",
    compiler_flags = [
        "-fdata-sections",
        "-ffunction-sections",
    ],
    enabled = True,
)

cc_feature(
    name = "detect_issues",
    compiler_flags = [
        "-U_FORTIFY_SOURCE",
        "-D_FORTIFY_SOURCE=1",
        "-fstack-protector",
        "-fno-omit-frame-pointer",
    ],
    enabled = True,
)

cc_feature(
    name = "detect_issues_ext",
    compiler_flags = [
        "-Wthread-safety",
        "-Wself-assign",
        "-Wunused-but-set-parameter",
        "-Wno-free-nonheap-object",
    ],
    enabled = True,
)

cc_feature(
    name = "constants_merge",
    cc_flags = [
        "-fmerge-all-constants",
    ],
    enabled = True,
)

cc_feature(
    name = "asserts_disable",
    compiler_flags = [
        "-DNDEBUG",
    ],
    enabled = True,
)

# Required when building with clang>=19, see jax-ml/jax#27091
cc_feature(
    name = "clang19",
    compiler_flags = [
        "-Wno-error=c23-extensions",
    ],
    enabled = True,
)

cc_toolchain_sysroot_feature(
    name = "sysroot_linux_x86_64",
    enabled = True,
    sysroot = "@sysroot_linux_x86_64//:sysroot",
    target = "x86_64-linux-gnu",
)

cc_toolchain_sysroot_feature(
    name = "sysroot_linux_aarch64",
    enabled = True,
    sysroot = "@sysroot_linux_aarch64//:sysroot",
    target = "aarch64-linux-gnu",
)

cc_toolchain_sysroot_feature(
    name = "sysroot_darwin_aarch64",
    enabled = True,
    sysroot = "@sysroot_darwin_aarch64//:sysroot",
    target = "arm64-apple-macosx15.1",
)

# macOS specific. Needed for llvm-install-name-tool when long paths for libraries are used.
# Usually bazel generates long loader paths.
cc_feature(
    name = "max_install_names",
    enabled = True,
    linker_flags = [
        "-headerpad_max_install_names",
    ],
)

# macOS specific. Needed for llvm-install-name-tool when long paths for libraries are used.
# Usually bazel generates long loader paths.
cc_feature(
    name = "no_elaborated_enum_base",
    cc_flags = ["-Wno-elaborated-enum-base"],
    compiler_flags = ["-Wno-elaborated-enum-base"],
    enabled = True,
)

cc_feature(
    name = "supports_dynamic_linker",
    enabled = True,
)

#cc_feature(
#    name = "nobuiltin",
#    compiler_flags = ["-fno-builtin"],
#    provides = ["compilation_mode"],
#)

cc_feature(
    name = "allow_shlib_undefined",
    enabled = True,
    linker_flags = [
        "-Wl,--allow-shlib-undefined",
    ],
)

cc_feature(
    name = "supports_start_end_lib_feature",
    enabled = True,
)

cc_feature(
    name = "generate_pdb_file",
    #    requires = [
    #        feature_set(features = ["dbg"]),
    #        feature_set(features = ["fastbuild"]),
    #    ],
)

#cc_feature(
#    name = "dbg",
#    implies = ["generate_pdb_file"],
#)

cc_feature(
    name = "fastbuild",
    #implies = ["generate_pdb_file"],
)

cc_feature(
    name = "opt",
)

# TODO: Remove -g flag
cc_feature(
    name = "sanitizer",
    compiler_flags = select({
        "//common:sanitize_address": ["-fno-PIE", "-g", "-fsanitize=address", "-mllvm", "-asan-force-dynamic-shadow=1"],
        "//common:sanitize_undefined": ["-g", "-fsanitize=undefined"],
        "//common:sanitize_thread": ["-g", "-fsanitize=thread"],
        "//common:sanitize_memory": ["-g", "-fsanitize=memory"],
        "//common:sanitize_leak": ["-g", "-fsanitize=leak"],
        "//conditions:default": [],
    }),
    linker_flags = select({
        "//common:sanitize_address": ["-g", "-lrt", "-l:libasan.a"],
        "//common:sanitize_undefined": ["-g", "-lrt", "-l:libasan.a"],
        "//common:sanitize_thread": ["-g", "-lrt", "-l:libasan.a"],
        "//common:sanitize_memory": ["-g", "-lrt", "-l:libasan.a"],
        "//common:sanitize_leak": ["-g", "-lrt", "-l:libasan.a"],
        "//conditions:default": [],
    }),
    enabled = True,
)
