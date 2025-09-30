"""Module extension for nccl_configure."""

load(
    "//gpu/nccl:nccl_configure.bzl",
    "nccl_configure",
)

nccl_configure_ext = module_extension(
    implementation = lambda mctx: nccl_configure(name = "local_config_nccl"),
)
