rocm_redist = {
    "rocm_7.12.0_gfx94X": struct(
        packages = [
            {
                "url": "https://repo.amd.com/rocm/tarball/therock-dist-linux-gfx94X-dcgpu-7.12.0.tar.gz",
                "sha256": "b88e1f167abe4cb3ab0d0c44431eed3ca1b77e1de6843e153c9ea6ac1e29f2f2",
            },
        ],
        required_softlinks = [],
        rocm_root = "",
    ),
}

def _parse_rocm_distro_links(distro_links):
    result = []
    if distro_links == "":
        return result

    for pair in distro_links.split(","):
        link = pair.split(":")
        result.append(struct(target = link[0], link = link[1]))
    return result

def create_rocm_distro(distro_url, distro_hash, symlinks):
    return struct(
        packages = [
            {
                "url": distro_url,
                "sha256": distro_hash,
            },
        ],
        required_softlinks = _parse_rocm_distro_links(symlinks),
        rocm_root = "",
    )
