licenses(["restricted"])  # NVIDIA proprietary license
load(
    "@rules_ml_toolchain//third_party/gpus:nvidia_common_rules.bzl",
    "cuda_rpath_flags",
)

%{multiline_comment}
cc_import(
    name = "cusparse_shared_library",
    hdrs = [":headers"],
    shared_library = "lib/libcusparse.so.%{libcusparse_version}",
    deps = ["@cuda_nvjitlink//:nvjitlink"],
)
%{multiline_comment}
cc_library(
    name = "cusparse",
    %{comment}deps = [":cusparse_shared_library"],
    %{comment}linkopts = cuda_rpath_flags("nvidia/cusparse/lib"),
    visibility = ["//visibility:public"],
)

cc_library(
    name = "headers",
    %{comment}hdrs = ["include/cusparse.h"],
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["include"],
    strip_include_prefix = "include",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)
