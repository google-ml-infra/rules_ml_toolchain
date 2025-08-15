licenses(["restricted"])  # NVIDIA proprietary license

load("@local_config_cuda//cuda:build_defs.bzl", "if_version_equal_or_greater_than")
load("@cuda_cudart//:version.bzl", _cudart_version = "VERSION")

exports_files([
    "nvvm/bin/cicc",
])

filegroup(
    name = "cicc",
    srcs = if_version_equal_or_greater_than(
        _cudart_version,
        "13",
        if_false = [],
        if_true = ["nvvm/bin/cicc"],
    ),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "nvvm",
    srcs = if_version_equal_or_greater_than(
        _cudart_version,
        "13",
        if_false = [],
        if_true = ["nvvm/libdevice/libdevice.10.bc"],
    ),
    visibility = ["//visibility:public"],
)
