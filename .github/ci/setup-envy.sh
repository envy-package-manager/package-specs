#!/usr/bin/env bash
# Put the envy that examples/envy.lua pins on PATH for the rest of the job, and
# point its cache at a fresh directory: a warm cache would hide an upstream
# artifact that moved or vanished.
set -Eeuo pipefail

version=$(sed -nE 's/^-- @envy version "([^"]+)".*/\1/p' examples/envy.lua)

case "$RUNNER_OS" in
  Linux) os=linux ;; macOS) os=darwin ;; Windows) os=windows ;;
esac
case "$RUNNER_ARCH" in
  X64) arch=x86_64 ;; ARM64) arch=arm64 ;;
esac
ext=$([[ "$os" == windows ]] && echo zip || echo tar.gz)

archive="$RUNNER_TEMP/envy.$ext"
dir="$RUNNER_TEMP/envy"
mkdir -p "$dir"

curl -fsSL --retry 3 -o "$archive" \
  "https://github.com/envy-package-manager/envy/releases/download/v$version/envy-$os-$arch.$ext"

if [[ "$ext" == zip ]]; then
  # Git Bash's tar is GNU tar, which reads no zip.
  pwsh -NoProfile -Command "Expand-Archive '$archive' '$dir'"
else
  tar -xzf "$archive" -C "$dir"
fi

export ENVY_CACHE_ROOT="$RUNNER_TEMP/envy-cache"
echo "ENVY_CACHE_ROOT=$ENVY_CACHE_ROOT" >> "$GITHUB_ENV"
echo "$dir" >> "$GITHUB_PATH"
"$dir/envy" --version
