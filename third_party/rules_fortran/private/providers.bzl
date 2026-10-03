"""Fortran providers."""

FortranInfo = provider(
    doc = """Provider for Fortran compilation information.
    
    This provider is used to propagate information about compiled Fortran
    code, including module files, object files, and transitive dependencies.
    """,
    fields = {
        "compile_flags": "list of compilation flags",
        "link_flags": "list of link flags",
        "module_map": "dict mapping module names to module files",
        "transitive_libraries": "depset of static library files (.a)",
        "transitive_modules": "depset of module files (.mod)",
        "transitive_objects": "depset of object files (.o)",
        "transitive_sources": "depset of source files (for building)",
    },
)

FortranToolchainInfo = provider(
    doc = "Information about the Fortran toolchain.",
    fields = {
        "all_files": "All toolchain files",
        "archiver": "The archiver executable (ar)",
        "compiler": "The Fortran compiler executable",
        "compiler_flags": "Default compiler flags",
        "linker": "The linker executable",
        "linker_flags": "Default linker flags",
        "module_flag_format": "Format string for module path flag (e.g., '-J{}', '-module {}')",
        "preprocessor_flag": "Flag to enable preprocessing (e.g., '-cpp', '-fpp')",
        "preprocessor_flags": "Default preprocessor flags (e.g., ['-D_OPENMP'])",
        "runtime_ccinfo": "CcInfo provider containing Fortran runtime libraries",
        "runtime_libraries": "flang/clang runtime libraries needed for C/Fortran interop",
        "supports_module_path": "Whether compiler supports -J flag for modules",
    },
)
