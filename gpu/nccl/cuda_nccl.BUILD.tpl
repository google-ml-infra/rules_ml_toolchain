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
    %{comment}srcs = glob([
        %{comment}"include/nccl*.h",
    %{comment}]),
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
