#!/bin/sh
set -e

image="${namespace:-minidocks}/base"
versions="
3.18;3.18
3.18-build;3.18;build
3.19;3.19
3.19-build;3.19;build
3.20;3.20
3.20-build;3.20;build
edge;edge
edge-build;edge;build
build;3.20;build
latest;3.20
"

build() {
    IFS=" "
    docker buildx build $docker_opts --target="${3:-latest}" --build-arg version="$2" -t "$image:$1" "$(dirname $0)"
}

case "$1" in
    --versions) echo "$versions" | awk 'NF' | cut -d';' -f1;;
    '') echo "$versions" | grep -v "^$" | while read -r version; do IFS=';'; build $version; done;;
    *) args="$(echo "$versions" | grep -E "^$1(;|$)")"; if [ -n "$args" ]; then IFS=';'; build $args; else echo "Version $1 does not exist." >/dev/stderr; exit 1; fi
esac
