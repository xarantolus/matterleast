#!/usr/bin/env bash
# Rebuilds the README screenshots (.github/screenshots/{d,l}-{list,chat,home}.jpg).
#
#   .devcontainer/server/readme-shots.sh seed    add the demo conversations
#   .devcontainer/server/readme-shots.sh shots   drive a lane's emulator and write the JPEGs
#
# Run `seed` once on a freshly reset test server that no agent is using
# (server.sh reset; it is not idempotent), start a lane with
# `tool/lane.sh up alice` from the worktree, then run `shots` from the same
# worktree. Taps are pixel positions for a 1080x2400 screen; if the layout
# changes, adjust them below. The Channels category is collapsed on the first
# visit so the direct messages fit on the screen.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
root=$(git -C "$here" rev-parse --show-toplevel)
URL=${URL:-http://127.0.0.1:8065}
API=$URL/api/v4
declare -A TOKEN ID

api() { # api <user> <method> <path> [json]
    local args=(-sS -m 30 -X "$2" -H "Authorization: Bearer ${TOKEN[$1]}")
    [ -n "${4:-}" ] && args+=(-H 'Content-Type: application/json' --data-binary "$4")
    curl "${args[@]}" "$API$3"
}

login() {
    TOKEN[$1]=$(curl -sS -D - -o /dev/null -X POST "$API/users/login" \
        --data-binary "{\"login_id\":\"$1\",\"password\":\"matterleast\"}" |
        awk 'tolower($1)=="token:" {print $2}' | tr -d '\r')
    ID[$1]=$(api "$1" GET /users/me | jq -r .id)
}

post() { # post <user> <channel id> <message> [extra json] -> id
    api "$1" POST /posts "$(jq -n --arg c "$2" --arg m "$3" --argjson e "${4:-{\}}" \
        '{channel_id:$c, message:$m} + $e')" | jq -r .id
}

react() { api "$1" POST /reactions "$(jq -n --arg u "${ID[$1]}" --arg p "$2" --arg e "$3" \
    '{user_id:$u, post_id:$p, emoji_name:$e}')" >/dev/null; }

view() { api alice POST "/channels/members/${ID[alice]}/view" "{\"channel_id\":\"$1\"}" >/dev/null; }

seed() {
    local tmp
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' RETURN
    for u in admin alice bob carol dave erin; do login "$u"; done
    local lh hb
    lh=$(api alice GET /teams/name/lighthouse | jq -r .id)
    hb=$(api alice GET /teams/name/harbor | jq -r .id)

    # Avatars for people and bots, icons for both teams.
    for u in admin alice bob carol dave erin helper-bot system-bot; do
        node "$here/make-avatar.js" "$tmp/$u.png" "$u" 256
        curl -sS -H "Authorization: Bearer ${TOKEN[admin]}" -F "image=@$tmp/$u.png" \
            "$API/users/$(api admin GET "/users/username/$u" | jq -r .id)/image" >/dev/null
    done
    node "$here/make-avatar.js" "$tmp/lh.png" "Lighthouse Crew" 256
    node "$here/make-avatar.js" "$tmp/hb.png" "Harbor Side" 256
    curl -sS -H "Authorization: Bearer ${TOKEN[admin]}" -F "image=@$tmp/lh.png" "$API/teams/$lh/image" >/dev/null
    curl -sS -H "Authorization: Bearer ${TOKEN[admin]}" -F "image=@$tmp/hb.png" "$API/teams/$hb/image" >/dev/null

    local reg
    reg=$(api admin POST /channels "$(jq -n --arg t "$lh" \
        '{team_id:$t, name:"regatta", display_name:"Regatta", type:"O", purpose:"Saturday race, crew and kit"}')" | jq -r .id)
    for u in alice bob carol dave erin; do
        api admin POST "/channels/$reg/members" "{\"user_id\":\"${ID[$u]}\"}" >/dev/null
    done
    for n in firehose bots-lab; do
        local c
        c=$(api alice GET "/teams/$lh/channels/name/$n" | jq -r .id)
        api alice DELETE "/channels/$c/members/${ID[alice]}" >/dev/null
    done

    # The regatta conversation alice has read.
    post carol "$reg" "Entry confirmed. Start gun is at 11:30 on Saturday, we should be at the dock by 10:15." >/dev/null
    sleep 1
    post dave "$reg" "Forecast says 12 to 15 knots from the west. I would put a reef in the main before we leave the dock." >/dev/null
    node "$here/readme-shots/make-scene.js" "$tmp/scene.png"
    local fid p1 code root
    fid=$(curl -sS -H "Authorization: Bearer ${TOKEN[bob]}" -F "files=@$tmp/scene.png" "$API/files?channel_id=$reg" |
        jq -r '.file_infos[0].id')
    p1=$(post bob "$reg" "Last night off the pier. Good omen, I think." "{\"file_ids\":[\"$fid\"]}")
    react alice "$p1" sailboat; react carol "$p1" heart; react dave "$p1" +1; react erin "$p1" +1
    sleep 1
    post alice "$reg" "Gorgeous. I will bring the spare jib and a thermos of tea." >/dev/null
    code=$(post dave "$reg" 'Tide table for the start line:
```
10:42  high  3.1 m
16:58  low   0.6 m
```')
    react bob "$code" eyes
    sleep 1
    root=$(post erin "$reg" "Crew vests are in the shed. Reply here with your size so I can set them aside.")
    post bob "$reg" "M for me, thanks Erin" "{\"root_id\":\"$root\"}" >/dev/null
    post carol "$reg" "Small please" "{\"root_id\":\"$root\"}" >/dev/null
    post dave "$reg" "Large, and one extra for the dog :dog:" "{\"root_id\":\"$root\"}" >/dev/null
    react alice "$root" +1; react bob "$root" tada
    sleep 1
    post carol "$reg" "Perfect, see everyone at the dock. :sailboat:" >/dev/null

    # Everything alice has read, then the unread messages the screenshots show.
    local town eng des nw media dmb dmc dmd gm
    town=$(api alice GET "/teams/$lh/channels/name/town-square" | jq -r .id)
    media=$(api alice GET "/teams/$lh/channels/name/media" | jq -r .id)
    eng=$(api alice GET "/teams/$lh/channels/name/engineering" | jq -r .id)
    des=$(api alice GET "/teams/$lh/channels/name/design" | jq -r .id)
    nw=$(api alice GET "/teams/$lh/channels/name/night-watch" | jq -r .id)
    dmb=$(api alice POST /channels/direct "[\"${ID[alice]}\",\"${ID[bob]}\"]" | jq -r .id)
    dmc=$(api alice POST /channels/direct "[\"${ID[alice]}\",\"${ID[carol]}\"]" | jq -r .id)
    dmd=$(api alice POST /channels/direct "[\"${ID[alice]}\",\"${ID[dave]}\"]" | jq -r .id)
    gm=$(api alice POST /channels/group "[\"${ID[alice]}\",\"${ID[bob]}\",\"${ID[carol]}\"]" | jq -r .id)
    for c in $reg $town $eng $des $nw $media $dmb $dmc $dmd $gm; do view "$c"; done
    sleep 1
    post dave "$town" "@alice the harbour master wants the entry form by Friday noon." >/dev/null
    post erin "$town" "Coffee machine on the second floor is fixed. Rejoice. :coffee:" >/dev/null
    post bob "$eng" "@alice could you take a look at the release notes before lunch?" >/dev/null
    post carol "$eng" "Merged the spacing fix for the channel rows :tada:" >/dev/null
    post carol "$des" "New icon set is exported. Tell me what you think when you have a minute." >/dev/null
    post dave "$nw" "Can we swap Thursday? I have a dentist appointment." >/dev/null
    post bob "$dmb" "Are you bringing the spare jib on Saturday?" >/dev/null
    post bob "$dmb" "Also, thank you for covering the standup yesterday." >/dev/null
    post carol "$dmc" "Lunch at 12? The noodle place just opened." >/dev/null
    post carol "$gm" "Who is bringing snacks to the race?" >/dev/null
    post bob "$gm" "I can do sandwiches." >/dev/null

    local u
    for pair in bob:online erin:online carol:dnd dave:away alice:online; do
        u=${pair%%:*}
        api "$u" PUT "/users/${ID[$u]}/status" "{\"user_id\":\"${ID[$u]}\",\"status\":\"${pair##*:}\"}" >/dev/null
    done
    api alice PUT "/users/${ID[alice]}/preferences" \
        "[{\"user_id\":\"${ID[alice]}\",\"category\":\"favorite_channel\",\"name\":\"$reg\",\"value\":\"true\"}]" >/dev/null
    echo "seed: done"
}

# Screenshots go to the lane's temp folder first; a JPEG is only written to
# the repository when its pixels differ from the committed one.
shots() {
    local lane=$root/tool/lane.sh out=$root/.github/screenshots ui=$here/readme-shots/ui.py
    mkdir -p "$out"
    tap() { python3 "$ui" "$lane adb" tap "$@"; sleep 2; }
    keep() { # keep <d|l> <list|chat|home>
        local png
        png=$("$lane" shot "$1-$2")
        echo "$1-$2: $(dart run "$root/tool/png_to_jpg.dart" "$png" "$out/$1-$2.jpg" 85)"
    }
    "$lane" adb shell settings put global sysui_demo_allowed 1
    for c in "-e command enter" "-e command clock -e hhmm 0815" "-e command battery -e level 100 -e plugged false" \
        "-e command network -e wifi show -e level 4" "-e command network -e mobile show -e datatype none -e level 4" \
        "-e command notifications -e visible false"; do
        # shellcheck disable=SC2086
        "$lane" adb shell am broadcast -a com.android.systemui.demo $c >/dev/null
    done
    # A fresh install asks about notifications first.
    if python3 "$ui" "$lane adb" has 'Not now'; then tap 'Not now'; fi
    for mode in d:yes l:no; do
        "$lane" adb shell cmd uimode night "${mode##*:}" >/dev/null
        sleep 3
        tap 'Home' -1
        keep "${mode%%:*}" home
        tap 'Lighthouse Crew · Mattermost.*'
        # Collapse Channels on the first visit so the direct messages fit on
        # the screen; it stays collapsed for the second.
        if [ "${mode%%:*}" = d ]; then tap 'Channels'; fi
        keep "${mode%%:*}" list
        tap 'Regatta'
        sleep 1
        keep "${mode%%:*}" chat
        "$lane" adb shell input keyevent 4
        sleep 2
    done
    ls -l "$out"
}

case ${1:-} in
    seed) seed ;;
    shots) shots ;;
    *) sed -n '2,13p' "$0" ;;
esac
