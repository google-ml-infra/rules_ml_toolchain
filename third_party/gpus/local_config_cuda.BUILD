load("@bazel_skylib//rules:common_settings.bzl", "string_flag")

package(default_visibility = ["//visibility:public"])

# Build flag to select CUDA compiler.
#
# Set with '--@local_config_cuda//:cuda_compiler=...', or indirectly with
# ./configure, '--config=cuda' or '--config=cuda_clang'.
string_flag(
    name = "cuda_compiler",
    build_setting_default = "nvcc",
    values = [
        "clang",
        "nvcc",
    ],
)

# Config setting whether CUDA device code should be compiled with clang.
config_setting(
    name = "is_cuda_compiler_clang",
    flag_values = {":cuda_compiler": "clang"},
)

# Config setting whether CUDA device code should be compiled with nvcc.
config_setting(
    name = "is_cuda_compiler_nvcc",
    flag_values = {":cuda_compiler": "nvcc"},
)

# CUDA flag aliases for backward compatibility.
# Use flags from --@rules_ml_toolchain//common:* instead.

# Deprecated: Please use --@rules_ml_toolchain//common:enable_cuda instead
alias(
    name = "enable_cuda",
    actual = "@rules_ml_toolchain//common:enable_cuda",
)

# Deprecated: Please use --@rules_ml_toolchain//common:is_cuda_enabled instead
alias(
    name = "is_cuda_enabled",
    actual = "@rules_ml_toolchain//common:is_cuda_enabled",
)

# Deprecated: Please use --@rules_ml_toolchain//common:is_cuda_disabled instead
alias(
    name = "is_cuda_disabled",
    actual = "@rules_ml_toolchain//common:is_cuda_disabled",
)
