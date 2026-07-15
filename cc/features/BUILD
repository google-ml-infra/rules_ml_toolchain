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
    "@rules_cc//cc:action_names.bzl",
    "ACTION_NAMES",
)
load(
    "//third_party/rules_cc_toolchain/features:features.bzl",
    "cc_feature",
    "cc_toolchain_import_feature",
)
load(
    ":features.bzl",
    "compiler_input_feature",
    "compiler_output_feature",
    "user_compile_feature",
    "unfiltered_compile_feature",
    "include_paths_feature",
    "external_include_paths_feature",
)
load(
    "//cc/features:runtime_library_search_directories.bzl",
    "runtime_library_search_directories",
)

package(
    default_visibility = [
        "//cc/impls/darwin_aarch64_darwin_aarch64:__pkg__",
        "//cc/impls/linux_aarch64_linux_aarch64:__pkg__",
        "//cc/impls/linux_aarch64_linux_aarch64_cuda:__pkg__",
        "//cc/impls/linux_x86_64_darwin_aarch64:__pkg__",
        "//cc/impls/linux_x86_64_linux_aarch64:__pkg__",
        "//cc/impls/linux_x86_64_linux_x86_64:__pkg__",
        "//cc/impls/linux_x86_64_linux_x86_64_cuda:__pkg__",
        "//cc/impls/linux_x86_64_linux_x86_64_rocm:__pkg__",
        "//cc/impls/linux_x86_64_linux_x86_64_sycl:__pkg__",
    ],
)

cc_feature(
    name = "language",
    # C language
    c_flags = [
        "-xc",
    ],
    # C++ language actions and flag (excluding C++ modules)
    actions = [
        ACTION_NAMES.linkstamp_compile,
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.cpp_header_parsing,
        ACTION_NAMES.lto_backend,
        ACTION_NAMES.clif_match,
        ACTION_NAMES.objcpp_compile,
    ],
    flags = [
        "-xc++",
    ],
    enabled = True,
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

# Required when building with clang>=19, see jax-ml/jax#27091
cc_feature(
    name = "clang19",
    compiler_flags = [
        "-Wno-error=c23-extensions",
    ],
    enabled = True,
)

# Local sysroot feature - use system root instead of hermetic sysroot
# Generic for all Linux architectures
cc_feature(
    name = "local_sysroot_linux",
    enabled = True,
    compiler_flags = ["--sysroot=/"],
    linker_flags = ["--sysroot=/"],
    env_sets = {
        "HOST_SYSROOT": "/",
    },
)

# When using local sysroot, we need to explicitly link default system libraries
# since we don't use hermetic_libraries feature
cc_feature(
    name = "local_sysroot_default_libs",
    enabled = True,
    linker_flags = [
        "-lstdc++",
        "-lm",
        "-lpthread",
        "-ldl",
    ],
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

cc_feature(
    name = "no_solib_rpaths",
    # Note: This feature must be explicitly requested by targets that want to strip solib rpaths.
    # It's disabled by default to preserve normal Bazel behavior for most builds.
    # Wheel builds should explicitly include this in their features list.
    enabled = False,
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

# Compilation modes
cc_feature(
    name = "fastbuild",
    compiler_flags = [
        "-O0",
    ],
    #implies = ["generate_pdb_file"],
    provides = ["compilation_mode"],
    expand_if_not_available = "opt",
)

cc_feature(
    name = "opt",
    compiler_flags = [
        "-g0",
        "-O2",
        "-DNDEBUG",
    ],
    provides = ["compilation_mode"],
)

cc_feature(
    name = "dbg",
    compiler_flags = [
        "-g",
        "-O0",
    ],
    provides = ["compilation_mode"],
)

cc_feature(
    name = "libc++",
    compiler_flags = [
        # Allows the use of GNU-specific extension keywords that are not part of the standard C or C++ specifications
        "-fgnu-keywords",
    ],
    linker_flags = [
        "-stdlib=libc++",
    ],
    enabled = True,
)

# Runtime library search directories feature
# This overrides the default action_config-embedded flag_sets to ensure
# proper with_features support for no_solib_rpaths
runtime_library_search_directories(
    name = "runtime_library_search_directories",
)

cc_feature(
    name = "cpp_modules",
    enabled = False,
)

cc_feature(
    name = "cpp20_module_compile_flags",
    actions = [
        ACTION_NAMES.cpp20_module_compile,
    ],
    flags = [
        "-fmodule-output=%{cpp_module_output_file}",
    ],
    expand_if_available = "cpp_module_output_file",
    enabled = True,
)

cc_feature(
    name = "cpp_module_modmap_file",
    actions = [
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.cpp20_module_compile,
        ACTION_NAMES.cpp20_module_codegen,
    ],
    flags = [
        "@%{cpp_module_modmap_file}",
    ],
    expand_if_available = "cpp_module_modmap_file",
    enabled = True,
)

cc_feature(
    name = "dependency_file",
    actions = [
        ACTION_NAMES.assemble,
        ACTION_NAMES.preprocess_assemble,
        ACTION_NAMES.c_compile,
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.cpp_module_compile,
        ACTION_NAMES.objc_compile,
        ACTION_NAMES.objcpp_compile,
        ACTION_NAMES.cpp_header_parsing,
        ACTION_NAMES.cpp_module_deps_scanning,
        ACTION_NAMES.cpp20_module_compile,
        ACTION_NAMES.clif_match,
    ],
    flags = [
        "-MD",
        "-MF",
        "%{dependency_file}"
    ],
    expand_if_available = "dependency_file",
    enabled = True,
)

cc_feature(
    name = "random_seed",
    actions = [
        ACTION_NAMES.c_compile,
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.cpp_module_codegen,
        ACTION_NAMES.cpp_module_compile,
        ACTION_NAMES.cpp_module_deps_scanning,
        ACTION_NAMES.cpp20_module_compile,
        ACTION_NAMES.cpp20_module_codegen,
    ],
    flags = [
        "-frandom-seed=%{output_file}",
    ],
    expand_if_available = "output_file",
    enabled = True,
)

compiler_input_feature(
    name = "compiler_input_flags",
    enabled = True,
)

compiler_output_feature(
    name = "compiler_output_flags",
    enabled = True,
)

user_compile_feature(
    name = "user_compile_flags",
    enabled = True,
)

#unfiltered_compile_feature(
#    name = "unfiltered_compile_flags",
#    enabled = True,
#)

include_paths_feature(
    name = "include_paths",
    enabled = True,
)

external_include_paths_feature(
    name = "external_include_paths",
    enabled = True,
)
