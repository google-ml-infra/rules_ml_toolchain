# Hermetic ROCm distribution

# Export the distribution directory so it can be symlinked by other repositories
exports_files(["%{rocm_root}"], visibility = ["//visibility:public"])

# Export selective toolchain files to avoid filling up sandboxes
filegroup(
    name = "rocm_root",
    srcs = glob([
        "%{rocm_root}/bin/hipcc",
        "%{rocm_root}/lib/llvm/**",
        "%{rocm_root}/llvm/bin/*",
        "%{rocm_root}/lib/llvm/lib/clang/**/include/**",
        "%{rocm_root}/lib/llvm/lib/clang/**/lib/**/*.a",
        "%{rocm_root}/lib/llvm/lib/clang/**/lib/**/*.bc",
        "%{rocm_root}/llvm/lib/clang/*/include/**",
        "%{rocm_root}/share/hip/**",
        "%{rocm_root}/amdgcn/**",
        "%{rocm_root}/lib/rocm_sysdeps/lib/*.so*",
        "%{rocm_root}/llvm/lib/*.so*",
        "%{rocm_root}/.info/**",
        "%{rocm_root}/include/**",
        "%{rocm_root}/lib/**",
    ], allow_empty = True),
    visibility = ["//visibility:public"],
)

# Alias for compatibility
alias(
    name = "all",
    actual = ":rocm_root",
    visibility = ["//visibility:public"],
)
