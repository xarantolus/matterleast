#!/bin/sh
# Installs Matterleast for the current user, without root: the app under
# $XDG_DATA_HOME/matterleast, its launcher entry and icon, and the mmauth://
# handler that single sign-on needs. uninstall.sh removes exactly these.
set -eu

here=$(cd "$(dirname "$0")" && pwd)
data=${XDG_DATA_HOME:-${HOME:?HOME is not set}/.local/share}
app=$data/matterleast
entry=$data/applications/matterleast.desktop
icon=$data/icons/hicolor/256x256/apps/io.github.xarantolus.matterleast.png

case $app in
*[\"\\\$\`]* | *"
"*)
    echo "install: the path $app has characters a launcher entry can't hold" >&2
    exit 1
    ;;
esac

if [ "$here" != "$app" ]; then
    rm -rf -- "$app"
    mkdir -p -- "$app"
    cp -R -- "$here/." "$app/"
fi

mkdir -p -- "$data/applications" "$(dirname -- "$icon")"
cp -- "$here/matterleast.png" "$icon"
while IFS= read -r line; do
    case $line in
    Exec=*) printf 'Exec="%s/matterleast" %%u\n' "$app" ;;
    *) printf '%s\n' "$line" ;;
    esac
done <"$here/matterleast.desktop" >"$entry"

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$data/applications" || true
fi
if command -v xdg-mime >/dev/null 2>&1; then
    xdg-mime default matterleast.desktop x-scheme-handler/mmauth || true
fi

echo "Installed Matterleast in $app"
