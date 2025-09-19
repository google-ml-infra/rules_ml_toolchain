"""Module extension for nccl_configure."""

load(
    "//gpu/nccl:nccl_configure.bzl",
    "nccl_configure",
)

def _nccl_configure_ext_impl(mctx):
    nccl_configure(name = "local_config_nccl")

nccl_configure_ext = module_extension(
    implementation = _nccl_configure_ext_impl,
)
