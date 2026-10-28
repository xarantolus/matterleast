#!/usr/bin/env bash
# The gate, detached so it survives the shell that started it. Run from
# inside the worktree.
#
#   tool/gate.sh        start the gate in the background, print the log and
#                       status file paths
#   tool/gate.sh wait   block until the run is done, print the end of the log
#                       and the status; exits with that status
#
# The status file holds "running", then "0" or "1".
set -euo pipefail

root=$(git rev-parse --show-toplevel)
name=$(basename "$root")
log=/tmp/matterleast-gate-$name.log
status=/tmp/matterleast-gate-$name.status

run() {
    cd "$root"
    local step
    for step in \
        "dart run build_runner build --delete-conflicting-outputs" \
        "dart format lib test" \
        "flutter analyze" \
        "dart analyze" \
        "env TZ=Europe/Berlin flutter test"; do
        echo "== $step"
        if ! $step; then
            echo "== failed: $step"
            echo 1 >"$status"
            exit 1
        fi
    done
    echo "== gate passed"
    echo 0 >"$status"
}

case ${1:-start} in
start)
    echo running >"$status"
    setsid nohup "$0" run >"$log" 2>&1 </dev/null &
    echo "log:    $log"
    echo "status: $status"
    ;;
run) run ;;
wait)
    [[ -f $status ]] || { echo "gate $name: not started" >&2; exit 1; }
    while [[ $(cat "$status") == running ]]; do sleep 5; done
    tail -n 15 "$log"
    echo "status: $(cat "$status")"
    exit "$(cat "$status")"
    ;;
*)
    echo "usage: tool/gate.sh [wait]" >&2
    exit 2
    ;;
esac
