#!/bin/sh
set -e

if [ $# -ne 2 ]; then
  echo "Usage: $0 <old_version> <new_version>"
  exit 1
fi

[ "$1" = "$2" ] && exit 1 || [ "$1" = "$(echo -e "$1\n$2" | sort -V | head -n1)" ]
