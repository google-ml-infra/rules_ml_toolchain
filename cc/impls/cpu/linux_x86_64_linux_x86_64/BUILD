load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load("//third_party/rules_cc_toolchain:toolchain_config.bzl", "cc_toolchain_config")
load("//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl", "cc_toolchain_import")
load("//third_party/rules_cc_toolchain/features:features.bzl", "cc_toolchain_import_feature")

#=====================================================================
# Tools: Linux x86_64, Sysroot: Linux x86_64
#=====================================================================

package(
    default_visibility = [
        "//cc/impls/cpu:__pkg__",
    ],
)

# TODO: remove below alias
alias(
    name = "startup_libs",
    actual = "@sysroot_linux_x86_64//:startup_libs",
    visibility = ["//visibility:public"],
)

cc_toolchain_import_feature(
    name = "startup_libs_feature",
    enabled = True,
    toolchain_import = ":startup_libs",
)

# buildifier: leave-alone
cc_toolchain_import(
    name = "imports",
    deps = [
        "@sysroot_linux_x86_64//:includes_c",
        "@llvm_linux_x86_64//:includes",
        "@sysroot_linux_x86_64//:includes_system",
        "@sysroot_linux_x86_64//:glibc",
        "@sysroot_linux_x86_64//:pthread",
        "@llvm_linux_x86_64//:libclang_rt",
    ],
    visibility = ["//visibility:public"],
)

cc_toolchain_import_feature(
    name = "imports_feature",
    enabled = True,
    toolchain_import = ":imports",
)

# buildifier: leave-alone
filegroup(
    name = "all",
    srcs = [
        ":imports",
        "//cc/impls/cpu/wrappers:all",
        ":startup_libs",
        "@llvm_linux_x86_64//:all",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "compiler",
    srcs = [
        ":imports",
        "//cc/impls/cpu/wrappers:all",
        "@llvm_linux_x86_64//:clang",
        "@llvm_linux_x86_64//:clang++",
        "@llvm_linux_x86_64//:distro_libs",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "linker",
    srcs = [
        ":compiler",
        "//cc/impls/cpu/wrappers:all",
        "@llvm_linux_x86_64//:ld",
        "@sysroot_linux_x86_64//:startup_libs",
        "@llvm_linux_x86_64//:distro_libs",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "ar",
    srcs = [
        "//cc/impls/cpu/wrappers:all",
        "@llvm_linux_x86_64//:ar",
        "@llvm_linux_x86_64//:distro_libs",
    ],
)
