#!/bin/sh

if [ "$(uname -m)" == "aarch64" ]; then
  docker pull ghcr.io/menci/archlinuxarm:base-devel
  docker build --no-cache -f Dockerfile-arm -t maltejur/aur_update "$(dirname "$0")"
else
  docker pull archlinux:base-devel
  docker build --no-cache -t maltejur/aur_update "$(dirname "$0")"
fi
