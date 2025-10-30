licenses(["restricted"])  # NVIDIA proprietary license
load(
    "@local_config_cuda//cuda:build_defs.bzl",
    "if_cuda_newer_than",
    "if_static_nvrtc",
)
load(
    "@rules_ml_toolchain//third_party/gpus:nvidia_common_rules.bzl",
    "cuda_rpath_flags",
)

%{multiline_comment}
cc_import(
    name = "nvrtc_main",
    hdrs = [":headers"],
    shared_library = "lib/libnvrtc.so.%{libnvrtc_version}",
)

cc_import(
    name = "nvrtc_builtins",
    hdrs = [":headers"],
    shared_library = "lib/libnvrtc-builtins.so.%{libnvrtc-builtins_version}",
)

cc_import(
    name = "nvrtc_builtins_static_alt",
    static_library = "lib/libnvrtc-builtins_static.alt.a",
)

cc_import(
    name = "nvrtc_static",
    static_library = "lib/libnvrtc_static.a",
)

cc_import(
    name = "nvrtc_builtins_static",
    static_library = "lib/libnvrtc-builtins_static.a",
)

cc_import(
    name = "nvrtc_static_alt",
    static_library = "lib/libnvrtc_static.alt.a",
)
%{multiline_comment}
cc_library(
    name = "nvrtc",
    %{comment}deps = if_static_nvrtc([
        %{comment}":nvrtc_static",
        %{comment}":nvrtc_builtins_static",
        %{comment}"@cuda_nvcc//:nvptxcompiler",
    %{comment}],
    %{comment}[
        %{comment}":nvrtc_main",
        %{comment}":nvrtc_builtins",
    %{comment}]),
    %{comment}linkopts = if_cuda_newer_than(
        %{comment}"13_0",
        %{comment}if_true = cuda_rpath_flags("nvidia/cu13/lib"),
        %{comment}if_false = cuda_rpath_flags("nvidia/cuda_nvrtc/lib"),
    %{comment}),
    visibility = ["//visibility:public"],
)

cc_library(
    name = "headers",
    %{comment}hdrs = [
        %{comment}"include/nvrtc.h",
    %{comment}],
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["include"],
    strip_include_prefix = "include",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)
