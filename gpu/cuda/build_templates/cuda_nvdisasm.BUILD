licenses(["restricted"])  # NVIDIA proprietary license

exports_files([
    "bin/nvdisasm",
])

filegroup(
    name = "nvdisasm",
    srcs = [
        "bin/nvdisasm",
    ],
    visibility = ["//visibility:public"],
    tags = [
        "cuda-only",
        "gpu",
    ],
)
