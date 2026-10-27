#!/usr/bin/env bash
# Renders the unread badges for desktop: the tray icon with a dot
# (assets/icon/tray_unread.png) and the Windows taskbar overlays with the
# mention count (windows/runner/resources/badge_*.ico: 1-9 and 9+).
# Needs rsvg-convert and ImageMagick, present in the dev container image.
set -euo pipefail
cd "$(dirname "$0")/.."
rsvg-convert -w 512 -h 512 tool/icon/tray_unread.svg -o assets/icon/tray_unread.png
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
for label in 1 2 3 4 5 6 7 8 9 9+; do
    size=22
    [[ $label == 9+ ]] && size=15
    name=${label/+/_more}
    sed -e "s/LABEL/$label/" -e "s/SIZE/$size/" tool/icon/badge.svg >"$work/$name.svg"
    for px in 16 20 24 32 48; do
        rsvg-convert -w "$px" -h "$px" "$work/$name.svg" -o "$work/$name-$px.png"
    done
    convert "$work/$name"-{16,20,24,32,48}.png "windows/runner/resources/badge_$name.ico"
done
