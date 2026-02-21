"""Module extension for nvshmem_redist_init_repository."""

load(
    "//gpu/nvshmem:nvshmem_redist_init_repository.bzl",
    "nvshmem_redist_init_repository",
)
load(
    "@cuda_redist_json//:distributions.bzl",
    "CUDA_REDISTRIBUTIONS",
)

def _nvshmem_redist_ext_impl(mctx):
    nvshmem_redist_init_repository(
        nvshmem_redistributions = CUDA_REDISTRIBUTIONS,
    )

nvshmem_redist_ext = module_extension(
    implementation = _nvshmem_redist_ext_impl,
)
