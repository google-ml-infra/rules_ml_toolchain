# Copyright 2026 Google LLC
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

"""macOS aarch64 toolchain macro."""

load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load("//third_party/rules_cc_toolchain:toolchain_config.bzl", "cc_toolchain_config")
load("//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl", "cc_toolchain_import")
load("//third_party/rules_cc_toolchain/features:features.bzl", "cc_toolchain_import_feature")

def darwin_aarch64_darwin_aarch64_toolchain(
        name = "toolchain",
        sysroot = "sysroot_darwin_aarch64"):
    native.filegroup(
        name = "wrappers",
        srcs = [
            "//wrappers:all",
        ],
        visibility = ["//visibility:public"],
    )

    cc_toolchain_import(
        name = "imports",
        deps = [
            Label("@sysroot_darwin_aarch64//:std_incs"),
            Label("@llvm_darwin_aarch64//:compiler_incs"),
            Label("@sysroot_darwin_aarch64//:sys_incs"),
            Label("@sysroot_darwin_aarch64//:sys_libs"),
            Label("@llvm_darwin_aarch64//:libclang_rt"),
        ],
        visibility = ["//visibility:public"],
    )

    cc_toolchain_import_feature(
        name = "imports_feature",
        enabled = True,
        toolchain_import = ":imports",
    )

    # buildifier: leave-alone
    native.filegroup(
        name = "all",
        srcs = [
            ":imports",
            ":wrappers",
            Label("@llvm_darwin_aarch64//:all"),
            Label("@xcode_darwin//:all"),
        ],
    )

    # buildifier: leave-alone
    native.filegroup(
        name = "compiler",
        srcs = [
            ":all",
            ":wrappers",
            Label("@llvm_darwin_aarch64//:clang"),
            Label("@llvm_darwin_aarch64//:clang++"),
            Label("@llvm_darwin_aarch64//:asan_ignorelist"),
        ],
    )

    # buildifier: leave-alone
    native.filegroup(
        name = "linker",
        srcs = [
            ":compiler",
            ":wrappers",
            Label("@llvm_darwin_aarch64//:ld"),
        ],
    )

    # buildifier: leave-alone
    native.filegroup(
        name = "ar",
        srcs = [
            ":wrappers",
            Label("@llvm_darwin_aarch64//:ar"),
        ],
    )

    # buildifier: leave-alone
    native.filegroup(
        name = "objcopy",
        srcs = [
            ":wrappers",
            Label("@llvm_darwin_aarch64//:objcopy"),
            Label("@llvm_darwin_aarch64//:distro_libs"),
        ],
    )

    # buildifier: leave-alone
    native.filegroup(
        name = "strip",
        srcs = [
            ":wrappers",
            Label("@llvm_darwin_aarch64//:strip"),
            Label("@llvm_darwin_aarch64//:distro_libs"),
        ],
    )

    cc_toolchain_config(
        name = "config",
        archiver = Label("@llvm_darwin_aarch64//:ar"),
        c_compiler = Label("@llvm_darwin_aarch64//:clang"),
        cc_compiler = Label("@llvm_darwin_aarch64//:clang++"),
        cxx_builtin_include_directories = [
            "%workspace%/external/" + sysroot + "/usr/include/c++/v1",
            "%workspace%/external/" + sysroot + "/usr/include",
            "%workspace%/external/" + sysroot + "/System/Library/Frameworks",
        ],
        compiler_features = [
            # Hermetic libraries feature required before import.
            Label("//third_party/rules_cc_toolchain/features:hermetic"),
            ":imports_feature",
            Label("//third_party/rules_cc_toolchain/features:undefined_symbols"),

            # Toolchain configuration
            Label("//third_party/rules_cc_toolchain/features:warnings"),
            Label("//third_party/rules_cc_toolchain/features:errors"),
            Label("//third_party/rules_cc_toolchain/features:reproducible"),
            Label("//cc/features:language"),
            Label("//cc/features/darwin/aarch64:sysroot"),
            Label("//third_party/rules_cc_toolchain/features:coverage"),
            #"//cc/features:clang19",    # TODO: Add a selection mechanism based on the Clang version
            Label("//cc/features:max_install_names"),
            Label("//cc/features:no_elaborated_enum_base"),

            # PIC / PIE flags
            Label("//third_party/rules_cc_toolchain/features:supports_pic"),
            Label("//third_party/rules_cc_toolchain/features:position_independent_code"),

            # Optimization flags
            Label("//cc/features:dbg"),
            Label("//cc/features:fastbuild"),
            Label("//cc/features:opt"),
            Label("//cc/features:garbage_collect_symbols_mac"),
            Label("//cc/features:constants_merge"),
            Label("//cc/features:detect_issues"),

            # C++ standard configuration
            Label("//third_party/rules_cc_toolchain/features:c++11"),
            Label("//third_party/rules_cc_toolchain/features:c++14"),
            Label("//third_party/rules_cc_toolchain/features:c++17"),
            Label("//third_party/rules_cc_toolchain/features:c++20"),

            # Instead of --allow-shlib-undefined, macOS uses the -undefined flag with dynamic_lookup as an argument.
            # Label("//cc/features:allow_shlib_undefined"),
            Label("//cc/features:supports_start_end_lib_feature"),
            Label("//third_party/rules_cc_toolchain/features:use_lld"),
        ],
        dynamic_library_extension = ".dylib",
        install_name = Label("@llvm_darwin_aarch64//:install_name_tool_darwin"),
        linker = Label("@llvm_darwin_aarch64//:ld"),
        strip_tool = Label("@llvm_darwin_aarch64//:strip"),
        target_cpu = "aarch64",
        target_libc = "macosx",
        target_system_name = "local",
    )

    cc_toolchain(
        name = name,
        all_files = ":all",
        ar_files = ":ar",
        compiler_files = ":compiler",
        dwp_files = ":all",
        linker_files = ":linker",
        objcopy_files = ":objcopy",
        strip_files = ":strip",
        supports_param_files = 1,
        toolchain_config = ":config",
        toolchain_identifier = "toolchain_id_darwin_aarch64_darwin_aarch64",
    )
