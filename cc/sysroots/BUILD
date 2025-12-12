#=====================================================================
# Not ManyLinux tag compliant libraries for usage in deps attribute
#=====================================================================

load(":collect_cc_libraries.bzl", "collect_cc_libraries")

alias(
    name = "openmp",
    actual = select({
        "//common:is_linux_x86_64": "@sysroot_linux_x86_64//:openmp_import",
        "//common:is_linux_aarch64": "@sysroot_linux_aarch64//:openmp_import",
    }),
    visibility = ["//visibility:public"],
)

alias(
    name = "openmp_copyright",
    actual = select({
        "//common:is_linux_x86_64": "@sysroot_linux_x86_64//:openmp_copyright",
        "//common:is_linux_aarch64": "@sysroot_linux_aarch64//:openmp_copyright",
    }),
)

collect_cc_libraries(
    name = "openmp_libs",
    deps = [
        ":openmp",
        ":openmp_copyright",
    ],
    visibility = ["//visibility:public"],
)
