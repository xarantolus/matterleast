#!/usr/bin/env bash
# One development lane per git worktree: its own emulator, the app running
# with `flutter run`, signed in to the local test server, hot reloaded when
# lib/ changes. Run from inside the worktree.
#
#   tool/lane.sh up [user]      boot an emulator, run the app as user (alice)
#   tool/lane.sh reload         hot reload now and print the result
#   tool/lane.sh restart        hot restart now and print the result
#   tool/lane.sh shot <label>   screenshot to /tmp/matterleast-shots/, prints the path
#   tool/lane.sh adb <args...>  adb against this lane's emulator
#   tool/lane.sh log [lines]    the end of the flutter run log
#   tool/lane.sh down           stop the app, the watcher and the emulator
#   tool/lane.sh status         all lanes on this machine
set -euo pipefail

root=$(git rev-parse --show-toplevel)
name=$(basename "$root")
state_dir=/tmp/matterleast-lanes
state=$state_dir/$name.env
log=$state_dir/$name.log
mkdir -p "$state_dir" /tmp/matterleast-shots

load() {
    [[ -f $state ]] || { echo "lane $name: not up (tool/lane.sh up)" >&2; exit 1; }
    # shellcheck source=/dev/null
    source "$state"
    export ANDROID_SERIAL="emulator-$PORT"
}

alive() { [[ -n ${1:-} ]] && kill -0 "$1" 2>/dev/null; }

free_port() {
    local port used
    for port in $(seq 5554 2 5584); do
        used=$(cat "$state_dir"/*.env 2>/dev/null | grep -c "^PORT=$port$" || true)
        if [[ $used == 0 ]] && ! adb devices | grep -q "emulator-$port"; then
            echo "$port"
            return
        fi
    done
    echo "lane: no free emulator port" >&2
    exit 1
}

# Sends a signal to flutter run and waits for the outcome in the log.
signal() {
    load
    local sig=$1 done_re=$2 pid offset
    pid=$(cat "$root/.lane.pid" 2>/dev/null || true)
    alive "$pid" || { echo "lane $name: flutter run is not running (see tool/lane.sh log)" >&2; exit 1; }
    offset=$(wc -l < "$log")
    kill "-$sig" "$pid"
    for _ in $(seq 120); do
        sleep 0.5
        if tail -n +"$((offset + 1))" "$log" | grep -qE "$done_re|rror|failed"; then
            sleep 0.3
            tail -n +"$((offset + 1))" "$log" | grep -vE '^\s*$' | tail -n 40
            return
        fi
    done
    echo "lane $name: no answer within 60 s" >&2
    tail -n 20 "$log"
    exit 1
}

cmd=${1:-status}
shift || true
case "$cmd" in
up)
    user=${1:-alice}
    if [[ -f $state ]]; then
        load
        if alive "${RUN_PID:-}"; then echo "lane $name: already up on emulator-$PORT"; exit 0; fi
    fi
    port=$(free_port)
    EMU_PORT=$port "$root/.devcontainer/emulator.sh" start
    export ANDROID_SERIAL="emulator-$port"
    (cd "$root" && flutter pub get > /dev/null)
    : > "$log"
    # A held-open stdin keeps flutter run alive without a terminal; reloads
    # come in as signals through the pid file.
    (cd "$root" && exec flutter run -d "emulator-$port" --debug \
        --pid-file "$root/.lane.pid" \
        --dart-define="MATTERLEAST_DEV_LOGIN=http://10.0.2.2:8065|$user|matterleast" \
        < <(tail -f /dev/null) >> "$log" 2>&1) &
    run_pid=$!
    # Reload a second after the last change under lib/.
    (
        cd "$root"
        stamp=$state_dir/$name.stamp
        touch "$stamp"
        while kill -0 "$run_pid" 2>/dev/null; do
            sleep 1
            if [[ -n $(find lib -newer "$stamp" -name '*.dart' -print -quit) ]]; then
                sleep 1
                touch "$stamp"
                pid=$(cat .lane.pid 2>/dev/null || true)
                [[ -n $pid ]] && kill -USR1 "$pid" 2>/dev/null || true
            fi
        done
    ) > /dev/null 2>&1 &
    watch_pid=$!
    printf 'PORT=%s\nRUN_PID=%s\nWATCH_PID=%s\nDIR=%s\n' "$port" "$run_pid" "$watch_pid" "$root" > "$state"
    echo "lane $name: emulator-$port, building and installing (tool/lane.sh log)..."
    for _ in $(seq 400); do
        sleep 1
        if grep -qE 'Flutter run key commands|A Dart VM Service' "$log"; then
            echo "lane $name: running on emulator-$port as $user; lib/ changes hot reload"
            exit 0
        fi
        if ! alive "$run_pid"; then
            echo "lane $name: flutter run stopped" >&2
            tail -n 30 "$log" >&2
            exit 1
        fi
    done
    echo "lane $name: app not up after 400 s" >&2
    exit 1
    ;;
reload) signal USR1 'Reloaded' ;;
restart) signal USR2 'Restarted' ;;
shot)
    load
    out=/tmp/matterleast-shots/$name-${1:?label}.png
    adb exec-out screencap -p > "$out"
    echo "$out"
    ;;
adb)
    load
    exec adb "$@"
    ;;
log)
    load
    tail -n "${1:-40}" "$log"
    ;;
down)
    load
    alive "${WATCH_PID:-}" && kill "$WATCH_PID" || true
    pid=$(cat "$root/.lane.pid" 2>/dev/null || true)
    alive "$pid" && kill "$pid" || true
    alive "${RUN_PID:-}" && kill "$RUN_PID" || true
    EMU_PORT=$PORT "$root/.devcontainer/emulator.sh" stop || true
    rm -f "$state" "$root/.lane.pid" "$state_dir/$name.stamp"
    echo "lane $name: down"
    ;;
status)
    shopt -s nullglob
    for f in "$state_dir"/*.env; do
        (
            # shellcheck source=/dev/null
            source "$f"
            if kill -0 "$RUN_PID" 2>/dev/null; then s=running; else s=stopped; fi
            echo "$(basename "$f" .env): emulator-$PORT $s $DIR"
        )
    done
    ;;
*)
    sed -n 2,13p "$0"
    exit 1
    ;;
esac
