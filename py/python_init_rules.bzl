"""Hermetic Python initialization. Consult the WORKSPACE on how to use it."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def python_init_rules():
    """Defines (doesn't setup) the rules_python repository."""

    http_archive(
        name = "rules_cc",
        urls = ["https://github.com/bazelbuild/rules_cc/archive/refs/tags/0.1.0.tar.gz"],
        strip_prefix = "rules_cc-0.1.0",
        sha256 = "4b12149a041ddfb8306a8fd0e904e39d673552ce82e4296e96fac9cbf0780e59",
    )

    http_archive(
        name = "com_google_protobuf",
        sha256 = "6e09bbc950ba60c3a7b30280210cd285af8d7d8ed5e0a6ed101c72aff22e8d88",
        strip_prefix = "protobuf-6.31.1",
        urls = ["https://github.com/protocolbuffers/protobuf/archive/refs/tags/v6.31.1.zip"],
        repo_mapping = {
            "@abseil-cpp": "@com_google_absl",
            "@protobuf_pip_deps": "@pypi",
        },
    )

    http_archive(
        name = "rules_python",
        sha256 = "fa7dd2c6b7d63b3585028dd8a90a6cf9db83c33b250959c2ee7b583a6c130e12",
        strip_prefix = "rules_python-1.6.0",
        urls = ["https://github.com/bazelbuild/rules_python/releases/download/1.6.0/rules_python-1.6.0.tar.gz"],
    )
