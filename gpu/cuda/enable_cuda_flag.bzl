
EnableCudaInfo = provider()

def _enable_cuda_flag_impl(ctx):
    value = ctx.build_setting_value
    if ctx.attr.enable_override:
        print(
            "\n\033[1;33mWarning:\033[0m '--define=using_cuda_nvcc' will be " +
            "unsupported soon. Use '--@local_config_cuda//:enable_cuda' " +
            "instead."
        )
        value = True
    return EnableCudaInfo(value = value)

enable_cuda_flag = rule(
    implementation = _enable_cuda_flag_impl,
    build_setting = config.bool(flag = True),
    attrs = {"enable_override": attr.bool()},
)
