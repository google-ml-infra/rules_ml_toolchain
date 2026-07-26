load("@rules_cc//cc:defs.bzl", "cc_import", "cc_library")

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
    name = "nvfatbin_shared_library",
    hdrs = [":headers"],
    shared_library = "lib/libnvfatbin.so.%{libnvfatbin_version}",
)

cc_import(
    name = "nvfatbin_static_library",
    hdrs = [":headers"],
    static_library = "lib/libnvfatbin_static.a",
)
%{multiline_comment}

cc_library(
    name = "nvfatbin",
    %{comment}deps = if_static_cuda([":nvfatbin_static_library"], [":nvfatbin_shared_library"]),
    %{comment}linkopts = if_cuda_newer_than(
        %{comment}"13_0",
        %{comment}if_true = cuda_rpath_flags("nvidia/cu13/lib"),
        %{comment}if_false = cuda_rpath_flags("nvidia/cuda_nvfatbin/lib"),
    %{comment}),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "header_list",
    %{comment}srcs = ["include/nvFatbin.h"],
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

cc_library(
    name = "headers",
    %{comment}hdrs = [":header_list"],
    %{comment}includes = ["include"],
    %{comment}strip_include_prefix = "include",
)
