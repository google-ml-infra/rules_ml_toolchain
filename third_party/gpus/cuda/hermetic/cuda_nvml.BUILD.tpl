licenses(["restricted"])  # NVIDIA proprietary license

cc_library(
    name = "headers",
    %{comment}hdrs = ["include/nvml.h"],
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
    visibility = ["//visibility:public"],
)
%{multiline_comment}

