"""Extension for local_sysroot_configure repository rule (bzlmod support)."""

load("//cc/sysroots:local_sysroot_configure.bzl", "local_sysroot_configure")

def _local_sysroot_ext_impl(module_ctx):
    """Extension implementation for local_sysroot_configure.

    Args:
        module_ctx: The module extension context.
    """
    # Create the local_sysroot_config repository
    local_sysroot_configure(name = "local_sysroot_config")

local_sysroot_ext = module_extension(
    implementation = _local_sysroot_ext_impl,
)
