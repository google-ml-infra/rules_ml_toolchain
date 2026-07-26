load("@rules_cc//cc:defs.bzl", "cc_import", "cc_library")

licenses(["restricted"])  # NVIDIA proprietary license

load("@local_config_cuda//cuda:build_defs.bzl", "cuda_rpath_flags", "if_cuda_newer_than", "if_static_cuda")

filegroup(
    name = "header_list",
    srcs = [
        "include/nvFatbin.h",
    ],
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

cc_library(
    name = "headers",
    hdrs = [":header_list"],
    includes = ["include"],
    strip_include_prefix = "include",
)

cc_import(
    name = "nvfatbin_static_library",
    hdrs = [":headers"],
    static_library = "lib/libnvfatbin_static.a",
    alwayslink = True,
)

cc_import(
    name = "nvfatbin_shared_library",
    hdrs = [":headers"],
    shared_library = "lib/libnvfatbin.so.%{version}",
)

cc_library(
    name = "nvfatbin",
    deps = if_static_cuda([":nvfatbin_static_library"], [":nvfatbin_shared_library"]),
    linkopts = if_cuda_newer_than(
        "13_0",
        if_true = cuda_rpath_flags("nvidia/cu13/lib"),
        if_false = cuda_rpath_flags("nvidia/cuda_nvfatbin/lib"),
    ),
    visibility = ["//visibility:public"],
)
