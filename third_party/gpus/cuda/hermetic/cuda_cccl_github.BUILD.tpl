licenses(["restricted"])  # NVIDIA proprietary license

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
