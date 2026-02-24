set shell := ["bash", "-euo", "pipefail", "-c"]

default:
  @just --list

_run task:
  @if command -v {{task}} >/dev/null 2>&1; then {{task}}; else nix develop "path:$PWD#ci" -c {{task}}; fi

fmt-check:
  @just _run fmt-check

lint:
  @just _run lint

check:
  @just _run check

eval:
  @just _run eval

fix:
  @just _run fix

ci:
  @just _run ci

cache-targets-linux:
  @just _run cache-targets-linux

cache-targets-macos:
  @just _run cache-targets-macos

ubuntu-build-aurora:
  @just _run ubuntu-build-aurora

lock-verify:
  @before=$$(shasum flake.lock | cut -d' ' -f1); \
  nix flake lock --no-update-lock-file; \
  after=$$(shasum flake.lock | cut -d' ' -f1); \
  test "$$before" = "$$after"

lock-sync:
  @nix flake lock

lock-update input:
  @nix flake update --update-input {{input}}
