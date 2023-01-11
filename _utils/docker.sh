#!/bin/bash
set -e

run_docker() {
  docker run --rm -v $(readlink -f .):/home/user/aur_update maltejur/aur_update "$@"
}
