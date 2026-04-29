"""Feature to use libstdc++ instead of libc++ for ROCm compatibility."""

load("@rules_cc//cc:cc_toolchain_config_lib.bzl", "flag_group", "flag_set", _feature = "feature")
load("@rules_cc//cc:action_names.bzl", "ALL_CPP_COMPILE_ACTION_NAMES", "ALL_CC_LINK_ACTION_NAMES")

def use_libstdcxx_feature():
    """Force use of libstdc++ instead of hermetic libc++."""
    return _feature(
        name = "use_libstdcxx",
        enabled = False,  # Enabled via --features=use_libstdcxx
        flag_sets = [
            flag_set(
                actions = ALL_CPP_COMPILE_ACTION_NAMES,
                flag_groups = [
                    flag_group(flags = ["-stdlib=libstdc++"]),
                ],
            ),
            flag_set(
                actions = ALL_CC_LINK_ACTION_NAMES,
                flag_groups = [
                    flag_group(flags = ["-stdlib=libstdc++"]),
                ],
            ),
        ],
    )
