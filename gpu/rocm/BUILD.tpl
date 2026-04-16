licenses(["restricted"])  # MPL2, portions GPL v3, LGPL v3, BSD-like

package(default_visibility = ["//visibility:private"])

# Export rocm_dist directory so it can be referenced directly as a label by XLA
# XLA's rocm_configure needs to symlink this directory into its own repository
exports_files(
    ["rocm_dist"],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "hip_runtime",
    hdrs = glob(["%{rocm_root}/include/**/*.h"]),
    includes = ["%{rocm_root}/include"],
    srcs = glob(
        [
            "%{rocm_root}/lib/libamdhip64.so*",
            "%{rocm_root}/lib/libhsa-runtime64.so*",
            "%{rocm_root}/lib/librocprofiler-register.so.0*",
            "%{rocm_root}/lib/libamd_comgr.so*",
            "%{rocm_root}/lib/libamd_comgr_loader.so*",
            "%{rocm_root}/lib/rocm_sysdeps/lib/*.so*",
            "%{rocm_root}/llvm/lib/libclang-cpp.so*",
            "%{rocm_root}/llvm/lib/libLLVM.so.*",
        ],
        exclude = [
            "%{rocm_root}/**/libamdhip64.so.*.*.*",
        ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "rocm_redist",
    srcs = glob(["%{rocm_root}/**"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "toolchain_data",
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
    ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "all_files",
    srcs = glob(["%{rocm_root}/**"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "rocm_root",
    srcs = [":all_files"],
    visibility = ["//visibility:public"],
)

config_setting(
    name = "using_hipcc",
    define_values = {
        "using_rocm": "true",
    },
    visibility = ["//visibility:public"],
)
