#!/bin/bash
set -euo pipefail

wrapper_runfiles="${RUNFILES_DIR:-$0.runfiles}"
symbolizer=$(find -L "${wrapper_runfiles}" -path "*/llvm*/bin/llvm-symbolizer" -type f 2>/dev/null | head -n 1)

[ -z "${symbolizer}" ] && echo "Warning: llvm-symbolizer not found in runfiles" >&2

asan_opts="{ASAN_BASE_OPTIONS}"
[ -n "${symbolizer}" ] && asan_opts="${asan_opts:+${asan_opts}:}external_symbolizer_path=${symbolizer}"
export ASAN_OPTIONS="${ASAN_OPTIONS:-}${ASAN_OPTIONS:+:}${asan_opts}"

lsan_opts="{LSAN_BASE_OPTIONS}"
export LSAN_OPTIONS="${LSAN_OPTIONS:-}${LSAN_OPTIONS:+:}${lsan_opts}"

tsan_opts="{TSAN_BASE_OPTIONS}"
[ -n "${symbolizer}" ] && tsan_opts="${tsan_opts:+${tsan_opts}:}external_symbolizer_path=${symbolizer}"
export TSAN_OPTIONS="${TSAN_OPTIONS:-}${TSAN_OPTIONS:+:}${tsan_opts}"

echo "Sanitizer wrapper: wrapper_runfiles=${wrapper_runfiles}" >&2
echo "Sanitizer wrapper: about to execute: {RUN_UNDER_EXEC}" >&2
{RUN_UNDER_EXEC}
