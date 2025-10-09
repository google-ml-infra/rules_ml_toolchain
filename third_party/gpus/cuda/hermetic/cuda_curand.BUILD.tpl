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
    name = "curand_shared_library",
    hdrs = [":headers"],
    shared_library = "lib/libcurand.so.%{libcurand_version}",
)

cc_import(
    name = "curand_static_library",
    hdrs = [":headers"],
    static_library = "lib/libcurand_static.a",
)
%{multiline_comment}
cc_library(
    name = "curand",
    %{comment}deps = if_static_cuda([":curand_static_library"], [":curand_shared_library"]),
    %{comment}linkopts = if_cuda_newer_than(
        %{comment}"13_0",
        %{comment}if_true = cuda_rpath_flags("nvidia/cu13/lib"),
        %{comment}if_false = cuda_rpath_flags("nvidia/curand/lib"),
    %{comment}),
    visibility = ["//visibility:public"],
)

cc_library(
    name = "headers",
    %{comment}hdrs = glob(["include/curand*.h"]),
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["include"],
    strip_include_prefix = "include",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)
