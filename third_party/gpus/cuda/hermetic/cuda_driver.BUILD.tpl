load("@bazel_skylib//rules:common_settings.bzl", "bool_flag")
load("@local_config_cuda//cuda:build_defs.bzl", "if_cuda_is_configured")

licenses(["restricted"])  # NVIDIA proprietary license

%{multiline_comment}
cc_import(
    name = "driver_shared_library",
    shared_library = "lib/libcuda.so.%{libcuda_version}",
)

cc_import(
    name = "nvidia-ptxjitcompiler_shared_library",
    shared_library = "lib/libnvidia-ptxjitcompiler.so.%{libnvidia-ptxjitcompiler_version}",
)

cc_import(
    name = "libcuda_so_1",
    shared_library = "lib/libcuda.so.1",
)

cc_import(
    name = "libnvidia-ptxjitcompiler_so_1",
    shared_library = "lib/libnvidia-ptxjitcompiler.so.1",
)

# Workaround for adding path of library symlink to RPATH of cc_binaries.
cc_import(
    name = "libcuda_so",
    shared_library = "lib/libcuda.so",
)

# Workaround for adding unversioned library to NEEDED section of cc_binaries.
genrule(
    name = "fake_libcuda_cc",
    outs = ["libcuda.cc"],
    cmd = "echo '' > $@",
)

cc_binary(
    name = "fake_libcuda_binary",
    srcs = [":fake_libcuda_cc"],
    linkopts = ["-Wl,-soname,libcuda.so"],
    linkshared = True,
)

cc_import(
    name = "fake_libcuda",
    shared_library = ":fake_libcuda_binary",
)
%{multiline_comment}

cc_library(
    name = "nvidia_driver",
    %{comment}deps = [
        %{comment}":libcuda_so",
        %{comment}":fake_libcuda",
        %{comment}":libcuda_so_1",
        %{comment}":driver_shared_library",
    %{comment}],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "nvidia_ptxjitcompiler",
    %{comment}deps = [
        %{comment}":libnvidia-ptxjitcompiler_so_1",
        %{comment}":nvidia-ptxjitcompiler_shared_library",
    %{comment}],
    visibility = ["//visibility:public"],
)

# Flag indicating whether we should use hermetic user mode driver.
bool_flag(
    name = "include_cuda_umd_libs",
    build_setting_default = if_cuda_is_configured(True, False),
    visibility = ["//visibility:public"],
)

config_setting(
    name = "cuda_umd_libs",
    flag_values = {":include_cuda_umd_libs": "True"},
)

# DEPRECATED: use the flag --@cuda_driver//:include_cuda_umd_libs instead
# See the instructions in the paragraph 5 of the doc
# https://github.com/google-ml-infra/rules_ml_toolchain/blob/main/gpu/README.md#configure-hermetic-cuda-cudnn-and-nccl
alias(
    name = "enable_forward_compatibility",
    actual = ":include_cuda_umd_libs",
)
