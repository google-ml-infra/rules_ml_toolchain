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
    visibility = ["//visibility:public"],
)

%{multiline_comment}
cc_import(
    name = "nvshmem_host_shared_library",
    hdrs = [":headers"],
    shared_library = "lib/libnvshmem_host.so.%{libnvshmem_host_version}",
)

cc_import(
    name = "nvshmem_bootstrap_uid_shared_library",
    hdrs = [":headers"],
    shared_library = "lib/nvshmem_bootstrap_uid.so.%{nvshmem_bootstrap_uid_version}",
)

cc_import(
    name = "nvshmem_transport_ibrc_shared_library",
    hdrs = [":headers"],
    shared_library = "lib/nvshmem_transport_ibrc.so.%{nvshmem_transport_ibrc_version}",
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
    visibility = ["//visibility:public"],
)
