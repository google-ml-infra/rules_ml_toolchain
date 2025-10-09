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
    name = "cusolver_shared_library",
    hdrs = [":headers"],
    shared_library = "lib/libcusolver.so.%{libcusolver_version}",
)

cc_import(
    name = "cusolver_lapack_static_library",
    hdrs = [":headers"],
    static_library = "lib/libcusolver_lapack_static.a",
)

cc_import(
    name = "cusolver_metis_static_library",
    hdrs = [":headers"],
    static_library = "lib/libcusolver_metis_static.a",
)

cc_import(
    name = "cusolver_static_library",
    hdrs = [":headers"],
    static_library = "lib/libcusolver_static.a",
)

cc_import(
    name = "metis_static_library",
    hdrs = [":headers"],
    static_library = "lib/libmetis_static.a",
)
%{multiline_comment}
cc_library(
    name = "cusolver",
    %{comment}deps = if_static_cuda([":cusolver_lapack_static_library", ":cusolver_static_library", ":cusolver_metis_static_library", ":metis_static_library"], [":cusolver_shared_library"])
    %{comment}+ [
        %{comment}"@cuda_nvjitlink//:nvjitlink",
        %{comment}"@cuda_cusparse//:cusparse",
        %{comment}"@cuda_cublas//:cublas",
        %{comment}"@cuda_cublas//:cublasLt",
    %{comment}],
    %{comment}linkopts = if_cuda_newer_than(
        %{comment}"13_0",
        %{comment}if_true = cuda_rpath_flags("nvidia/cu13/lib"),
        %{comment}if_false = cuda_rpath_flags("nvidia/cusolver/lib"),
    %{comment}),
    visibility = ["//visibility:public"],
)

cc_library(
    name = "headers",
    %{comment}hdrs = glob([
        %{comment}"include/cusolver*.h",
    %{comment}]),
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["include"],
    strip_include_prefix = "include",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)
