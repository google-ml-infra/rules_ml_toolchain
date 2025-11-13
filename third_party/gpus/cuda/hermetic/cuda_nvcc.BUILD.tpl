licenses(["restricted"])  # NVIDIA proprietary license

load(
    "@local_config_cuda//cuda:build_defs.bzl",
    "if_static_cuda",
)
load(
    "@rules_ml_toolchain//cc/cuda/features:cuda_nvcc_feature.bzl",
    "cuda_nvcc_feature",
)
load("@local_config_cuda//cuda:build_defs.bzl", "if_cuda_newer_than")

exports_files([
    "bin/nvcc",
])

filegroup(
    name = "nvvm",
    srcs = ["nvvm/libdevice/libdevice.10.bc"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "nvdisasm",
    srcs = [
        "bin/nvdisasm",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "nvlink",
    srcs = [
        "bin/nvlink",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "fatbinary",
    srcs = [
        "bin/fatbinary",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "bin2c",
    srcs = [
        "bin/bin2c",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "ptxas",
    srcs = [
        "bin/ptxas",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "bin",
    srcs = glob([
        "bin/**",
        "nvvm/bin/**",
    ]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "link_stub",
    srcs = [
        "bin/crt/link.stub",
    ],
    visibility = ["//visibility:public"],
)

cuda_nvcc_feature(
    name = "feature",
    enabled = True,
    bin = ":bin/nvcc",
    version = "%{version_of_cuda}",
    visibility = [
        "@rules_ml_toolchain//cc/impls/linux_aarch64_linux_aarch64_cuda:__pkg__",
        "@rules_ml_toolchain//cc/impls/linux_x86_64_linux_x86_64_cuda:__pkg__",
    ],
)

%{multiline_comment}
cc_import(
    name = "nvptxcompiler_static_library",
    hdrs = [":headers"],
    static_library = if_cuda_newer_than("13_0", None, "lib/libnvptxcompiler_static.a"),
)
%{multiline_comment}

cc_library(
    name = "nvptxcompiler",
    %{comment}deps = if_static_cuda(if_cuda_newer_than(
        %{comment}"13_0",
        %{comment}["@cuda_nvptxcompiler//:nvptxcompiler"],
        %{comment}[":nvptxcompiler_static_library"],
    %{comment})),
    visibility = ["//visibility:public"],
)

cc_library(
    name = "headers",
    %{comment}hdrs = glob([
        %{comment}"include/fatbinary_section.h",
        %{comment}"include/nvPTXCompiler.h",
    %{comment}]) + if_cuda_newer_than(
        %{comment}"13_0",
        %{comment}if_true = [],
        %{comment}if_false = glob(["include/crt/**"]),
    %{comment}),
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["include"],
    strip_include_prefix = "include",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)
