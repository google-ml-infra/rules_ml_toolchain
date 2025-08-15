licenses(["restricted"])  # NVIDIA proprietary license

load("@local_config_cuda//cuda:build_defs.bzl", "if_version_equal_or_greater_than")
load("@cuda_cudart//:version.bzl", _cudart_version = "VERSION")

cc_library(
    name = "headers",
    %{comment}hdrs = if_version_equal_or_greater_than(
        %{comment}_cudart_version,
        %{comment}"13",
        %{comment}if_true = glob(["include/crt/**"]),
        %{comment}if_false = [],
    %{comment}),
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["include"],
    strip_include_prefix = "include",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

