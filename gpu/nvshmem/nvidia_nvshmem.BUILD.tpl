load("@rules_cc//cc:defs.bzl", "cc_import", "cc_library")

licenses(["restricted"])  # NVIDIA proprietary license
load(
    "@rules_ml_toolchain//gpu:nvidia_common_rules.bzl",
    "cuda_rpath_flags",
)

filegroup(
    name = "libnvshmem_device",
    srcs = [
        "lib/libnvshmem_device.bc",
    ],
    tags = [
        "cuda-only",
        "gpu",
    ],
    visibility = ["//visibility:public"],
)

%{multiline_comment}
cc_import(
    name = "nvshmem_host_shared_library",
    hdrs = [":headers"],
    shared_library = "lib/libnvshmem_host.so.%{libnvshmem_host_version}",
    tags = [
        "cuda-only",
        "gpu",
    ],
)

cc_import(
    name = "nvshmem_bootstrap_uid_shared_library",
    hdrs = [":headers"],
    shared_library = "lib/nvshmem_bootstrap_uid.so.%{nvshmem_bootstrap_uid_version}",
    tags = [
        "cuda-only",
        "gpu",
    ],
)

cc_import(
    name = "nvshmem_transport_ibrc_shared_library",
    hdrs = [":headers"],
    shared_library = "lib/nvshmem_transport_ibrc.so.%{nvshmem_transport_ibrc_version}",
    tags = [
        "cuda-only",
        "gpu",
    ],
)
%{multiline_comment}
cc_library(
    name = "nvshmem",
    %{comment}deps = [
      %{comment}":nvshmem_host_shared_library",
      %{comment}":nvshmem_bootstrap_uid_shared_library",
      %{comment}":nvshmem_transport_ibrc_shared_library",
    %{comment}],
    %{comment}linkopts = cuda_rpath_flags("nvidia/nvshmem/lib"),
    tags = [
        "cuda-only",
        "gpu",
    ],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "headers",
    %{comment}hdrs = glob([
        %{comment}"include/**",
    %{comment}]),
    include_prefix = "third_party/nvshmem",
    includes = ["include"],
    strip_include_prefix = "include",
    tags = [
        "cuda-only",
        "gpu",
    ],
    visibility = ["//visibility:public"],
)
