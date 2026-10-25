#!/usr/bin/env bash
# Regenerates the REST client and models from the server's OpenAPI source at
# the pinned tag in tool/api/server-version. Pass a new tag (and optionally its
# commit) to bump. Needs git, node (npx) and dart.
#
#   tool/update-api.sh            # regenerate at the pinned version
#   tool/update-api.sh v12.1.0    # bump, then review the diff and commit
set -euo pipefail
cd "$(dirname "$0")/.."

read -r tag sha < tool/api/server-version
if [ $# -ge 1 ]; then
    tag=$1
    sha=${2:-}
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

echo "==> fetching mattermost/mattermost at $tag"
git clone -q --depth 1 --branch "$tag" --filter=blob:none --sparse \
    https://github.com/mattermost/mattermost.git "$work/mm"
git -C "$work/mm" sparse-checkout set --no-cone /api/Makefile /api/v4/source/ /server/public/model/ >/dev/null
head=$(git -C "$work/mm" rev-parse HEAD)
if [ -n "$sha" ] && [ "$head" != "$sha" ]; then
    echo "tag $tag is at $head, expected $sha" >&2
    exit 1
fi
echo "$tag $head" > tool/api/server-version

echo "==> bundling the spec in the order of api/Makefile"
src=$work/mm/api
files=$(grep -oE '^\s*@cat \$\(V4_SRC\)/[a-z_]+\.yaml >>' "$src/Makefile" \
    | sed -E 's/.*V4_SRC\)\/([a-z_]+\.yaml).*/\1/')
{
    cat "$src/v4/source/introduction.yaml"
    for f in $files; do cat "$src/v4/source/$f"; done
    cat "$src/v4/source/definitions.yaml"
} > "$work/bundled.yaml"

echo "==> applying tool/api/overlay.yaml"
npx -y openapi-format@1.33.8 "$work/bundled.yaml" \
    --overlayFile tool/api/overlay.yaml --no-sort -o "$work/patched.yaml" >/dev/null

echo "==> linting (errors fail the update)"
npx -y @redocly/cli@1 lint "$work/patched.yaml" --format summary

echo "==> preparing tool/api/spec.json"
dart run tool/api/prepare.dart "$work/patched.yaml" tool/api/spec.json

echo "==> drift against the Go models (report only)"
dart run tool/api/drift_report.dart tool/api/spec.json "$work/mm/server/public/model"

compose() {
    {
        cat tool/api/swagger_parser.base.yaml
        if [ -s "$1" ]; then sed 's/^/    /' "$1"; fi
        echo "  include_paths:"
        sed 's/^/    /' tool/api/include-paths.yaml
    } > tool/api/swagger_parser.yaml
}

echo "==> generating (pass 1: model list)"
compose /dev/null
rm -rf lib/api/generated
dart run swagger_parser -f tool/api/swagger_parser.yaml >/dev/null
dart run tool/api/lenient_models.dart lib/api/generated/models \
    lib/api/json/lenient_models.dart "$work/lenient_parsers.yaml"

echo "==> generating (pass 2: with lenient model parsers)"
compose "$work/lenient_parsers.yaml"
rm -rf lib/api/generated
dart run swagger_parser -f tool/api/swagger_parser.yaml | grep -E 'clients|files' || true
# No dynamic past the boundary.
find lib/api/generated -name '*.dart' ! -name '*.g.dart' -exec sed -i \
    's/Map<String, dynamic>/Map<String, Object?>/g; s/final dynamic /final Object? /g' {} +
dart run tool/api/lenient_models.dart lib/api/generated/models \
    lib/api/json/lenient_models.dart "$work/lenient_parsers.yaml" >/dev/null

echo "==> build_runner"
# No --build-filter: it deletes every generated file outside the filter.
dart run build_runner build --delete-conflicting-outputs 2>&1 \
    | grep -E '^\[SEVERE\]|Built|Failed|Succeeded' || true
dart format lib/api tool/api >/dev/null

echo "==> changes"
git diff --stat -- tool/api lib/api | tail -5
