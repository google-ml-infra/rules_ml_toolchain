licenses(["restricted"])  # NVIDIA proprietary license
load(
     "@local_config_cuda//cuda:build_defs.bzl",
     "if_static_cuda",
)
load(
    "@rules_ml_toolchain//third_party/gpus:nvidia_common_rules.bzl",
    "cuda_rpath_flags",
)

%{multiline_comment}
cc_import( 
    name = "cudnn_ops",
    hdrs = [":headers"],
    shared_library = "lib/libcudnn_ops.so.%{libcudnn_ops_version}",
)

cc_import( 
    name = "cudnn_cnn",
    hdrs = [":headers"],
    shared_library = "lib/libcudnn_cnn.so.%{libcudnn_cnn_version}",
)

cc_import( 
    name = "cudnn_adv",
    hdrs = [":headers"],
    shared_library = "lib/libcudnn_adv.so.%{libcudnn_adv_version}",
)

cc_import( 
    name = "cudnn_graph",
    hdrs = [":headers"],
    shared_library = "lib/libcudnn_graph.so.%{libcudnn_graph_version}",
)

cc_import(
    name = "cudnn_engines_precompiled",
    hdrs = [":headers"],
    shared_library = "lib/libcudnn_engines_precompiled.so.%{libcudnn_engines_precompiled_version}",
)

cc_import(
    name = "cudnn_engines_runtime_compiled",
    hdrs = [":headers"],
    shared_library = "lib/libcudnn_engines_runtime_compiled.so.%{libcudnn_engines_runtime_compiled_version}",
)

cc_import(
    name = "cudnn_heuristic",
    hdrs = [":headers"],
    shared_library = "lib/libcudnn_heuristic.so.%{libcudnn_heuristic_version}",
)

cc_import(
    name = "cudnn_main",
    hdrs = [":headers"],
    shared_library = "lib/libcudnn.so.%{libcudnn_version}",
)

cc_import(
    name = "cudnn_graph_static",
    hdrs = [":headers"],
    static_library = "lib/libcudnn_graph_static_v9.a",
)

cc_import(
    name = "cudnn_adv_static",
    hdrs = [":headers"],
    static_library = "lib/libcudnn_adv_static_v9.a",
)

cc_import(
    name = "cudnn_engines_runtime_compiled_static",
    hdrs = [":headers"],
    static_library = "lib/libcudnn_engines_runtime_compiled_static_v9.a",
)

cc_import(
    name = "cudnn_engines_precompiled_static",
    hdrs = [":headers"],
    static_library = "lib/libcudnn_engines_precompiled_static_v9.a",
)

cc_import(
    name = "cudnn_ops_static",
    hdrs = [":headers"],
    static_library = "lib/libcudnn_ops_static_v9.a",
)

cc_import(
    name = "cudnn_heuristic_static",
    hdrs = [":headers"],
    static_library = "lib/libcudnn_heuristic_static_v9.a",
)

cc_import(
    name = "cudnn_cnn_static",
    hdrs = [":headers"],
    static_library = "lib/libcudnn_cnn_static_v9.a",
)
%{multiline_comment}
cc_library(
    name = "cudnn",
    %{comment}deps = if_static_cuda(
      %{comment}[":cudnn_engines_precompiled_static",
      %{comment}":cudnn_ops_static",
      %{comment}":cudnn_graph_static",
      %{comment}":cudnn_cnn_static",
      %{comment}":cudnn_adv_static",
      %{comment}":cudnn_engines_runtime_compiled_static",
      %{comment}":cudnn_heuristic_static",
      %{comment}],
      %{comment}[":cudnn_engines_precompiled",
      %{comment}":cudnn_ops",
      %{comment}":cudnn_graph",
      %{comment}":cudnn_cnn",
      %{comment}":cudnn_adv",
      %{comment}":cudnn_engines_runtime_compiled",
      %{comment}":cudnn_heuristic",
      %{comment}":cudnn_main",
    %{comment}]) + ["@cuda_nvrtc//:nvrtc"],
    %{comment}linkopts = cuda_rpath_flags("nvidia/cudnn/lib"),
    visibility = ["//visibility:public"],
)

cc_library(
    name = "headers",
    %{comment}hdrs = glob([
        %{comment}"include/cudnn*.h",
    %{comment}]),
    include_prefix = "third_party/gpus/cudnn",
    includes = ["include"],
    strip_include_prefix = "include",
    visibility = ["@local_config_cuda//cuda:__pkg__"],
)
