load("@bazel_skylib//rules:common_settings.bzl", "bool_flag")

licenses(["restricted"])  # NVIDIA proprietary license

%{multiline_comment}
cc_import(
    name = "driver_shared_library",
    shared_library = "lib/libcuda.so.%{libcuda_version}",
)

cc_import(
    name = "nvidia-ml_shared_library",
    shared_library = "lib/libnvidia-ml.so.%{libnvidia-ml_version}",
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
    name = "libnvidia-ml_so_1",
    shared_library = "lib/libnvidia-ml.so.1",
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

cc_import(
    name = "libnvidia-ml_so",
    shared_library = "lib/libnvidia-ml.so",
)

cc_import(
    name = "libnvidia-ptxjitcompiler_so",
    shared_library = "lib/libnvidia-ptxjitcompiler.so",
)

# Workaround for adding unversioned library to NEEDED section of cc_binaries.
genrule(
    name = "fake_libcuda_cc",
    outs = ["libcuda.cc"],
    cmd = "echo '' > $@",
)

genrule(
    name = "fake_libnvidia-ml_cc",
    outs = ["libnvidia-ml.cc"],
    cmd = "echo '' > $@",
)

genrule(
    name = "fake_libnvidia-ptxjitcompiler_cc",
    outs = ["libnvidia-ptxjitcompiler.cc"],
    cmd = "echo '' > $@",
)

cc_binary(
    name = "fake_libcuda_binary",
    srcs = [":fake_libcuda_cc"],
    linkopts = ["-Wl,-soname,libcuda.so"],
    linkshared = True,
)

cc_binary(
    name = "fake_libnvidia-ml_binary",
    srcs = [":fake_libnvidia-ml_cc"],
    linkopts = ["-Wl,-soname,libnvidia-ml.so"],
    linkshared = True,
)

cc_binary(
    name = "fake_libnvidia-ptxjitcompiler_binary",
    srcs = [":fake_libnvidia-ptxjitcompiler_cc"],
    linkopts = ["-Wl,-soname,libnvidia-ptxjitcompiler.so"],
    linkshared = True,
)

cc_import(
    name = "fake_libcuda",
    shared_library = ":fake_libcuda_binary",
)

cc_import(
    name = "fake_libnvidia-ml",
    shared_library = ":fake_libnvidia-ml_binary",
)

cc_import(
    name = "fake_libnvidia-ptxjitcompiler",
    shared_library = ":fake_libnvidia-ptxjitcompiler_binary",
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
    name = "nvidia_ml",
    %{comment}deps = [
        %{comment}":libnvidia-ml_so",
        %{comment}":fake_libnvidia-ml",
        %{comment}":libnvidia-ml_so_1",
        %{comment}":nvidia-ml_shared_library",
    %{comment}],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "nvidia_ptxjitcompiler",
    %{comment}deps = [
        %{comment}":libnvidia-ptxjitcompiler_so",
        %{comment}":fake_libnvidia-ptxjitcompiler",
        %{comment}":libnvidia-ptxjitcompiler_so_1",
        %{comment}":nvidia-ptxjitcompiler_shared_library",
    %{comment}],
    visibility = ["//visibility:public"],
)

# Flag indicating if we should enable forward compatibility.
bool_flag(
    name = "enable_forward_compatibility",
    build_setting_default = False,
)

config_setting(
    name = "forward_compatibility",
    flag_values = {":enable_forward_compatibility": "True"},
)
