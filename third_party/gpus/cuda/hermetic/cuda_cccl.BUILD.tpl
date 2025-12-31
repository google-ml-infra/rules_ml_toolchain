licenses(["restricted"])  # NVIDIA proprietary license
load(
    "@rules_ml_toolchain//third_party/gpus:nvidia_common_rules.bzl",
    "cuda_lib_header_prefix"
)
load("@cuda_cudart//:version.bzl", _cudart_version = "VERSION")

cc_library(
    name = "headers",
    hdrs = glob([
        %{comment}"include" + cuda_lib_header_prefix(_cudart_version, 13, "/cccl", "") + "/cub/**",
        %{comment}"include" + cuda_lib_header_prefix(_cudart_version, 13, "/cccl", "") + "/cuda/**",
        %{comment}"include" + cuda_lib_header_prefix(_cudart_version, 13, "/cccl", "") + "/nv/**",
        %{comment}"include" + cuda_lib_header_prefix(_cudart_version, 13, "/cccl", "") + "/thrust/**",
    ]),
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["include" + cuda_lib_header_prefix(_cudart_version, 13, "/cccl", "")],
    strip_include_prefix = "include" + cuda_lib_header_prefix(_cudart_version, 13, "/cccl", ""),
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)
