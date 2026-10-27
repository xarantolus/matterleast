#!/bin/sh
# Removes what install.sh put in place. The app's data (sign-ins, cache)
# stays; the keyring entries are the keyring's to delete.
set -eu

data=${XDG_DATA_HOME:-${HOME:?HOME is not set}/.local/share}

rm -rf -- "$data/matterleast"
rm -f -- "$data/applications/matterleast.desktop"
rm -f -- "$data/icons/hicolor/256x256/apps/io.github.xarantolus.matterleast.png"

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$data/applications" || true
fi

echo "Removed Matterleast"
