licenses(["restricted"])  # NVIDIA proprietary license

filegroup(
    name = "header_list",
    srcs = [":thrust_header_list",":nv_header_list", ":cuda_header_list", ":cub_header_list"],
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

cc_library(
    name = "headers",
    deps = [":thrust_headers",":nv_headers", ":cuda_headers", ":cub_headers"],
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

filegroup(
    name = "thrust_header_list",
    srcs = glob([
        %{comment}"thrust/thrust/**",
    ], allow_empty = True),
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

cc_library(
    name = "thrust_headers",
    hdrs = [":thrust_header_list"],
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["thrust"],
    strip_include_prefix = "thrust",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

filegroup(
    name = "cuda_header_list",
    srcs = glob([
        %{comment}"libcudacxx/include/cuda/**",
    ], allow_empty = True),
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

cc_library(
    name = "cuda_headers",
    hdrs = [":cuda_header_list"],
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["libcudacxx/include"],
    strip_include_prefix = "libcudacxx/include",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

filegroup(
    name = "nv_header_list",
    srcs = glob([
        %{comment}"libcudacxx/include/nv/**",
    ], allow_empty = True),
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

cc_library(
    name = "nv_headers",
    hdrs = ["nv_header_list"],
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["libcudacxx/include/nv"],
    strip_include_prefix = "libcudacxx/include",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

filegroup(
    name = "cub_header_list",
    srcs = glob([
        %{comment}"cub/cub/**",
    ], allow_empty = True),
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

cc_library(
    name = "cub_headers",
    hdrs = [":cub_header_list"],
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["cub"],
    strip_include_prefix = "cub",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

