licenses(["restricted"])  # NVIDIA proprietary license

filegroup(
    name = "header_list",
    %{comment}srcs = glob(["include/**"]),
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
