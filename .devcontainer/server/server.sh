#!/usr/bin/env bash
# Throwaway Mattermost server for development and tests, run with podman inside
# the dev container. Listens on the loopback only; the emulator reaches it as
# http://10.0.2.2:8065. All data is invented (see seed.sh).
#
#   server.sh start    create or start the containers, wait until the API answers,
#                      seed on first start
#   server.sh stop
#   server.sh status
#   server.sh logs [db|server|commands]
#   server.sh reset    delete all data, then start and seed again
#   server.sh seed     run the seed script against the running server
set -euo pipefail
cd "$(dirname "$0")"

MM_IMAGE=docker.io/mattermost/mattermost-team-edition:12.0.1
PG_IMAGE=docker.io/library/postgres:17-alpine
NODE_IMAGE=docker.io/library/node:22-alpine
PREFIX=matterleast
URL=http://127.0.0.1:8065
DB_PASSWORD=mmuser-local-only
BOOT_TIMEOUT=${BOOT_TIMEOUT:-180}

exists() { podman container exists "$PREFIX-$1"; }
running() { [ "$(podman inspect -f '{{.State.Running}}' "$PREFIX-$1" 2>/dev/null)" = true ]; }

create_db() {
    podman run -d --name "$PREFIX-db" --network host \
        -v "$PREFIX-db-data":/var/lib/postgresql/data \
        -e POSTGRES_USER=mmuser -e POSTGRES_PASSWORD="$DB_PASSWORD" -e POSTGRES_DB=mattermost \
        "$PG_IMAGE" -c listen_addresses=127.0.0.1 >/dev/null
}

create_server() {
    podman run -d --name "$PREFIX-server" --network host \
        -v "$PREFIX-mm-config":/mattermost/config \
        -v "$PREFIX-mm-data":/mattermost/data \
        --env-file mattermost.env \
        -e MM_SQLSETTINGS_DATASOURCE="postgres://mmuser:$DB_PASSWORD@127.0.0.1:5432/mattermost?sslmode=disable&connect_timeout=10" \
        "$MM_IMAGE" >/dev/null
}

create_commands() {
    podman run -d --name "$PREFIX-commands" --network host \
        -v "$PWD/commands":/app:ro -w /app \
        "$NODE_IMAGE" node responder.js >/dev/null
}

wait_ready() {
    local waited=0
    until curl -fsS -m 5 "$URL/api/v4/system/ping" 2>/dev/null | grep -q '"status":"OK"'; do
        sleep 3
        waited=$((waited + 3))
        if [ "$waited" -ge "$BOOT_TIMEOUT" ]; then
            echo "server: not ready after ${BOOT_TIMEOUT}s; see: $0 logs server" >&2
            exit 1
        fi
    done
    echo "server: ready at $URL after ${waited}s"
}

start() {
    local fresh=0
    for c in db server commands; do
        if ! exists $c; then
            [ $c = server ] && fresh=1
            create_$c
        elif ! running $c; then
            podman start "$PREFIX-$c" >/dev/null
        fi
    done
    wait_ready
    if [ $fresh = 1 ]; then
        ./seed.sh
    fi
}

stop() {
    for c in commands server db; do
        running $c && podman stop -t 10 "$PREFIX-$c" >/dev/null && echo "server: stopped $c"
    done
    true
}

reset() {
    stop
    for c in commands server db; do
        exists $c && podman rm "$PREFIX-$c" >/dev/null
    done
    for v in db-data mm-config mm-data; do
        podman volume exists "$PREFIX-$v" && podman volume rm "$PREFIX-$v" >/dev/null
    done
    echo "server: data deleted"
    start
}

status() {
    podman ps -a --filter "name=^$PREFIX-" --format '{{.Names}}\t{{.Status}}'
    curl -fsS -m 5 "$URL/api/v4/system/ping" 2>/dev/null && echo || echo "server: API not answering"
}

case "${1:-status}" in
start) start ;;
stop) stop ;;
reset) reset ;;
status) status ;;
seed) ./seed.sh ;;
logs) podman logs --tail 200 -f "$PREFIX-${2:-server}" ;;
*) sed -n '2,13p' "$0"; exit 2 ;;
esac
