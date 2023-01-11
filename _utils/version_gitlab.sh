#!/bin/sh
set -e

if [ $# -ne 1 ]; then
  echo "Usage: $0 <GL_PROJECT_ID>"
  exit 1
fi

curl -s https://gitlab.com/api/v4/projects/$1/repository/tags |
  jq -r '.[0].name' |
  sed 's/^v//' |
  cat
