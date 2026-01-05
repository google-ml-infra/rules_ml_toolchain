licenses(["restricted"])  # NVIDIA proprietary license

filegroup(
    name = "header_list",
    %{comment}srcs = ["include/nvml.h"],
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

cc_library(
    name = "headers",
    hdrs = [":header_list"],
    include_prefix = "third_party/gpus/cuda/nvml/include",
    includes = ["include"],
    strip_include_prefix = "include",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

%{multiline_comment}
cc_import(
    name = "nvidia-ml_stub",
    interface_library = "lib/stubs/libnvidia-ml.so",
    system_provided = 1,
    visibility = ["@cuda_cudart//:__pkg__"],
)
%{multiline_comment}

cc_library(
    name = "nvml",
    %{comment}deps = [":nvidia-ml_stub"],
    visibility = ["//visibility:public"],
)
