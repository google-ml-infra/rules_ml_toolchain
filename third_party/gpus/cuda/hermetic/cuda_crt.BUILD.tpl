licenses(["restricted"])  # NVIDIA proprietary license

load("@cuda_cudart//:version.bzl", _cudart_version = "VERSION")
load("@local_config_cuda//cuda:build_defs.bzl", "if_cuda_newer_than")

cc_library(
    name = "headers",
    %{comment}hdrs = if_cuda_newer_than(
        %{comment}"13_0",
        %{comment}if_true = glob(["include/crt/**"]),
        %{comment}if_false = [],
    %{comment}),
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["include"],
    strip_include_prefix = "include",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

