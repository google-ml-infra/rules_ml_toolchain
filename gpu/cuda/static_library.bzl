"""cc_import for NVIDIA static libraries that register constructors in .ctors."""

load("@rules_cc//cc:defs.bzl", "cc_import")

def cuda_static_import(name, static_library, **kwargs):
    """Like cc_import, but moves the archive's .ctors into .init_array first.

    ld.lld does not fold legacy .ctors sections into .init_array, so the
    constructors of these archives would never run. See
    //gpu/cuda/tools:ctors_to_init_array.

    Args:
      name: the cc_import's name.
      static_library: the archive, or None (then this is a plain cc_import).
      **kwargs: passed to cc_import.
    """
    if not static_library:
        cc_import(name = name, static_library = static_library, **kwargs)
        return
    converted = "{}/{}".format(name, static_library.rsplit("/", 1)[-1])
    native.genrule(
        name = name + "_init_array",
        srcs = [static_library],
        outs = [converted],
        tools = [Label("//gpu/cuda/tools:ctors_to_init_array")],
        cmd = "$(execpath {}) $< $@".format(Label("//gpu/cuda/tools:ctors_to_init_array")),
    )
    cc_import(name = name, static_library = converted, **kwargs)
