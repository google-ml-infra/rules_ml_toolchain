load("//gpu/cuda:enable_cuda_flag.bzl", "enable_cuda_flag")

package(default_visibility = ["//visibility:public"])

# Build flag to enable CUDA support.
#
# Enable with '--@local_config_cuda//:enable_cuda', or indirectly with
# ./configure or '--config=cuda'.
enable_cuda_flag(
    name = "enable_cuda",
    build_setting_default = False,
    enable_override = select({
        ":define_using_cuda_nvcc": True,
        "//conditions:default": False,
    }),
)

# Config setting to keep `--define=using_cuda_nvcc=true` working.
# TODO(b/174244321): Remove when downstream projects have been fixed, along
# with the enable_cuda_flag rule in cuda:build_defs.bzl.tpl.
config_setting(
    name = "define_using_cuda_nvcc",
    define_values = {"using_cuda_nvcc": "true"},
    visibility = ["//visibility:private"],
)

# Config setting whether CUDA support has been requested.
#
# Enable path: ./configure > --config=cuda (.tf_configure.bazelrc)
#     > --//tensorflow:enable_cuda (.bazelrc) > :is_cuda_enabled
config_setting(
    name = "is_cuda_enabled",
    flag_values = {":enable_cuda": "True"},
)

config_setting(
    name = "is_cuda_disabled",
    flag_values = {":enable_cuda": "False"},
)
