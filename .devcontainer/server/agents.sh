#!/usr/bin/env bash
# Installs the open-source Agents plugin (mattermost-ai) on the local test
# server and points its one agent, "Local Echo" (@echo), at the fake model in
# commands/llm.js. No real model or key is involved.
#
#   agents.sh            install (or update) and configure; idempotent
#
# Environment: URL (server, default http://127.0.0.1:8065), LLM_URL (default
# the commands container), AGENTS_VERSION, AGENTS_CACHE (download folder).
set -euo pipefail
cd "$(dirname "$0")"

URL=${URL:-http://127.0.0.1:8065}
API=$URL/api/v4
LLM_URL=${LLM_URL:-http://127.0.0.1:8066/llm/v1}
VERSION=${AGENTS_VERSION:-2.10.0}
CACHE=${AGENTS_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/matterleast}
TARBALL=$CACHE/mattermost-plugin-agents-v$VERSION-linux-amd64.tar.gz
RELEASE=https://github.com/mattermost/mattermost-plugin-agents/releases/download

mkdir -p "$CACHE"
if [ ! -s "$TARBALL" ]; then
    echo "agents: downloading plugin $VERSION"
    curl -fsSL -m 600 -o "$TARBALL.part" "$RELEASE/v$VERSION/mattermost-plugin-agents-v$VERSION-linux-amd64.tar.gz"
    mv "$TARBALL.part" "$TARBALL"
fi

token=$(curl -sS -m 30 -D - -o /dev/null -X POST "$API/users/login" \
    --data-binary '{"login_id":"admin","password":"matterleast"}' \
    | awk 'tolower($1)=="token:" {print $2}' | tr -d '\r')
[ -n "$token" ] || { echo "agents: admin login failed" >&2; exit 1; }
api() { # api <method> <path> [json]
    local args=(-sS -m 120 --fail-with-body -X "$1" -H "Authorization: Bearer $token")
    [ -n "${3:-}" ] && args+=(-H 'Content-Type: application/json' --data-binary "$3")
    curl "${args[@]}" "$API$2"
}

plugins=$(api GET /plugins 2>&1) || {
    echo "agents: plugins are off on this server; recreate it with the current mattermost.env (server.sh recreate)" >&2
    exit 1
}
echo "agents: uploading plugin"
curl -sS -m 300 --fail-with-body -H "Authorization: Bearer $token" \
    -F "plugin=@$TARBALL" -F force=true "$API/plugins" >/dev/null

api POST /plugins/mattermost-ai/enable >/dev/null

# The plugin keeps its configuration and its agents in its own store; both
# go through its admin API.
plugin() { # plugin <method> <path> [json]
    local args=(-sS -m 60 --fail-with-body -X "$1" -H "Authorization: Bearer $token")
    [ -n "${3:-}" ] && args+=(-H 'Content-Type: application/json' --data-binary "$3")
    curl "${args[@]}" "$URL/plugins/mattermost-ai$2"
}
for _ in $(seq 30); do plugin GET /admin/config >/dev/null 2>&1 && break; sleep 1; done
config=$(plugin GET /admin/config | jq --arg llm "$LLM_URL" '.services = [{
    id: "local-echo", name: "Local echo", type: "openaicompatible",
    apiKey: "local-only-not-a-key", apiURL: $llm, defaultModel: "local-echo",
    tokenLimit: 16000, outputTokenLimit: 2000, streamingTimeoutSeconds: 60
  }] | .defaultBotName = "echo" | .allowedUpstreamHostnames = "127.0.0.1"
  | .mcp.enabled = true | .mcp.embeddedServer.enabled = true')
plugin PUT /admin/config "$config" >/dev/null
agents=$(plugin GET /agents)
if ! jq -e 'map(select(.name == "echo" or .username == "echo")) | length > 0' >/dev/null <<<"$agents"; then
    plugin POST /agents '{"username":"echo","displayName":"Local Echo","serviceID":"local-echo",
        "channelAccessLevel":0,"userAccessLevel":0,"reasoningEnabled":true}' >/dev/null
fi
echo "agents: plugin $VERSION enabled; agent @echo answers through $LLM_URL"
