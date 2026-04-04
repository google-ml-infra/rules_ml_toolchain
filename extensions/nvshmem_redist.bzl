"""Module extension for nvshmem_redist_init_repository."""

load(
    "@nvshmem_redist_json//:distributions.bzl",
    "NVSHMEM_REDISTRIBUTIONS",
)
load(
    "//gpu/nvshmem:nvshmem_redist_init_repository.bzl",
    "nvshmem_redist_init_repository",
)

def _nvshmem_redist_ext_impl(mctx):
    nvshmem_redist_init_repository(
        nvshmem_redistributions = NVSHMEM_REDISTRIBUTIONS,
    )

nvshmem_redist_ext = module_extension(
    implementation = _nvshmem_redist_ext_impl,
)
