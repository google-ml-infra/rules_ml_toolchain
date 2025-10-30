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
    name = "cublas_shared_library",
    hdrs = [":headers"],
    shared_library = "lib/libcublas.so.%{libcublas_version}",
)

cc_import(
    name = "cublasLt_shared_library",
    hdrs = [":headers"],
    shared_library = "lib/libcublasLt.so.%{libcublaslt_version}",
)

cc_import(
    name = "cublasLt_static_library",
    hdrs = [":headers"],
    static_library = "lib/libcublasLt_static.a",
)

cc_import(
    name = "cublas_static_library",
    hdrs = [":headers"],
    static_library = "lib/libcublas_static.a",
)
%{multiline_comment}
cc_library(
    name = "cublas",
    visibility = ["//visibility:public"],
    %{comment}deps = if_static_cuda(
        %{comment}[":cublas_static_library"],
        %{comment}[":cublas_shared_library"],
    %{comment}) + [":cublasLt"],
    %{comment}linkopts = if_cuda_newer_than(
        %{comment}"13_0",
        %{comment}if_true = cuda_rpath_flags("nvidia/cu13/lib"),
        %{comment}if_false = cuda_rpath_flags("nvidia/cublas/lib"),
    %{comment}),
)

cc_library(
    name = "cublasLt",
    visibility = ["//visibility:public"],
    %{comment}deps = if_static_cuda(
        %{comment}[":cublasLt_static_library"],
        %{comment}[":cublasLt_shared_library"],
    %{comment}),
    %{comment}linkopts = if_cuda_newer_than(
        %{comment}"13_0",
        %{comment}if_true = cuda_rpath_flags("nvidia/cu13/lib"),
        %{comment}if_false = cuda_rpath_flags("nvidia/cublas/lib"),
    %{comment}),
)

cc_library(
    name = "headers",
    %{comment}hdrs = [
        %{comment}"include/cublas.h",
        %{comment}"include/cublasLt.h",
        %{comment}"include/cublas_api.h",
        %{comment}"include/cublas_v2.h",
    %{comment}],
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["include"],
    strip_include_prefix = "include",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)
