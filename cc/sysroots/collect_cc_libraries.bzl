# Load the CcInfo provider which holds C++ specific dependency information.
# This is often needed to correctly interact with C++ rules.
#load("@bazel_tools//tools/cpp:cc_info.bzl", "CcInfo")

def _collect_cc_libraries_impl(ctx):
    """
    Implementation function for the collect_cc_import_libraries rule.
    It extracts the libraries from the CcInfo provider of the target specified in 'deps'.
    """

    libs = []
    all_library_files = depset()

    for dep in ctx.attr.deps:

        if not CcInfo in dep:
            fail("The target '{}' must provide CcInfo.".format(dep.label))

        cc_info = dep[CcInfo]
        if not cc_info.linking_context or not cc_info.linking_context.linker_inputs:
            continue

        for input in cc_info.linking_context.linker_inputs.to_list():
            for lib in input.libraries:
                # Check for PIC static library (.a) or dynamic library (.so)
                if lib.pic_static_library:
                    libs.append(lib.pic_static_library)
                if lib.dynamic_library:
                    #print("_collect_cc_libraries_impl: lib.dynamic_library: ", lib.dynamic_library)
                    libs.append(lib.dynamic_library)

    # Return the files via the DefaultInfo provider, making them available
    # to other rules that depend on this one.
    return [
        DefaultInfo(files = depset(libs, transitive = [depset()])),
    ]

collect_cc_libraries = rule(
    implementation = _collect_cc_libraries_impl,
    doc = "Extracts libraries from a cc_import target.",
    attrs = {
        "deps": attr.label_list(
            mandatory = True,
            providers = [CcInfo],
        ),
    },
)