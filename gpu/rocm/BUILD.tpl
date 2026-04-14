licenses(["restricted"])  # MPL2, portions GPL v3, LGPL v3, BSD-like

package(default_visibility = ["//visibility:private"])

# HIP runtime shared libraries
cc_import(
    name = "amdhip64_import",
    shared_library = "%{rocm_root}/lib/libamdhip64.so",
)

cc_import(
    name = "hsa_runtime64_import",
    shared_library = "%{rocm_root}/lib/libhsa-runtime64.so",
)

# Wrapper library to ensure rpath is set correctly and libraries are in runfiles
cc_library(
    name = "hip_runtime",
    data = [
        "%{rocm_root}/lib/libamdhip64.so",
        "%{rocm_root}/lib/libamdhip64.so.7",
        "%{rocm_root}/lib/libhsa-runtime64.so",
        "%{rocm_root}/lib/libhsa-runtime64.so.1",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":amdhip64_import",
        ":hsa_runtime64_import",
    ],
)

# HIP headers library - provides HIP/ROCm headers and runtime for compilation and linking
cc_library(
    name = "hip_headers",
    hdrs = glob(["%{rocm_root}/include/**/*.h"]),
    includes = ["%{rocm_root}/include"],
    visibility = ["//visibility:public"],
    deps = [":hip_runtime"],
)

filegroup(
    name = "toolchain_data",
    srcs = glob([
        "%{rocm_root}/bin/hipcc",
        "%{rocm_root}/lib/llvm/**",
        "%{rocm_root}/share/hip/**",
        "%{rocm_root}/amdgcn/**",
        "%{rocm_root}/lib/rocm_sysdeps/lib/*.so*",
        "%{rocm_root}/lib/libamd_comgr_loader.so*",
        "%{rocm_root}/lib/libamd_comgr.so*",
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
