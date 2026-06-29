# Hermetic ROCm distribution

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
