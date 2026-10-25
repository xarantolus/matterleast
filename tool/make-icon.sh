#!/usr/bin/env bash
# Renders the launcher icon layers in tool/icon/ to PNG and installs them as
# the Android icons (adaptive foreground/background, monochrome, legacy).
# Needs rsvg-convert (librsvg2-bin), present in the dev container image.
set -euo pipefail
cd "$(dirname "$0")/.."
for layer in foreground background monochrome; do
    rsvg-convert -w 432 -h 432 "tool/icon/$layer.svg" -o "assets/icon/$layer.png"
done
rsvg-convert -w 512 -h 512 tool/icon/legacy.svg -o assets/icon/legacy.png
dart run flutter_launcher_icons
