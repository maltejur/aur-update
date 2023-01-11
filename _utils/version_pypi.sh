#!/bin/sh
set -e

if [ $# -ne 1 ]; then
  echo "Usage: $0 <PROJECT_NAME>"
  exit 1
fi

curl -s \
  https://pypi.org/pypi/$1/json |
  jq -r '.info.version' |
  sed 's/^v//' |
  cat
