licenses(["restricted"])  # NVIDIA proprietary license
load(
    "@local_config_cuda//cuda:build_defs.bzl",
    "if_cuda_newer_than",
    "if_static_cuda",
)
load(
    "@rules_ml_toolchain//gpu:nvidia_common_rules.bzl",
    "cuda_rpath_flags",
)

%{multiline_comment}
cc_import(
    name = "cusparse_shared_library",
    hdrs = [":headers"],
    shared_library = "lib/libcusparse.so.%{libcusparse_version}",
)

cc_import(
    name = "cusparse_static_library",
    hdrs = [":headers"],
    static_library = "lib/libcusparse_static.a",
)
%{multiline_comment}
cc_library(
    name = "cusparse",
    %{comment}deps = if_static_cuda([":cusparse_static_library"], [":cusparse_shared_library"]) + ["@cuda_nvjitlink//:nvjitlink"],
    %{comment}linkopts = if_cuda_newer_than(
        %{comment}"13_0",
        %{comment}if_true = cuda_rpath_flags("nvidia/cu13/lib"),
        %{comment}if_false = cuda_rpath_flags("nvidia/cusparse/lib"),
    %{comment}),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "header_list",
    %{comment}srcs = ["include/cusparse.h"],
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
