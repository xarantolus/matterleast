#!/usr/bin/env bash
# Records API responses from the local test server (invented data) into
# test/fixtures/api/ for decoding and sync tests. Run with the server up:
#   .devcontainer/server/server.sh start && tool/record-fixtures.sh
set -euo pipefail
cd "$(dirname "$0")/.."

URL=${URL:-http://127.0.0.1:8065}
API=$URL/api/v4
OUT=test/fixtures/api
mkdir -p "$OUT"

TOKEN=$(curl -sS -m 30 -D - -o /dev/null -X POST "$API/users/login" \
    --data-binary '{"login_id":"alice","password":"matterleast"}' \
    | awk 'tolower($1)=="token:" {print $2}' | tr -d '\r')
[ -n "$TOKEN" ] || { echo "login failed; is the server seeded?" >&2; exit 1; }

get() { # get <name> <path> [curl args...]
    local name=$1 path=$2
    shift 2
    curl -sS -m 30 --fail-with-body -H "Authorization: Bearer $TOKEN" "$@" "$API$path" | jq . > "$OUT/$name.json"
    echo "  $name.json"
}

ME=$(curl -sS -H "Authorization: Bearer $TOKEN" "$API/users/me" | jq -r .id)
TEAM=$(curl -sS -H "Authorization: Bearer $TOKEN" "$API/teams/name/lighthouse" | jq -r .id)
ENG=$(curl -sS -H "Authorization: Bearer $TOKEN" "$API/teams/$TEAM/channels/name/engineering" | jq -r .id)
OFFTOPIC=$(curl -sS -H "Authorization: Bearer $TOKEN" "$API/teams/$TEAM/channels/name/off-topic" | jq -r .id)

get me /users/me
get client_config '/config/client?format=old'
get client_license '/license/client?format=old'
get preferences "/users/$ME/preferences"
get my_teams "/users/$ME/teams"
get my_team_members "/users/$ME/teams/members"
get team_unreads "/users/$ME/teams/unread"
get channels "/users/$ME/teams/$TEAM/channels?include_deleted=true"
get channel_members "/users/$ME/teams/$TEAM/channels/members"
get categories "/users/$ME/teams/$TEAM/channels/categories"
get channel "/channels/$ENG"
get channel_stats "/channels/$ENG/stats"
get posts_page "/channels/$ENG/posts?page=0&per_page=60&collapsedThreads=true&collapsedThreadsExtended=true"
get posts_page_flat "/channels/$ENG/posts?page=0&per_page=60"
get posts_since "/channels/$ENG/posts?since=0"
get posts_before "/channels/$OFFTOPIC/posts?page=0&per_page=30"
ROOT=$(jq -r '[.posts[] | select(.root_id == "" and .reply_count > 0)][0].id' "$OUT/posts_page.json")
get thread "/posts/$ROOT/thread?collapsedThreads=true&collapsedThreadsExtended=true&perPage=60"
get post "/posts/$ROOT"
get post_info "/posts/$ROOT/info"
get threads "/users/$ME/teams/$TEAM/threads?per_page=25&totalsOnly=false"
get pinned "/channels/$ENG/pinned"
get flagged "/users/$ME/posts/flagged?per_page=30"
get emoji '/emoji?per_page=200&sort=name'
get roles '/roles/names' -X POST -H 'Content-Type: application/json' --data-binary '["system_user","channel_user","team_user"]'
get users_by_ids '/users/ids' -X POST -H 'Content-Type: application/json' --data-binary "$(jq -c '[.posts[].user_id] | unique' "$OUT/posts_page_flat.json")"
get statuses '/users/status/ids' -X POST -H 'Content-Type: application/json' --data-binary "$(jq -c '[.posts[].user_id] | unique' "$OUT/posts_page_flat.json")"
get search_posts "/teams/$TEAM/posts/search" -X POST -H 'Content-Type: application/json' --data-binary '{"terms":"release","is_or_search":false,"page":0,"per_page":20}'
get mentions "/teams/$TEAM/posts/search" -X POST -H 'Content-Type: application/json' --data-binary '{"terms":"@alice","is_or_search":true,"page":0,"per_page":20}'
get commands "/teams/$TEAM/commands/autocomplete"
get files_in_channel "/teams/$TEAM/files/search" -X POST -H 'Content-Type: application/json' --data-binary '{"terms":"checklist","is_or_search":false}'
curl -sS -m 30 -o "$OUT/ping.json" "$API/system/ping" && echo "  ping.json"
curl -sS -m 30 -o "$OUT/login_failed.json" -X POST "$API/users/login" --data-binary '{"login_id":"alice","password":"wrong"}' && echo "  login_failed.json"
echo "recorded into $OUT"
