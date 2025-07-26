load("@local_config_cuda//cuda:build_defs.bzl", "if_cuda", "if_cuda_hermetic_clang")
load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load("//third_party/rules_cc_toolchain:toolchain_config.bzl", "cc_toolchain_config")
load("//third_party/rules_cc_toolchain/features:cc_toolchain_import.bzl", "cc_toolchain_import")
load("//third_party/rules_cc_toolchain/features:features.bzl", "cc_toolchain_import_feature")

#---------------------------------------------------------------------------------------
# Tools: Linux x86_64, Sysroot: Linux x86_64, CUDA
#---------------------------------------------------------------------------------------

package(
    default_visibility = [
        "//cc:__pkg__",
    ],
)

CUDA_TOOLS = if_cuda_hermetic_clang(
    {
        "gcc": "wrappers/linux/clang",
        "cpp": "wrappers/linux/clang++",
        "ld": "wrappers/linux/ld",
        "ar": "wrappers/linux/ar",
        "gcov": "wrappers/linux/idler",
        "llvm-cov": "wrappers/linux/idler",
        "nm": "wrappers/linux/idler",
        "objdump": "wrappers/linux/idler",
        "strip": "wrappers/linux/idler",
    },
    {
        "gcc": "wrappers/linux/nvcc_wrapper",
        "cpp": "wrappers/linux/clang++",
        "ld": "wrappers/linux/ld",
        "ar": "wrappers/linux/ar",
        "gcov": "wrappers/linux/idler",
        "llvm-cov": "wrappers/linux/idler",
        "nm": "wrappers/linux/idler",
        "objdump": "wrappers/linux/idler",
        "strip": "wrappers/linux/idler",
    },
)

filegroup(
    name = "cuda_nvcc",
    srcs = if_cuda([
        "@cuda_nvcc//:bin",
        "@cuda_nvcc//:nvvm",
    ]),
)

alias(
    name = "cuda_nvcc_feature",
    actual = "@cuda_nvcc//:feature",
    visibility = ["//visibility:public"],
)

alias(
    name = "startup_libs",
    actual = "@sysroot_linux_x86_64//:startup_libs",
    visibility = ["//visibility:public"],
)

cc_toolchain_import_feature(
    name = "startup_libs_feature",
    enabled = True,
    toolchain_import = ":startup_libs",
)

# buildifier: leave-alone
cc_toolchain_import(
    name = "imports",
    deps = [
        "@rules_ml_toolchain//cc/cuda/clang:inject_cuda_runtime_wrapper",
        "@sysroot_linux_x86_64//:includes_c",
        "@llvm_linux_x86_64//:includes",
        "@sysroot_linux_x86_64//:includes_system",
        "@sysroot_linux_x86_64//:glibc",
        "@sysroot_linux_x86_64//:pthread",
        "@llvm_linux_x86_64//:libclang_rt",
    ],
    visibility = ["//visibility:public"],
)

cc_toolchain_import_feature(
    name = "imports_feature",
    enabled = True,
    toolchain_import = ":imports",
)

# buildifier: leave-alone
filegroup(
    name = "all_linux_x86_64_linux_x86_64",
    srcs = [
        ":cuda_nvcc",
        ":imports",
        "//cc/impls/cuda/wrappers:all",
        ":startup_libs",
        "@llvm_linux_x86_64//:all",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "compiler_linux_x86_64_linux_x86_64",
    srcs = [
        ":cuda_nvcc",
        ":imports",
        "//cc/impls/cuda/wrappers:all",
        "@llvm_linux_x86_64//:clang",
        "@llvm_linux_x86_64//:clang++",
        "@llvm_linux_x86_64//:distro_libs",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "linker_linux_x86_64_linux_x86_64",
    srcs = [
        ":compiler_linux_x86_64_linux_x86_64",
        ":cuda_nvcc",
        "//cc/impls/cuda/wrappers:all",
        "@llvm_linux_x86_64//:ld",
        ":startup_libs",
        "@llvm_linux_x86_64//:distro_libs",
    ],
)

# buildifier: leave-alone
filegroup(
    name = "ar_linux_x86_64_linux_x86_64",
    srcs = [
        ":cuda_nvcc",
        "//cc/impls/cuda/wrappers:all",
        "@llvm_linux_x86_64//:ar",
        "@llvm_linux_x86_64//:distro_libs",
    ],
)

cc_toolchain_config(
    name = "toolchain_config_linux_x86_64_linux_x86_64",
    archiver = "@llvm_linux_x86_64//:ar",
    c_compiler = "@llvm_linux_x86_64//:clang",
    cc_compiler = "@llvm_linux_x86_64//:clang++",
    compiler_features = [
        # Cuda features
        ":cuda_nvcc_feature",
        "//cc/cuda/features:hermetic",
        ":imports_feature",

        # Hermetic libraries feature required before import.
        "//third_party/rules_cc_toolchain/features:hermetic_libraries",

        # Toolchain configuration
        "//third_party/rules_cc_toolchain/features:warnings",
        "//third_party/rules_cc_toolchain/features:errors",
        "//third_party/rules_cc_toolchain/features:reproducible",
        "//third_party/rules_cc_toolchain/features:use_lld",
        "//cc/features:sysroot_linux_x86_64",
        ":startup_libs_feature",
        "//third_party/rules_cc_toolchain/features:coverage",

        # PIC / PIE flags
        "//third_party/rules_cc_toolchain/features:supports_pic",
        "//third_party/rules_cc_toolchain/features:position_independent_code",
        "//third_party/rules_cc_toolchain/features:position_independent_executable",

        # Optimization flags
        "//third_party/rules_cc_toolchain/features:garbage_collect_symbols",
        "//cc/features:constants_merge",
        "//cc/features:asserts_disable",
        "//third_party/rules_cc_toolchain/features:dbg",
        "//third_party/rules_cc_toolchain/features:opt",
        "//cc/features:detect_issues",
        #"//cc/features:detect_issues_ext",   # Non-hermetic builds don't include these flags

        # C++ standard configuration
        "//third_party/rules_cc_toolchain/features:c++11",
        "//third_party/rules_cc_toolchain/features:c++14",
        "//third_party/rules_cc_toolchain/features:c++17",

        #
        "//cc/features:allow_shlib_undefined",
        "//cc/features:supports_dynamic_linker",
        "//cc/features:supports_start_end_lib_feature",
    ],
    linker = "@llvm_linux_x86_64//:ld",
    target_cpu = "x86_64",
    target_system_name = "local",
    tool_paths = CUDA_TOOLS,
)

cc_toolchain(
    name = "toolchain_linux_x86_64_linux_x86_64_cuda",
    all_files = ":all_linux_x86_64_linux_x86_64",
    ar_files = ":ar_linux_x86_64_linux_x86_64",
    compiler_files = ":compiler_linux_x86_64_linux_x86_64",
    dwp_files = ":all_linux_x86_64_linux_x86_64",
    linker_files = ":linker_linux_x86_64_linux_x86_64",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 1,
    toolchain_config = ":toolchain_config_linux_x86_64_linux_x86_64",
    toolchain_identifier = "toolchain_linux_x86_64_linux_x86_64_id",
)
