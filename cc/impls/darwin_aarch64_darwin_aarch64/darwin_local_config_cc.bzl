

def _darwin_local_config_cc_impl(rctx):
    rctx.template(
        "BUILD.bazel",
        rctx.attr._build_tpl,
        substitutions = {
            "%{SYSROOT}": rctx.attr.sysroot.name,
        },
    )

    wrappers_dir = rctx.path("wrappers")

    res_mkdir = rctx.execute(["mkdir", "-p", str(wrappers_dir)])
    if res_mkdir.return_code != 0:
        fail("Failed to create wrappers directory: %s" % res_mkdir.stderr)

    for file_label in rctx.attr._wrapper_files:
        src_path = rctx.path(file_label)
        dest_filename = file_label.name

        dest_path = str(wrappers_dir.get_child(dest_filename))

        result = rctx.execute(["cp", "-R", str(src_path), dest_path])
        if result.return_code != 0:
            fail("Failed to copy %s: %s" % (src_path, result.stderr))

darwin_local_config_cc = repository_rule(
    implementation = _darwin_local_config_cc_impl,
    attrs = {
        "sysroot": attr.label(default = "@sysroot_darwin_aarch64", mandatory = True),
        "_build_tpl": attr.label(default = "//cc/impls/darwin_aarch64_darwin_aarch64:BUILD.bazel.tpl"),
        "_wrapper_files": attr.label_list(
            allow_files = True,
            default = [
                Label("//cc/impls/darwin_aarch64_darwin_aarch64/wrappers:BUILD"),
                Label("//cc/impls/darwin_aarch64_darwin_aarch64/wrappers:ar"),
                Label("//cc/impls/darwin_aarch64_darwin_aarch64/wrappers:clang"),
                Label("//cc/impls/darwin_aarch64_darwin_aarch64/wrappers:clang++"),
                Label("//cc/impls/darwin_aarch64_darwin_aarch64/wrappers:idler"),
                Label("//cc/impls/darwin_aarch64_darwin_aarch64/wrappers:ld"),
            ],
        ),
    },
)