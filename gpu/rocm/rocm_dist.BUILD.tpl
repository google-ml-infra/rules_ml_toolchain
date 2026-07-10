# Hermetic ROCm distribution

load("@rules_ml_toolchain//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl", "cc_toolchain_import")

# Export the distribution directory so it can be symlinked by other repositories
exports_files(["%{rocm_root}"], visibility = ["//visibility:public"])

# Export selective toolchain files to avoid filling up sandboxes
filegroup(
    name = "rocm_root",
    srcs = glob([
        "%{rocm_root}/bin/hipcc",
        "%{rocm_root}/lib/llvm/bin/**",
        "%{rocm_root}/lib/llvm/lib/**",
        "%{rocm_root}/llvm/bin/*",
        "%{rocm_root}/llvm/lib/clang/*/include/**",
        "%{rocm_root}/llvm/lib/*.so*",
        "%{rocm_root}/share/hip/**",
        "%{rocm_root}/amdgcn/**",
        "%{rocm_root}/.info/**",
        "%{rocm_root}/include/**",
        "%{rocm_root}/lib/*.so*",
        "%{rocm_root}/lib/hipblaslt/**",
        "%{rocm_root}/lib/rocblas/**",
        "%{rocm_root}/lib/rocm_sysdeps/**",
        "%{rocm_root}/lib/libhipblaslt*.so*",
        "%{rocm_root}/lib/librocblas*.so*",
        "%{rocm_root}/lib/libamdhip64*.so*",
        "%{rocm_root}/lib/libMIOpen*.so*",
    ],
    exclude = [
        "%{rocm_root}/lib/llvm/include/**",
        "%{rocm_root}/tests/**",
        "%{rocm_root}/libexec/**",
        "%{rocm_root}/lib/rocm_sysdeps/share/terminfo/**",
    ],
    allow_empty = True),
    visibility = ["//visibility:public"],
)

# Alias for compatibility
alias(
    name = "all",
    actual = ":rocm_root",
    visibility = ["//visibility:public"],
)

# llvm-symbolizer for sanitizer stack trace symbolization
filegroup(
    name = "llvm-symbolizer",
    srcs = glob([
        "%{rocm_root}/llvm/bin/llvm-symbolizer",
        "%{rocm_root}/lib/llvm/bin/llvm-symbolizer",
    ]),
    visibility = ["//visibility:public"],
)

# Distribution libraries needed by llvm-symbolizer
filegroup(
    name = "distro_libs",
    srcs = glob([
        "%{rocm_root}/llvm/lib/*.so*",
        "%{rocm_root}/lib/llvm/lib/*.so*",
    ]),
    visibility = ["//visibility:public"],
)

# ROCm clang compiler (single file for use in attributes)
filegroup(
    name = "clang",
    srcs = glob(
        ["%{rocm_root}/llvm/bin/clang"],
        exclude = ["%{rocm_root}/llvm/bin/clang-*"],
    ),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "clang++",
    srcs = glob(["%{rocm_root}/llvm/bin/clang++"]),
    visibility = ["//visibility:public"],
)

# All clang binaries (for packaging)
filegroup(
    name = "clang_all",
    srcs = glob([
        "%{rocm_root}/llvm/bin/clang",
        "%{rocm_root}/llvm/bin/clang-*",
    ]),
    visibility = ["//visibility:public"],
)

# ROCm LLVM linker
filegroup(
    name = "ld",
    srcs = glob(["%{rocm_root}/llvm/bin/ld.lld"]),
    visibility = ["//visibility:public"],
)

# ROCm LLVM archiver
filegroup(
    name = "ar",
    srcs = glob(["%{rocm_root}/llvm/bin/llvm-ar"]),
    visibility = ["//visibility:public"],
)

# ROCm LLVM strip
filegroup(
    name = "strip",
    srcs = glob(["%{rocm_root}/llvm/bin/llvm-strip"]),
    visibility = ["//visibility:public"],
)

# ROCm LLVM compiler includes (raw filegroup)
filegroup(
    name = "compiler_incs_files",
    srcs = glob([
        "%{rocm_root}/llvm/lib/clang/*/include/**",
    ]),
)

# Wrapped for cc_toolchain_import
cc_toolchain_import(
    name = "compiler_incs",
    hdrs = [":compiler_incs_files"],
    includes = glob(["%{rocm_root}/llvm/lib/clang/*/include"], exclude_directories = 0),
    visibility = ["//visibility:public"],
)


