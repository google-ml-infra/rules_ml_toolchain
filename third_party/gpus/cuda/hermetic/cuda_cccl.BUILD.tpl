licenses(["restricted"])  # NVIDIA proprietary license
load(
    "@rules_ml_toolchain//third_party/gpus:nvidia_common_rules.bzl",
    "cuda_lib_header_prefix"
)
load("@cuda_cudart//:version.bzl", _cudart_version = "VERSION")

#cc_library(
#    name = "headers",
#    hdrs = glob([
#        %{comment}"include" + cuda_lib_header_prefix(_cudart_version, 13, "/cccl", "") + "/cub/**",
#        %{comment}"include" + cuda_lib_header_prefix(_cudart_version, 13, "/cccl", "") + "/cuda/**",
#        %{comment}"include" + cuda_lib_header_prefix(_cudart_version, 13, "/cccl", "") + "/nv/**",
#        %{comment}"include" + cuda_lib_header_prefix(_cudart_version, 13, "/cccl", "") + "/thrust/**",
#    ]),
#    include_prefix = "third_party/gpus/cuda/include",
#    includes = ["include" + cuda_lib_header_prefix(_cudart_version, 13, "/cccl", "")],
#    strip_include_prefix = "include" + cuda_lib_header_prefix(_cudart_version, 13, "/cccl", ""),
#    visibility = ["@local_config_cuda//cuda:__pkg__"],
#)

cc_library(
    name = "headers",
    deps = [":thrust_headers",":nv_headers", ":cuda_headers", ":cub_headers"],
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

cc_library(
    name = "thrust_headers",
    hdrs = glob([
        %{comment}"thrust/thrust/**",
    ]),
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["thrust"],
    strip_include_prefix = "thrust",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

cc_library(
    name = "cuda_headers",
    hdrs = glob([
        %{comment}"libcudacxx/include/cuda/**",
    ]),
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["libcudacxx/include"],
    strip_include_prefix = "libcudacxx/include",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

cc_library(
    name = "nv_headers",
    hdrs = glob([
        %{comment}"libcudacxx/include/nv/**",
    ]),
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["libcudacxx/include/nv"],
    strip_include_prefix = "libcudacxx/include",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

cc_library(
    name = "cub_headers",
    hdrs = glob([
        %{comment}"cub/cub/**",
    ]),
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["cub"],
    strip_include_prefix = "cub",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)
