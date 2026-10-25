#!/usr/bin/env bash
# Regenerates test/fixtures/markdown/expected.json from corpus.json with the
# pinned @mattermost/commonmark. Dev-only; needs node and npm. CI uses the
# committed output.
set -euo pipefail
cd "$(dirname "$0")"
npm install --no-save --no-package-lock --silent
node generate.mjs ../../test/fixtures/markdown/corpus.json \
    ../../test/fixtures/markdown/expected.json
