"""Module extension for nvshmem_redist_json."""

load(
    "//gpu/nvshmem:nvshmem_json_init_repository.bzl",
    "nvshmem_json_init_repository",
)

nvshmem_json_ext = module_extension(
    implementation = lambda mctx: nvshmem_json_init_repository(),  # Generate `@nvshmem_redist_json`
)
