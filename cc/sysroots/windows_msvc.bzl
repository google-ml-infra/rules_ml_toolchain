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
# ==============================================================================

"""Repository rule to discover host MSVC installation on Windows."""

def _get_SystemRoot(rctx):
    sysroot = rctx.getenv("SYSTEMROOT")
    if not sysroot:
        return "C:\\Windows"
    return sysroot

def _find_vc_path(rctx):
    """Find Visual C++ installation directory on the host Windows machine."""
    bazel_vc = rctx.getenv("BAZEL_VC")
    if bazel_vc and rctx.path(bazel_vc).exists:
        return bazel_vc

    bazel_vs = rctx.getenv("BAZEL_VS")
    if bazel_vs:
        vc_candidate = bazel_vs.rstrip("\\/") + "\\VC"
        if rctx.path(vc_candidate).exists:
            return vc_candidate

    program_files_dirs = []
    for env_var in ["ProgramFiles(x86)", "PROGRAMFILES(X86)", "ProgramFiles", "PROGRAMFILES"]:
        val = rctx.getenv(env_var)
        if val and val not in program_files_dirs:
            program_files_dirs.append(val)
    if not program_files_dirs:
        program_files_dirs = ["C:\\Program Files (x86)", "C:\\Program Files"]

    # 1. Try vswhere.exe
    for pf in program_files_dirs:
        vswhere = pf.rstrip("\\/") + "\\Microsoft Visual Studio\\Installer\\vswhere.exe"
        if rctx.path(vswhere).exists:
            for args in [
                [
                    vswhere,
                    "-products",
                    "*",
                    "-latest",
                    "-requires",
                    "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
                    "-property",
                    "installationPath",
                ],
                [
                    vswhere,
                    "-products",
                    "*",
                    "-latest",
                    "-property",
                    "installationPath",
                ],
            ]:
                res = rctx.execute(args)
                if res.return_code == 0 and res.stdout.strip():
                    install_dir = res.stdout.strip().splitlines()[-1].strip()
                    vc_dir = install_dir.rstrip("\\/") + "\\VC"
                    if rctx.path(vc_dir).exists:
                        return vc_dir

    # 2. Fallback to standard Visual Studio installation directories
    years = ["2022", "2019", "2017"]
    editions = ["Enterprise", "Professional", "Community", "BuildTools"]
    for pf in program_files_dirs:
        for year in years:
            for edition in editions:
                vc_dir = pf.rstrip("\\/") + "\\Microsoft Visual Studio\\" + year + "\\" + edition + "\\VC"
                if rctx.path(vc_dir).exists:
                    return vc_dir

    return ""

def _find_vcvarsall(rctx, vc_path):
    if not vc_path:
        return ""
    for rel in ["\\Auxiliary\\Build\\VCVARSALL.BAT", "\\VCVARSALL.BAT"]:
        candidate = vc_path.rstrip("\\/") + rel
        if rctx.path(candidate).exists:
            return candidate
    return ""

def _setup_msvc_env(rctx, vcvarsall):
    vcvars_args = ["amd64"]
    winsdk_ver = rctx.getenv("BAZEL_WINSDK_FULL_VERSION", "")
    if winsdk_ver:
        vcvars_args.append(winsdk_ver)
    vc_ver = rctx.getenv("BAZEL_VC_FULL_VERSION", "")
    if vc_ver:
        vcvars_args.append("-vcvars_ver=" + vc_ver)

    cmd = '"' + vcvarsall + '" ' + " ".join(vcvars_args)
    rctx.file(
        "get_msvc_env.bat",
        "@call " + cmd + " > NUL\n@set\n",
         True,
    )
    sysroot = _get_SystemRoot(rctx)
    cmd_exe = sysroot.rstrip("\\/") + "\\System32\\cmd.exe"
    if not rctx.path(cmd_exe).exists:
        cmd_exe = "cmd.exe"

    res = rctx.execute(
        [cmd_exe, "/c", "get_msvc_env.bat"],
        environment = {
            "PATH": sysroot + "\\System32;" + sysroot + ";" + sysroot + "\\System32\\Wbem",
            "SYSTEMROOT": sysroot,
            "SYSTEMDRIVE": rctx.getenv("SYSTEMDRIVE") or "C:",
            "TEMP": rctx.getenv("TEMP") or rctx.getenv("TMP") or "C:\\Temp",
            "TMP": rctx.getenv("TMP") or rctx.getenv("TEMP") or "C:\\Temp",
        },
    )
    if res.return_code != 0:
        fail("Failed to execute VCVARSALL.BAT (%s): %s" % (vcvarsall, res.stderr))

    env_map = {}
    for line in res.stdout.splitlines():
        if "=" in line:
            k, v = line.split("=", 1)
            env_map[k.upper()] = v.strip()
    return env_map

def _windows_msvc_impl(rctx):
    os_name = rctx.os.name.lower()

    msvc_path = "msvc_not_found"
    msvc_include = "msvc_not_found"
    msvc_lib = "msvc_not_found"
    msvc_tmp = "msvc_not_found"
    builtin_include_dirs = []

    if os_name.startswith("windows"):
        vc_path = _find_vc_path(rctx)
        if not vc_path:
            fail(
                "Visual C++ build tools were not found on the host machine. " +
                "Please install Visual Studio / Build Tools with C++ support or set BAZEL_VC.",
            )
        vcvarsall = _find_vcvarsall(rctx, vc_path)
        if not vcvarsall:
            fail("VCVARSALL.BAT was not found under '%s'." % vc_path)

        env_map = _setup_msvc_env(rctx, vcvarsall)
        msvc_path = env_map.get("PATH", "") or "msvc_not_found"
        msvc_include = env_map.get("INCLUDE", "") or "msvc_not_found"
        msvc_lib = env_map.get("LIB", "") or "msvc_not_found"
        msvc_tmp = env_map.get("TMP", env_map.get("TEMP", "C:\\Temp")) or "C:\\Temp"

        for inc in msvc_include.split(";"):
            inc_clean = inc.strip()
            if inc_clean and inc_clean != "msvc_not_found" and inc_clean not in builtin_include_dirs:
                builtin_include_dirs.append(inc_clean)

    rctx.file(
        "defs.bzl",
        content = """\
# Copyright 2026 Google LLC
# Generated by windows_msvc repository rule.

MSVC_ENV_PATH = {msvc_path}
MSVC_ENV_INCLUDE = {msvc_include}
MSVC_ENV_LIB = {msvc_lib}
MSVC_ENV_TMP = {msvc_tmp}
MSVC_CXX_BUILTIN_INCLUDE_DIRECTORIES = {builtin_include_dirs}
""".format(
            msvc_path = repr(msvc_path),
            msvc_include = repr(msvc_include),
            msvc_lib = repr(msvc_lib),
            msvc_tmp = repr(msvc_tmp),
            builtin_include_dirs = repr(builtin_include_dirs),
        ),
    )

    rctx.file(
        "BUILD.bazel",
        content = """\
# Copyright 2026 Google LLC
# Generated by windows_msvc repository rule.

package(default_visibility = ["//visibility:public"])

exports_files(["defs.bzl"])

filegroup(
    name = "sysroot",
    srcs = [],
)
""",
    )

windows_msvc = repository_rule(
    implementation = _windows_msvc_impl,
    local = True,
    environ = [
        "BAZEL_VC",
        "BAZEL_VC_FULL_VERSION",
        "BAZEL_VS",
        "BAZEL_WINSDK_FULL_VERSION",
        "ProgramFiles",
        "ProgramFiles(x86)",
        "PROGRAMFILES",
        "PROGRAMFILES(X86)",
        "SYSTEMDRIVE",
        "SYSTEMROOT",
        "TEMP",
        "TMP",
    ],
)
