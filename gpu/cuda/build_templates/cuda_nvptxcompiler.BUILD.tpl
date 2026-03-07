licenses(["restricted"])  # NVIDIA proprietary license

load("@local_config_cuda//cuda:build_defs.bzl", "if_cuda_newer_than")

%{multiline_comment}
cc_import(
    name = "nvptxcompiler_static_library",
    hdrs = [":headers"],
    static_library = if_cuda_newer_than("13_0", "lib/libnvptxcompiler_static.a", None),
)
%{multiline_comment}

cc_library(
    name = "nvptxcompiler",
    %{comment}deps = [":nvptxcompiler_static_library"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "header_list",
    %{comment}srcs = [
        %{comment}"include/nvPTXCompiler.h",
    %{comment}],
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)

cc_library(
    name = "headers",
    hdrs = [":header_list"],
    includes = ["include"],
    strip_include_prefix = "include",
)