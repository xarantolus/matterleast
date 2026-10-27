#!/usr/bin/env bash
# Packs the Linux release bundle into matterleast-linux-x64.tar.gz with a
# top-level matterleast/ folder, the launcher entry template and the icon.
# Run after `flutter build linux --release`. CI and local checks use this
# one script.
#   tool/pack-linux.sh [output-directory]    (default: build/)
set -euo pipefail
cd "$(dirname "$0")/.."

out=${1:-build}
bundle=build/linux/x64/release/bundle
stage=$(mktemp -d)
trap 'rm -rf -- "$stage"' EXIT

[[ -x $bundle/matterleast ]] || { echo "pack: run flutter build linux --release first" >&2; exit 1; }
mkdir -p "$stage/matterleast" "$out"
cp -R "$bundle/." "$stage/matterleast/"
cp linux/matterleast.desktop linux/matterleast.png "$stage/matterleast/"
tar -C "$stage" --owner=0 --group=0 -czf "$out/matterleast-linux-x64.tar.gz" matterleast
sha256sum "$out/matterleast-linux-x64.tar.gz"
