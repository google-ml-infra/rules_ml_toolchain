licenses(["restricted"])  # NVIDIA proprietary license

load("@local_config_cuda//cuda:build_defs.bzl", "if_cuda_newer_than")

exports_files([
    "nvvm/bin/cicc",
    "nvvm/libdevice/libdevice.10.bc",
])

filegroup(
    name = "cicc",
    srcs = if_cuda_newer_than(
        "13_0",
        if_true = ["nvvm/bin/cicc"],
        if_false = [],
    ),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "nvvm",
    srcs = if_cuda_newer_than(
        "13_0",
        if_true = ["nvvm/libdevice/libdevice.10.bc"],
        if_false = [],
    ),
    visibility = ["//visibility:public"],
)
