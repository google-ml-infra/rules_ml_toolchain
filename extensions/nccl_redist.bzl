"""Module extension for nccl_redist_init_repository."""

load(
    "//gpu/nccl:nccl_redist_init_repository.bzl",
    "nccl_redist_init_repository",
)

def _nccl_redist_ext_impl(mctx):
    nccl_redist_init_repository()

nccl_redist_ext = module_extension(
    implementation = lambda mctx: nccl_redist_init_repository(), # Generate repo `@cuda_nccl`
)
