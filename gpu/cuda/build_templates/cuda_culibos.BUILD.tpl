licenses(["restricted"])  # NVIDIA proprietary license

load("@local_config_cuda//cuda:build_defs.bzl", "if_cuda_newer_than")

%{multiline_comment}
cc_import(
    name = "culibos_static_library",
    static_library = if_cuda_newer_than("13_0", "lib/libculibos.a", None),
    visibility = ["//visibility:public"],
)
%{multiline_comment}
