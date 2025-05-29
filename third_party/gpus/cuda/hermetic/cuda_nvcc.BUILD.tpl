licenses(["restricted"])  # NVIDIA proprietary license

load(
    "@rules_ml_toolchain//cc_toolchain/cuda/features:cuda_nvcc_feature.bzl",
    "cuda_nvcc_feature",
)

exports_files([
    "bin/nvcc",
])

filegroup(
    name = "nvvm",
    srcs = [
        "nvvm/libdevice/libdevice.10.bc",
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
    visibility = ["@rules_ml_toolchain//cc_toolchain:__pkg__"],
)

cc_library(
    name = "headers",
    %{comment}hdrs = glob([
        %{comment}"include/crt/**",
        %{comment}"include/fatbinary_section.h",
        %{comment}"include/nvPTXCompiler.h",
    %{comment}]),
    include_prefix = "third_party/gpus/cuda/include",
    includes = ["include"],
    strip_include_prefix = "include",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)
