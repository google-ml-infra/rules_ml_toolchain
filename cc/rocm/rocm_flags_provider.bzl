# Copyright 2026 Google LLC
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

"""Provider that exposes ROCm compiler flags from toolchain features."""

RocmFlagsInfo = provider(
    doc = "Provides ROCm compiler flags for rocm_compile rule",
    fields = {
        "compiler_flags": "List of compiler flags from ROCm toolchain features",
        "amdgpu_targets": "List of GPU architectures (e.g., gfx908)",
        "rocm_path": "Path to ROCm installation",
    },
)

def _rocm_flags_impl(ctx):
    """Aggregates all ROCm compiler flags from toolchain features."""
    compiler_flags = []

    # ROCm defines (from rocm_defines feature)
    compiler_flags.extend([
        "-DTENSORFLOW_USE_ROCM=1",
        "-D__HIP_PLATFORM_AMD__",
        "-DEIGEN_USE_HIP",
        "-DUSE_ROCM",
    ])

    # HIP includes (from rocm_hip_includes feature)
    # Note: -nohipinc is only understood by hipcc wrapper, not clang++ directly
    compiler_flags.extend([
        "-isystem", "external/config_rocm_hipcc/rocm/rocm_dist/lib/llvm/lib/clang/19/include",
        "-isystem", "external/config_rocm_hipcc/rocm/rocm_dist/include",
    ])

    # Warning flags (from rocm_warnings feature)
    compiler_flags.append("-Wno-unused-result")

    # PIC (from rocm_pic feature)
    compiler_flags.append("-fPIC")

    # ROCm hipcc feature flags
    # Note: --rocm-path will be added dynamically in rocm_compile based on sandbox path
    compiler_flags.extend([
        "-fno-gpu-rdc",
        "-fcuda-flush-denormals-to-zero",
        "--std=c++17",
    ])

    # GPU architectures
    for arch in ctx.attr.amdgpu_targets:
        compiler_flags.append("--offload-arch=" + arch)

    return [RocmFlagsInfo(
        compiler_flags = compiler_flags,
        amdgpu_targets = ctx.attr.amdgpu_targets,
        rocm_path = None,  # Will be determined at compile time from sandbox
    )]

rocm_flags = rule(
    implementation = _rocm_flags_impl,
    attrs = {
        "amdgpu_targets": attr.string_list(
            mandatory = True,
            doc = "List of GPU architectures",
        ),
    },
    provides = [RocmFlagsInfo],
)
