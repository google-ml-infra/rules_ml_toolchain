"""Module extension for SYCL."""

load("//gpu/sycl:sycl_init_repository.bzl", "sycl_init_repository")
load("//gpu/sycl:sycl_configure.bzl", "sycl_configure")

def _sycl_configure_impl(mctx):
    sycl_init_repository()
    sycl_configure(name = "local_config_sycl")

sycl_configure_ext = module_extension(
    implementation = _sycl_configure_impl,
)
