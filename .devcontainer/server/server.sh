#!/usr/bin/env bash
# Throwaway Mattermost server for development and tests, run with podman inside
# the dev container. Listens on the loopback only; the emulator reaches it as
# http://10.0.2.2:8065. All data is invented (see seed.sh).
#
#   server.sh start [--second]  create or start the containers, wait until the
#                               API answers, seed on first start; --second also
#                               runs a second server on port 8067 for
#                               multi-server tests
#   server.sh stop
#   server.sh status
#   server.sh logs [db|server|server2|commands]
#   server.sh reset             delete all data, then start and seed again
#   server.sh seed [port]       run the seed script against a running server
#   server.sh recreate          recreate the server container (keeps its data)
#                               so changes to mattermost.env apply
#   server.sh agents            install the Agents plugin with a fake model
#                               (agents.sh)
set -euo pipefail
cd "$(dirname "$0")"

MM_IMAGE=docker.io/mattermost/mattermost-team-edition:12.0.1
PG_IMAGE=docker.io/library/postgres:17-alpine
NODE_IMAGE=docker.io/library/node:22-alpine
PREFIX=matterleast
DB_PASSWORD=mmuser-local-only
BOOT_TIMEOUT=${BOOT_TIMEOUT:-180}

exists() { podman container exists "$PREFIX-$1"; }
# Runs a postgres client tool against the database over TCP; podman exec can't
# enter the container's namespaces inside the dev container.
pg() { podman run --rm --network host -e PGPASSWORD="$DB_PASSWORD" "$PG_IMAGE" "$@"; }
running() { [ "$(podman inspect -f '{{.State.Running}}' "$PREFIX-$1" 2>/dev/null)" = true ]; }

create_db() {
    podman run -d --name "$PREFIX-db" --network host \
        -v "$PREFIX-db-data":/var/lib/postgresql/data \
        -e POSTGRES_USER=mmuser -e POSTGRES_PASSWORD="$DB_PASSWORD" -e POSTGRES_DB=mattermost \
        "$PG_IMAGE" -c listen_addresses=127.0.0.1 >/dev/null
}

# create_server <name> <port> <database>
create_server() {
    local name=$1 port=$2 database=$3
    podman run -d --name "$PREFIX-$name" --network host \
        -v "$PREFIX-$name-config":/mattermost/config \
        -v "$PREFIX-$name-data":/mattermost/data \
        --env-file mattermost.env \
        -e MM_SERVICESETTINGS_SITEURL="http://10.0.2.2:$port" \
        -e MM_SERVICESETTINGS_LISTENADDRESS="127.0.0.1:$port" \
        -e MM_SQLSETTINGS_DATASOURCE="postgres://mmuser:$DB_PASSWORD@127.0.0.1:5432/$database?sslmode=disable&connect_timeout=10" \
        "$MM_IMAGE" >/dev/null
}

create_commands() {
    podman run -d --name "$PREFIX-commands" --network host \
        -v "$PWD/commands":/app:ro -w /app \
        "$NODE_IMAGE" node responder.js >/dev/null
}

# pg_retry <client args...>: like pg, retried while the database is starting.
pg_retry() {
    local tries=0
    until pg "$@" 2>/dev/null; do
        tries=$((tries + 1))
        [ "$tries" -ge 60 ] && { echo "server: database not ready" >&2; exit 1; }
        sleep 1
    done
}

wait_db() { pg_retry psql -q -h 127.0.0.1 -U mmuser -d postgres -c "SELECT 1" >/dev/null; }

wait_ready() { # wait_ready <port>
    local waited=0
    until curl -fsS -m 5 "http://127.0.0.1:$1/api/v4/system/ping" 2>/dev/null | grep -q '"status":"OK"'; do
        sleep 3
        waited=$((waited + 3))
        if [ "$waited" -ge "$BOOT_TIMEOUT" ]; then
            echo "server: port $1 not ready after ${BOOT_TIMEOUT}s; see: $0 logs server" >&2
            exit 1
        fi
    done
    echo "server: ready at http://127.0.0.1:$1 after ${waited}s"
}

start_one() { # start_one <name> <port> <database>
    local name=$1 port=$2 database=$3 fresh=0
    if ! exists "$name"; then
        wait_db
        local present
        present=$(pg_retry psql -h 127.0.0.1 -U mmuser -d postgres -tAc \
            "SELECT 1 FROM pg_database WHERE datname='$database'" | tr -d "[:space:]")
        [ "$present" = 1 ] || pg createdb -h 127.0.0.1 -U mmuser "$database"
        create_server "$name" "$port" "$database"
        fresh=1
    elif ! running "$name"; then
        podman start "$PREFIX-$name" >/dev/null
    fi
    wait_ready "$port"
    [ $fresh = 1 ] && URL="http://127.0.0.1:$port" ./seed.sh
    true
}

start() {
    local second=${1:-}
    for c in db commands; do
        if ! exists $c; then create_$c; elif ! running $c; then podman start "$PREFIX-$c" >/dev/null; fi
    done
    start_one server 8065 mattermost
    if [ "$second" = "--second" ] || exists server2; then
        start_one server2 8067 mattermost2
    fi
}

stop() {
    for c in commands server2 server db; do
        running $c && podman stop -t 10 "$PREFIX-$c" >/dev/null && echo "server: stopped $c"
    done
    true
}

reset() {
    local had_second=0
    exists server2 && had_second=1
    stop
    for c in commands server2 server db; do
        exists $c && podman rm -v "$PREFIX-$c" >/dev/null
    done
    for v in db-data server-config server-data server2-config server2-data; do
        podman volume exists "$PREFIX-$v" && podman volume rm "$PREFIX-$v" >/dev/null
    done
    echo "server: data deleted"
    if [ $had_second = 1 ]; then start --second; else start; fi
}

status() {
    podman ps -a --filter "name=^$PREFIX-" --format '{{.Names}}\t{{.Status}}'
    for port in 8065 8067; do
        curl -fsS -m 5 "http://127.0.0.1:$port/api/v4/system/ping" >/dev/null 2>&1 \
            && echo "server: $port answering" || echo "server: $port not answering"
    done
}

case "${1:-status}" in
start) start "${2:-}" ;;
stop) stop ;;
reset) reset ;;
status) status ;;
seed) URL="http://127.0.0.1:${2:-8065}" ./seed.sh ;;
recreate)
    podman stop -t 10 "$PREFIX-server" >/dev/null && podman rm "$PREFIX-server" >/dev/null
    create_server server 8065 mattermost
    wait_ready 8065 ;;
agents) ./agents.sh ;;
logs) podman logs --tail 200 -f "$PREFIX-${2:-server}" ;;
*) sed -n '2,19p' "$0"; exit 2 ;;
esac
