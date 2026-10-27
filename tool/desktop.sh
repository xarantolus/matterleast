#!/usr/bin/env bash
# One Linux desktop lane per git worktree: a virtual X screen with a window
# manager, a panel with a tray, a notification daemon, a D-Bus session and an
# unlocked keyring, and the app running with `flutter run -d linux`, signed in
# to the local test server, hot reloaded when lib/ changes. Run from inside
# the worktree. Coordinates are screen pixels, the same as in `shot` PNGs.
#
#   tool/desktop.sh up [user]        start the session, run the app as user (alice)
#   tool/desktop.sh reload           hot reload now and print the result
#   tool/desktop.sh restart          hot restart now and print the result
#   tool/desktop.sh shot <label> [--window]
#                                    PNG of the screen (or the app window) to
#                                    /tmp/matterleast-shots/, prints the path
#   tool/desktop.sh click X Y        left click; rclick X Y for a right click
#   tool/desktop.sh type TEXT        type text into the focused field
#   tool/desktop.sh key COMBO...     press keys, e.g. ctrl+k, Return, Escape
#   tool/desktop.sh drag X1 Y1 X2 Y2 drag with the left button held
#   tool/desktop.sh scroll X Y N     scroll N notches at X Y (negative = up)
#   tool/desktop.sh size W H         resize the app window
#   tool/desktop.sh windows          visible windows with their geometry
#   tool/desktop.sh log [lines]      the end of the flutter run log
#   tool/desktop.sh down [--wipe]    stop everything this lane started; the app's
#                                    data (and so its signed-in user) stays
#                                    for the next up unless --wipe
#   tool/desktop.sh status           all desktop lanes on this machine
set -euo pipefail

root=$(git rev-parse --show-toplevel)
name=$(basename "$root")
state_dir=/tmp/matterleast-lanes
# Not *.env, which lane.sh reads as emulator lanes.
state=$state_dir/$name.desktop
log=$state_dir/$name.desktop.log
home=$state_dir/$name.desktop.d
pid_file=$root/.desktop.pid
app_class=io.github.xarantolus.matterleast
screen_size=${DESKTOP_SIZE:-1600x1000}
mkdir -p "$state_dir" /tmp/matterleast-shots

load() {
    [[ -f $state ]] || { echo "desktop $name: not up (tool/desktop.sh up)" >&2; exit 1; }
    # shellcheck source=/dev/null
    source "$state"
    export DISPLAY
}

alive() { [[ -n ${1:-} ]] && kill -0 "$1" 2>/dev/null; }

free_display() {
    local n
    for n in $(seq 20 60); do
        if [[ ! -e /tmp/.X$n-lock && ! -e /tmp/.X11-unix/X$n ]]; then
            echo ":$n"
            return
        fi
    done
    echo "desktop: no free display" >&2
    exit 1
}

# Every process this lane started carries the marker in its environment,
# including the ones that daemonise (dbus, keyring) or are D-Bus activated.
lane_pids() {
    local p
    for p in /proc/[0-9]*; do
        [[ ${p#/proc/} == "$$" ]] && continue
        tr '\0' '\n' 2> /dev/null < "$p/environ" | grep -qx "MATTERLEAST_DESKTOP=$name" && echo "${p#/proc/}"
    done
    return 0
}

app_window() {
    xdotool search --onlyvisible --classname "$app_class" 2>/dev/null | head -n 1
}

# Sets X Y WIDTH HEIGHT of a window in screen pixels. xwininfo, because
# xdotool's position is off by the frame for windows the WM reparents.
geometry() {
    eval "$(xwininfo -id "$1" 2> /dev/null | awk -F: '
        /Absolute upper-left X/ { print "X=" $2+0 }
        /Absolute upper-left Y/ { print "Y=" $2+0 }
        /^ *Width/ { print "WIDTH=" $2+0 }
        /^ *Height/ { print "HEIGHT=" $2+0 }')"
}

# Until the app skips WorkManager on desktop, it installs a systemd user
# timer that would start this debug build every 15 minutes.
remove_workmanager_timers() {
    local dir=${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user unit base
    for unit in "$dir"/workmanager-*.service; do
        [[ -f $unit ]] && grep -q "^ExecStart=$root/build/linux/" "$unit" || continue
        base=$(basename "$unit" .service)
        systemctl --user disable --now "$base.timer" > /dev/null 2>&1 || true
        rm -f "$unit" "$dir/$base.timer" "$dir/timers.target.wants/$base.timer"
        echo "desktop $name: removed the WorkManager timer $base"
    done
    rmdir "$dir/timers.target.wants" "$dir" "${dir%/user}" 2> /dev/null || true
}

# Sends a signal to flutter run and waits for the outcome in the log.
signal() {
    load
    local sig=$1 done_re=$2 pid offset
    pid=$(cat "$pid_file" 2>/dev/null || true)
    alive "$pid" || { echo "desktop $name: flutter run is not running (see tool/desktop.sh log)" >&2; exit 1; }
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
    echo "desktop $name: no answer within 60 s" >&2
    tail -n 20 "$log"
    exit 1
}

# A bottom panel with a task list, the tray (StatusNotifier and XEmbed) and
# a clock; without a stored config xfce4-panel asks which layout to use.
write_panel_config() {
    local dir=$home/config/xfce4/xfconf/xfce-perchannel-xml
    mkdir -p "$dir"
    cat > "$dir/xfce4-panel.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=8;x=0;y=0"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="32"/>
      <property name="icon-size" type="uint" value="22"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="tasklist"/>
    <property name="plugin-2" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="uint" value="0"/>
    </property>
    <property name="plugin-3" type="string" value="systray">
      <property name="square-icons" type="bool" value="true"/>
    </property>
    <property name="plugin-4" type="string" value="clock"/>
  </property>
</channel>
EOF
}

wait_for() {
    local what=$1 check=$2
    for _ in $(seq 50); do
        eval "$check" > /dev/null 2>&1 && return 0
        sleep 0.1
    done
    echo "desktop $name: $what did not start" >&2
    return 1
}

start_session() {
    local display=$1
    write_panel_config
    mkdir -p "$home/data" "$home/cache" "$home/run"
    chmod 700 "$home/run"
    export MATTERLEAST_DESKTOP=$name DISPLAY=$display
    export XDG_DATA_HOME=$home/data XDG_CACHE_HOME=$home/cache XDG_RUNTIME_DIR=$home/run
    export GDK_BACKEND=x11 NO_AT_BRIDGE=1
    export DBUS_SESSION_BUS_ADDRESS=unix:path=$home/run/bus
    unset WAYLAND_DISPLAY

    Xvfb "$display" -screen 0 "${screen_size}x24" -nolisten tcp -dpi 96 -br > "$home/xvfb.log" 2>&1 &
    wait_for Xvfb "xdpyinfo -display $display"
    # Services the bus starts on demand (xfconfd for the panel) read the
    # lane's config; the app keeps the normal config dir, where flutter
    # keeps its settings.
    XDG_CONFIG_HOME=$home/config dbus-daemon --session --fork --address="$DBUS_SESSION_BUS_ADDRESS" > /dev/null
    wait_for dbus "test -S $home/run/bus"
    # Creates (first run) and unlocks the login keyring, so libsecret stores
    # the session token without a password prompt. Only for the test server.
    printf matterleast | gnome-keyring-daemon --unlock --components=secrets > /dev/null 2> "$home/keyring.log"
    # Close to tray and minimise need a real window manager.
    openbox --config-file /etc/xdg/openbox/rc.xml > "$home/openbox.log" 2>&1 &
    XDG_CONFIG_HOME=$home/config xfce4-panel --disable-wm-check > "$home/panel.log" 2>&1 &
    dunst > "$home/dunst.log" 2>&1 &
}

cmd=${1:-status}
shift || true
case "$cmd" in
up)
    user=${1:-alice}
    if [[ -f $state ]]; then
        load
        if alive "${RUN_PID:-}"; then echo "desktop $name: already up on $DISPLAY"; exit 0; fi
        for p in $(lane_pids); do kill "$p" 2>/dev/null || true; done
    fi
    display=$(free_display)
    # Written first, so `down` can clean up after a failed start.
    printf 'DISPLAY=%s\nDIR=%s\n' "$display" "$root" > "$state"
    start_session "$display"
    (cd "$root" && flutter pub get > /dev/null)
    : > "$log"
    # A held-open stdin keeps flutter run alive without a terminal; reloads
    # come in as signals through the pid file.
    (cd "$root" && exec flutter run -d linux --debug \
        --pid-file "$pid_file" \
        --dart-define="MATTERLEAST_DEV_LOGIN=http://127.0.0.1:8065|$user|matterleast" \
        < <(tail -f /dev/null 2> /dev/null) >> "$log" 2>&1) > /dev/null 2>&1 &
    run_pid=$!
    # Reload a second after the last change under lib/.
    (
        cd "$root"
        stamp=$state_dir/$name.desktop.stamp
        touch "$stamp"
        while kill -0 "$run_pid" 2>/dev/null; do
            sleep 1
            if [[ -n $(find lib -newer "$stamp" -name '*.dart' -print -quit) ]]; then
                sleep 1
                touch "$stamp"
                pid=$(cat "$pid_file" 2>/dev/null || true)
                [[ -n $pid ]] && kill -USR1 "$pid" 2>/dev/null || true
            fi
        done
    ) > /dev/null 2>&1 &
    watch_pid=$!
    printf 'DISPLAY=%s\nRUN_PID=%s\nWATCH_PID=%s\nDIR=%s\n' "$display" "$run_pid" "$watch_pid" "$root" > "$state"
    echo "desktop $name: display $display ($screen_size), building (tool/desktop.sh log)..."
    for _ in $(seq 600); do
        sleep 1
        if grep -qE 'Flutter run key commands|A Dart VM Service' "$log"; then
            echo "desktop $name: running on $display as $user; lib/ changes hot reload"
            exit 0
        fi
        if ! alive "$run_pid"; then
            echo "desktop $name: flutter run stopped" >&2
            tail -n 30 "$log" >&2
            exit 1
        fi
    done
    echo "desktop $name: app not up after 600 s" >&2
    exit 1
    ;;
reload) signal USR1 'Reloaded' ;;
restart) signal USR2 'Restarted' ;;
shot)
    load
    label=${1:?label}
    out=/tmp/matterleast-shots/$name-desktop-$label.png
    if [[ ${2:-} == --window ]]; then
        win=$(app_window)
        [[ -n $win ]] || { echo "desktop $name: no app window" >&2; exit 1; }
        geometry "$win"
        import -window root -crop "${WIDTH}x${HEIGHT}+${X}+${Y}" +repage -quality 10 "png:$out"
        echo "$out (window at +$X+$Y: add that to its pixel coordinates)"
    else
        import -window root -quality 10 "png:$out"
        echo "$out"
    fi
    ;;
click | rclick)
    load
    button=1
    [[ $cmd == rclick ]] && button=3
    xdotool mousemove --sync "${1:?X}" "${2:?Y}" click "$button"
    ;;
type)
    load
    xdotool type --delay 15 -- "${*:?text}"
    ;;
key)
    load
    xdotool key --delay 30 -- "${@:?combo}"
    ;;
drag)
    load
    x1=${1:?X1} y1=${2:?Y1} x2=${3:?X2} y2=${4:?Y2}
    xdotool mousemove --sync "$x1" "$y1" mousedown 1
    # Steps, so the app sees a drag rather than a jump.
    for i in $(seq 1 10); do
        xdotool mousemove --sync $((x1 + (x2 - x1) * i / 10)) $((y1 + (y2 - y1) * i / 10))
        sleep 0.02
    done
    xdotool mouseup 1
    ;;
scroll)
    load
    n=${3:?N}
    button=5
    if (( n < 0 )); then button=4; n=$((-n)); fi
    xdotool mousemove --sync "${1:?X}" "${2:?Y}" click --repeat "$n" --delay 40 "$button"
    ;;
size)
    load
    win=$(app_window)
    [[ -n $win ]] || { echo "desktop $name: no app window" >&2; exit 1; }
    xdotool windowsize --sync "$win" "${1:?W}" "${2:?H}"
    ;;
windows)
    load
    for win in $(xdotool search --onlyvisible --name '' 2>/dev/null); do
        # Client windows only, not the WM's frame parts.
        class=$(xprop -id "$win" WM_CLASS 2> /dev/null | sed -n 's/.*= "\([^"]*\)".*/\1/p')
        [[ -n $class ]] || continue
        geometry "$win"
        printf '%-10s %4dx%-4d +%d+%d  %-34s %s\n' "$win" "$WIDTH" "$HEIGHT" "$X" "$Y" \
            "$class" "$(xdotool getwindowname "$win" 2> /dev/null)"
    done
    ;;
log)
    load
    tail -n "${1:-40}" "$log"
    ;;
down)
    load
    alive "${WATCH_PID:-}" && kill "$WATCH_PID" || true
    pid=$(cat "$pid_file" 2>/dev/null || true)
    alive "$pid" && kill "$pid" || true
    alive "${RUN_PID:-}" && kill "$RUN_PID" || true
    sleep 1
    pids=$(lane_pids)
    [[ -n $pids ]] && kill $pids 2>/dev/null || true
    sleep 1
    pids=$(lane_pids)
    [[ -n $pids ]] && kill -9 $pids 2>/dev/null || true
    remove_workmanager_timers
    rm -f "$state" "$pid_file" "$state_dir/$name.desktop.stamp" \
        "/tmp/.X${DISPLAY#:}-lock" "/tmp/.X11-unix/X${DISPLAY#:}"
    if [[ ${1:-} == --wipe ]]; then
        rm -rf "$home"
        echo "desktop $name: down, app data wiped"
    else
        echo "desktop $name: down (app data kept in $home)"
    fi
    ;;
status)
    shopt -s nullglob
    for f in "$state_dir"/*.desktop; do
        (
            # shellcheck source=/dev/null
            source "$f"
            if alive "${RUN_PID:-}"; then s=running; else s=stopped; fi
            echo "$(basename "$f" .desktop): $DISPLAY $s $DIR"
        )
    done
    ;;
*)
    sed -n '2,/^[^#]/{/^#/p}' "$0"
    exit 1
    ;;
esac
