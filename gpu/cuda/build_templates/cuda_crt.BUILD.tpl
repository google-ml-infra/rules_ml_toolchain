licenses(["restricted"])  # NVIDIA proprietary license

load("@cuda_cudart//:version.bzl", _cudart_version = "VERSION")
load("@local_config_cuda//cuda:build_defs.bzl", "if_cuda_newer_than")

filegroup(
    name = "header_list",
    %{comment}srcs = if_cuda_newer_than(
        %{comment}"13_0",
        %{comment}if_true = glob(["include/crt/**"]),
        %{comment}if_false = [],
    %{comment}),
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

cc_library(
    name = "headers",
    hdrs = [":header_list"],
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["include"],
    strip_include_prefix = "include",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

