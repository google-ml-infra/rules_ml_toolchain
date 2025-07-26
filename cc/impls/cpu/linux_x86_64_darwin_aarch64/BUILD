load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load("//third_party/rules_cc_toolchain:toolchain_config.bzl", "cc_toolchain_config")
load("//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl", "cc_toolchain_import")
load("//third_party/rules_cc_toolchain/features:features.bzl", "cc_toolchain_import_feature")

package(
    default_visibility = [
        "//cc/impls/cpu:__pkg__",
    ],
)

# buildifier: leave-alone
cc_toolchain_import(
    name = "imports",
    deps = [
        "@sysroot_darwin_aarch64//:includes_c",
        "@llvm_linux_x86_64//:includes",
        "@sysroot_darwin_aarch64//:includes_system",
        "@sysroot_darwin_aarch64//:glibc",
        "@sysroot_darwin_aarch64//:pthread",
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
        "@llvm_linux_x86_64//:all",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "compiler",
    srcs = [
        ":all",
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
        "@llvm_linux_x86_64//:distro_libs",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "ar",
    srcs = [
        "//cc/impls/cpu/wrappers:all",
        "@llvm_linux_x86_64//:ar_darwin",
        "@llvm_linux_x86_64//:distro_libs",
    ],
)
