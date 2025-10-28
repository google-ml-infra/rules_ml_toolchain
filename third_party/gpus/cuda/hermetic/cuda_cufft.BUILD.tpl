licenses(["restricted"])  # NVIDIA proprietary license
load(
     "@local_config_cuda//cuda:build_defs.bzl",
     "if_cuda_newer_than",
     "if_static_cuda",
)
load(
    "@rules_ml_toolchain//third_party/gpus:nvidia_common_rules.bzl",
    "cuda_rpath_flags",
)

%{multiline_comment}
cc_import(
    name = "cufft_shared_library",
    hdrs = [":headers"],
    shared_library = "lib/libcufft.so.%{libcufft_version}",
)

cc_import(
    name = "cufft_static_library",
    hdrs = [":headers"],
    static_library = "lib/libcufft_static.a",
)

cc_import(
    name = "cufftw_static_library",
    hdrs = [":headers"],
    static_library = "lib/libcufftw_static.a",
)

cc_import(
    name = "cufft_static_nocallback_library",
    hdrs = [":headers"],
    static_library = if_cuda_newer_than("13_0", None, "lib/libcufft_static_nocallback.a"),
)
%{multiline_comment}
cc_library(
    name = "cufft",
    %{comment}deps = if_static_cuda(if_cuda_newer_than("13_0", [":cufft_static_library"], [":cufft_static_nocallback_library"]) + [":cufftw_static_library"], [":cufft_shared_library"]),
    %{comment}linkopts = if_cuda_newer_than(
        %{comment}"13_0",
        %{comment}if_true = cuda_rpath_flags("nvidia/cu13/lib"),
        %{comment}if_false = cuda_rpath_flags("nvidia/cufft/lib"),
    %{comment}) + if_static_cuda(["-Wl,--no-relax"]),
    visibility = ["//visibility:public"],
)

cc_library(
    name = "headers",
    %{comment}hdrs = glob([
        %{comment}"include/cudalibxt.h", 
        %{comment}"include/cufft*.h"
    %{comment}]),
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["include"],
    strip_include_prefix = "include",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)
