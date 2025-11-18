#=====================================================================
# Not ManyLinux tag compliant libraries for usage in deps attribute
#=====================================================================

# Alias for OpenMP cc_import
alias(
    name = "openmp",
    actual = select({
        "//common:is_linux_x86_64": "@sysroot_linux_x86_64//:openmp_import",
        "//common:is_linux_aarch64": "@sysroot_linux_aarch64//:openmp_import",
    }),
    visibility = ["//visibility:public"],
)
