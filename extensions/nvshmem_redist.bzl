"""Module extension for nvshmem_redist_init_repository."""

load(
    "//gpu/nvshmem:nvshmem_redist_init_repository.bzl",
    "nvshmem_redist_init_repository",
)

nvshmem_redist_ext = module_extension(
    implementation = lambda mctx: nvshmem_redist_init_repository(nvshmem_redistributions = {}),  # Generate repo `@nvidia_nvshmem`
)
