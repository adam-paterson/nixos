FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    xz-utils \
  && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --uid 1000 nix \
  && mkdir -p /nix \
  && chown nix:nix /nix

USER nix
ENV USER=nix
ENV HOME=/home/nix
ENV PATH=/home/nix/.nix-profile/bin:/nix/var/nix/profiles/default/bin:${PATH}
ENV NIX_CONFIG="experimental-features = nix-command flakes"

RUN bash -lc "curl -L https://nixos.org/nix/install | sh -s -- --no-daemon"

WORKDIR /work

CMD ["bash"]
