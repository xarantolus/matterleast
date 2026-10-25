#!/usr/bin/env bash
# Regenerates lib/data/emoji/emoji_table.g.dart from Mattermost's emoji.json at
# the pinned tag in tool/api/server-version (bump that with tool/update-api.sh).
# Needs git and dart.
set -euo pipefail
cd "$(dirname "$0")/.."

read -r tag sha < tool/api/server-version

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

echo "==> fetching mattermost/mattermost at $tag"
git -c advice.detachedHead=false clone -q --depth 1 --branch "$tag" --filter=blob:none --sparse \
    https://github.com/mattermost/mattermost.git "$work/mm"
git -C "$work/mm" sparse-checkout set --no-cone /webapp/channels/src/utils/emoji.json >/dev/null
head=$(git -C "$work/mm" rev-parse HEAD)
if [ "$head" != "$sha" ]; then
    echo "tag $tag is at $head, expected $sha" >&2
    exit 1
fi

echo "==> generating"
dart run tool/gen_emoji.dart "$work/mm/webapp/channels/src/utils/emoji.json" "$tag"
dart format lib/data/emoji >/dev/null

echo "==> changes"
git diff --stat -- lib/data/emoji | tail -5
