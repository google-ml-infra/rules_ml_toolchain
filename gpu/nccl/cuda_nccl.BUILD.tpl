load("@rules_cc//cc:defs.bzl", "cc_import", "cc_library")

licenses(["restricted"])  # NVIDIA proprietary license
load(
    "@rules_ml_toolchain//gpu:nvidia_common_rules.bzl",
    "cuda_rpath_flags",
)

exports_files([
    "version.txt",
])
%{multiline_comment}
cc_import(
    name = "nccl_shared_library",
    shared_library = "lib/libnccl.so.%{libnccl_version}",
    hdrs = [":headers"],
    deps = ["@local_config_cuda//cuda:cuda_headers", ":headers"],
)
%{multiline_comment}
cc_library(
    name = "nccl",
    hdrs = [":header_list"],
    %{comment}deps = [":nccl_shared_library"],
    %{comment}linkopts = cuda_rpath_flags("nvidia/nccl/lib"),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "header_list",
    # Older NCCL distributions (e.g., <= 2.27.7) only ship .h headers and do not
    # contain any .cuh files under include/, which fails in Bazel 8+ where
    # --incompatible_disallow_empty_glob is enabled by default.
    %{comment}srcs = glob(
        %{comment}[
            %{comment}"include/**/*.h",
            %{comment}"include/**/*.cuh",
        %{comment}],
        %{comment}allow_empty = True,
    %{comment}),
)

cc_library(
    name = "headers",
    hdrs = [":header_list"],
    include_prefix = "third_party/nccl",
    includes = ["include/"],
    strip_include_prefix = "include",
    visibility = ["//visibility:public"],
    deps = ["@local_config_cuda//cuda:cuda_headers"],
)
