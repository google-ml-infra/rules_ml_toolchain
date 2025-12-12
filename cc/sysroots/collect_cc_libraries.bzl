# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================

def _collect_cc_libraries_impl(ctx):
    """
    Implementation function for the collect_cc_libraries rule. It extracts the libraries and other files
    from the CcInfo or DefaultInfo providers of the targets specified in 'deps'.
    """
    all_files = depset()

    for dep in ctx.attr.deps:
        dep_files = depset()

        if CcInfo in dep:
            cc_info = dep[CcInfo]
            if not cc_info.linking_context or not cc_info.linking_context.linker_inputs:
                continue

            for input in cc_info.linking_context.linker_inputs.to_list():
                for lib in input.libraries:
                    # Check for PIC static library (.a) or dynamic library (.so)
                    if lib.pic_static_library:
                        dep_files = depset(transitive = [dep_files, depset([lib.pic_static_library])])
                    if lib.dynamic_library:
                        dep_files = depset(transitive = [dep_files, depset([lib.dynamic_library])])
        elif DefaultInfo in dep:
            dep_files = depset(transitive = [dep_files, dep[DefaultInfo].files])
        else:
            fail("The target '{}' must provide CcInfo or DefaultInfo.".format(dep.label))

        all_files = depset(transitive = [all_files, dep_files])

    # Return the files via the DefaultInfo provider, making them available
    # to other rules that depend on this one.
    return [
        DefaultInfo(files = all_files),
    ]

collect_cc_libraries = rule(
    implementation = _collect_cc_libraries_impl,
    doc = "Extracts libraries from a cc_import target.",
    attrs = {
        "deps": attr.label_list(
            mandatory = True,
            providers = [[CcInfo], [DefaultInfo]],
        ),
    },
)