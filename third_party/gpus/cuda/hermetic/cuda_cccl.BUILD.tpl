licenses(["restricted"])  # NVIDIA proprietary license
load(
    "@rules_ml_toolchain//third_party/gpus:nvidia_common_rules.bzl",
    "if_cuda_major_version_newer_than",
)
load("@cuda_cudart//:version.bzl", _cudart_version = "VERSION")

cc_library(
    name = "headers",
    hdrs = glob([
        %{comment}"include/cub/**",
        %{comment}"include/cuda/**",
        %{comment}"include/nv/**",
        %{comment}"include/thrust/**",
    ]),
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["include"],
    strip_include_prefix = if_cuda_major_version_newer_than(_cudart_version, 13, if_true = "incude/cccl", if_false = "include"),
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)
