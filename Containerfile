FROM docker.io/nixos/nix:latest

# Keep the image minimal and rely on `nix run`/`nix shell` at runtime.
# Installing tools at image-build time can force expensive source builds
# under emulation, which is fragile on local container builders.
ENV NIX_CONFIG="experimental-features = nix-command flakes"

WORKDIR /work

CMD ["/bin/bash"]
