licenses(["restricted"])  # NVIDIA proprietary license

load("@local_config_cuda//cuda:build_defs.bzl", "if_cuda_newer_than")

%{multiline_comment}
cc_import(
    name = "nvptxcompiler_static_library",
    hdrs = ["include/nvPTXCompiler.h"],
    static_library = if_cuda_newer_than("13_0", "lib/libnvptxcompiler_static.a", None),
)
%{multiline_comment}

cc_library(
    name = "nvptxcompiler",
    %{comment}deps = [":nvptxcompiler_static_library"],
    visibility = ["//visibility:public"],
)

