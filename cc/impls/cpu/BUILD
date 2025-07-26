load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load("//third_party/rules_cc_toolchain:toolchain_config.bzl", "cc_toolchain_config")

#=====================================================================
# Tools: Linux x86_64, Sysroot: Linux x86_64
#=====================================================================

cc_toolchain_config(
    name = "toolchain_config_linux_x86_64_linux_x86_64",
    archiver = "@llvm_linux_x86_64//:ar",
    c_compiler = "@llvm_linux_x86_64//:clang",
    cc_compiler = "@llvm_linux_x86_64//:clang++",
    compiler_features = [
        # Hermetic libraries feature required before import.
        "//third_party/rules_cc_toolchain/features:hermetic_libraries",
        "//cc/impls/cpu/linux_x86_64_linux_x86_64:imports_feature",

        # Toolchain configuration
        "//third_party/rules_cc_toolchain/features:warnings",
        "//third_party/rules_cc_toolchain/features:errors",
        "//third_party/rules_cc_toolchain/features:reproducible",
        "//third_party/rules_cc_toolchain/features:language",
        "//third_party/rules_cc_toolchain/features:use_lld",
        "//cc/features:sysroot_linux_x86_64",
        "//cc/impls/cpu/linux_x86_64_linux_x86_64:startup_libs_feature",
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
        "//cc/features:detect_issues_ext",

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
)

cc_toolchain(
    name = "toolchain_linux_x86_64_linux_x86_64",
    all_files = "//cc/impls/cpu/linux_x86_64_linux_x86_64:all",
    ar_files = "//cc/impls/cpu/linux_x86_64_linux_x86_64:ar",
    compiler_files = "//cc/impls/cpu/linux_x86_64_linux_x86_64:compiler",
    dwp_files = "//cc/impls/cpu/linux_x86_64_linux_x86_64:all",
    linker_files = "//cc/impls/cpu/linux_x86_64_linux_x86_64:linker",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 1,
    toolchain_config = ":toolchain_config_linux_x86_64_linux_x86_64",
    toolchain_identifier = "toolchain_linux_x86_64_linux_x86_64_id",
)

######################################################################
# Tools: Linux x86_64, Sysroot: Linux aarch64
######################################################################

cc_toolchain_config(
    name = "toolchain_config_linux_x86_64_linux_aarch64",
    archiver = "@llvm_linux_x86_64//:ar",
    c_compiler = "@llvm_linux_x86_64//:clang",
    cc_compiler = "@llvm_linux_x86_64//:clang++",
    compiler_features = [
        # Hermetic libraries feature required before import.
        "//third_party/rules_cc_toolchain/features:hermetic_libraries",
        "//cc/impls/cpu/linux_x86_64_linux_aarch64:imports_feature",

        # Toolchain configuration
        "//third_party/rules_cc_toolchain/features:warnings",
        "//third_party/rules_cc_toolchain/features:errors",
        "//third_party/rules_cc_toolchain/features:reproducible",
        "//third_party/rules_cc_toolchain/features:language",
        "//third_party/rules_cc_toolchain/features:use_lld",
        "//cc/features:sysroot_linux_aarch64",
        "//cc/impls/cpu/linux_x86_64_linux_aarch64:startup_libs_feature",
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
        "//cc/features:detect_issues_ext",

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
    target_cpu = "aarch64",
    target_system_name = "local",
)

cc_toolchain(
    name = "toolchain_linux_x86_64_linux_aarch64",
    all_files = "//cc/impls/cpu/linux_x86_64_linux_aarch64:all",
    ar_files = "//cc/impls/cpu/linux_x86_64_linux_aarch64:ar",
    compiler_files = "//cc/impls/cpu/linux_x86_64_linux_aarch64:compiler",
    dwp_files = "//cc/impls/cpu/linux_x86_64_linux_aarch64:all",
    linker_files = "//cc/impls/cpu/linux_x86_64_linux_aarch64:linker",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 1,
    toolchain_config = ":toolchain_config_linux_x86_64_linux_aarch64",
    toolchain_identifier = "toolchain_id_linux_x86_64_linux_aarch64",
)

######################################################################
# Tools: Linux x86_64, Sysroot: macOS aarch64
######################################################################

MAC_TOOLS = {
    "gcc": "wrappers/darwin/clang",
    "cpp": "wrappers/darwin/clang++",
    "ld": "wrappers/darwin/ld",
    "ar": "wrappers/darwin/ar",
    "gcov": "wrappers/darwin/idler",
    "llvm-cov": "wrappers/darwin/idler",
    "nm": "wrappers/darwin/idler",
    "objdump": "wrappers/darwin/idler",
    "strip": "wrappers/darwin/idler",
}

cc_toolchain_config(
    name = "toolchain_config_linux_x86_64_darwin_aarch64",
    archiver = "@llvm_linux_x86_64//:ar_darwin",
    c_compiler = "@llvm_linux_x86_64//:clang",
    cc_compiler = "@llvm_linux_x86_64//:clang++",
    compiler_features = [
        # Hermetic libraries feature required before import.
        "//third_party/rules_cc_toolchain/features:hermetic_libraries",
        "//cc/impls/cpu/linux_x86_64_darwin_aarch64:imports_feature",
        "//third_party/rules_cc_toolchain/features:undefined_symbols",

        # Toolchain configuration
        "//third_party/rules_cc_toolchain/features:warnings",
        "//third_party/rules_cc_toolchain/features:errors",
        "//third_party/rules_cc_toolchain/features:reproducible",
        "//third_party/rules_cc_toolchain/features:language",
        "//third_party/rules_cc_toolchain/features:use_lld",
        "//cc/features:sysroot_darwin_aarch64",
        "//third_party/rules_cc_toolchain/features:coverage",
        "//cc/features:max_install_names",
        "//cc/features:no_elaborated_enum_base",

        # PIC / PIE flags
        "//third_party/rules_cc_toolchain/features:supports_pic",
        "//third_party/rules_cc_toolchain/features:position_independent_code",

        # Optimization flags
        "//cc/features:garbage_collect_symbols_mac",
        "//cc/features:constants_merge",
        "//cc/features:asserts_disable",
        "//third_party/rules_cc_toolchain/features:dbg",
        "//third_party/rules_cc_toolchain/features:opt",
        "//cc/features:detect_issues",

        # C++ standard configuration
        "//third_party/rules_cc_toolchain/features:c++11",
        "//third_party/rules_cc_toolchain/features:c++14",
        "//third_party/rules_cc_toolchain/features:c++17",

        #
        # "//cc/features:allow_shlib_undefined",  # Instead of --allow-shlib-undefined, macOS uses the -undefined flag with dynamic_lookup as an argument.
        "//cc/features:supports_dynamic_linker",
        "//cc/features:supports_start_end_lib_feature",
    ],
    dynamic_library_extension = ".dylib",
    install_name = "@llvm_linux_x86_64//:install_name_tool_darwin",
    linker = "@llvm_linux_x86_64//:ld",
    target_cpu = "aarch64",
    target_libc = "macosx",
    target_system_name = "local",
    tool_paths = MAC_TOOLS,
)

cc_toolchain(
    name = "toolchain_linux_x86_64_darwin_aarch64",
    all_files = "//cc/impls/cpu/linux_x86_64_darwin_aarch64:all",
    ar_files = "//cc/impls/cpu/linux_x86_64_darwin_aarch64:ar",
    compiler_files = "//cc/impls/cpu/linux_x86_64_darwin_aarch64:compiler",
    dwp_files = "//cc/impls/cpu/linux_x86_64_darwin_aarch64:all",
    linker_files = "//cc/impls/cpu/linux_x86_64_darwin_aarch64:linker",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 1,
    toolchain_config = ":toolchain_config_linux_x86_64_darwin_aarch64",
    toolchain_identifier = "toolchain_id_linux_x86_64_darwin_aarch64",
)


######################################################################
# Tools: macOS aarch64, Sysroot: macOS aarch64
######################################################################

cc_toolchain_config(
    name = "toolchain_config_darwin_aarch64_darwin_aarch64",
    archiver = "@llvm_darwin_aarch64//:ar",
    c_compiler = "@llvm_darwin_aarch64//:clang",
    cc_compiler = "@llvm_darwin_aarch64//:clang++",
    compiler_features = [
        # Hermetic libraries feature required before import.
        "//third_party/rules_cc_toolchain/features:hermetic_libraries",
        "//cc/impls/cpu/darwin_aarch64_darwin_aarch64:imports_feature",
        "//third_party/rules_cc_toolchain/features:undefined_symbols",

        # Toolchain configuration
        "//third_party/rules_cc_toolchain/features:warnings",
        "//third_party/rules_cc_toolchain/features:errors",
        "//third_party/rules_cc_toolchain/features:reproducible",
        "//third_party/rules_cc_toolchain/features:language",
        "//third_party/rules_cc_toolchain/features:use_lld",
        "//cc/features:sysroot_darwin_aarch64",
        "//third_party/rules_cc_toolchain/features:coverage",
        "//cc/features:max_install_names",
        "//cc/features:no_elaborated_enum_base",

        # PIC / PIE flags
        "//third_party/rules_cc_toolchain/features:supports_pic",
        "//third_party/rules_cc_toolchain/features:position_independent_code",

        # Optimization flags
        "//cc/features:garbage_collect_symbols_mac",
        "//cc/features:constants_merge",
        "//cc/features:asserts_disable",
        "//third_party/rules_cc_toolchain/features:dbg",
        "//third_party/rules_cc_toolchain/features:opt",
        "//cc/features:detect_issues",

        # C++ standard configuration
        "//third_party/rules_cc_toolchain/features:c++11",
        "//third_party/rules_cc_toolchain/features:c++14",
        "//third_party/rules_cc_toolchain/features:c++17",

        #
        # "//cc/features:allow_shlib_undefined",  # Instead of --allow-shlib-undefined, macOS uses the -undefined flag with dynamic_lookup as an argument.
        "//cc/features:supports_dynamic_linker",
        "//cc/features:supports_start_end_lib_feature",
    ],
    dynamic_library_extension = ".dylib",
    install_name = "@llvm_darwin_aarch64//:install_name_tool_darwin",
    linker = "@llvm_darwin_aarch64//:ld",
    target_cpu = "aarch64",
    target_libc = "macosx",
    target_system_name = "local",
    tool_paths = MAC_TOOLS,
)

cc_toolchain(
    name = "toolchain_darwin_aarch64_darwin_aarch64",
    all_files = "//cc/impls/cpu/darwin_aarch64_darwin_aarch64:all",
    ar_files = "//cc/impls/cpu/darwin_aarch64_darwin_aarch64:ar",
    compiler_files = "//cc/impls/cpu/darwin_aarch64_darwin_aarch64:compiler",
    dwp_files = "//cc/impls/cpu/darwin_aarch64_darwin_aarch64:all",
    linker_files = "//cc/impls/cpu/darwin_aarch64_darwin_aarch64:linker",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 1,
    toolchain_config = ":toolchain_config_darwin_aarch64_darwin_aarch64",
    toolchain_identifier = "toolchain_id_darwin_aarch64_darwin_aarch64",
)
