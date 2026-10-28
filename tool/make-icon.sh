#!/usr/bin/env bash
# Renders the launcher icon layers in tool/icon/ to PNG and installs them as
# the Android icons (adaptive foreground/background, monochrome, legacy) and
# the Windows icon of the exe, its window and the installer.
# Needs rsvg-convert (librsvg2-bin) and ImageMagick, present in the dev
# container image.
set -euo pipefail
cd "$(dirname "$0")/.."
for layer in foreground background monochrome; do
    rsvg-convert -w 432 -h 432 "tool/icon/$layer.svg" -o "assets/icon/$layer.png"
done
rsvg-convert -w 512 -h 512 tool/icon/legacy.svg -o assets/icon/legacy.png
dart run flutter_launcher_icons

# Each size rendered from the vector, not scaled down from the largest.
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
layers=()
for px in 16 24 32 48 64 128 256; do
    rsvg-convert -w "$px" -h "$px" tool/icon/legacy.svg -o "$work/$px.png"
    layers+=("$work/$px.png")
done
convert "${layers[@]}" windows/runner/resources/app_icon.ico
