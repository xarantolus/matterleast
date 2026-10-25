#!/usr/bin/env bash
# Fills the local test server with invented users, teams, channels and content.
# Runs once on a fresh server (server.sh start does it); `server.sh reset` redoes
# it. Every user's password is "matterleast".
set -euo pipefail
cd "$(dirname "$0")"

URL=${URL:-http://127.0.0.1:8065}
API=$URL/api/v4
PASSWORD=matterleast
COMMANDS_URL=http://127.0.0.1:8066
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

declare -A TOKEN ID

# api <user> <method> <path> [json]
api() {
    local user=$1 method=$2 path=$3 body=${4:-}
    local args=(-sS -m 30 --fail-with-body -X "$method" -H "Authorization: Bearer ${TOKEN[$user]}")
    [ -n "$body" ] && args+=(-H 'Content-Type: application/json' --data-binary "$body")
    curl "${args[@]}" "$API$path" || { echo; echo "seed: $method $path failed" >&2; exit 1; }
}

# upload <user> <path> <curl -F args...>
upload() {
    local user=$1 path=$2
    shift 2
    curl -sS -m 60 --fail-with-body -H "Authorization: Bearer ${TOKEN[$user]}" "$@" "$API$path" \
        || { echo; echo "seed: upload $path failed" >&2; exit 1; }
}

login() {
    local user=$1
    local token
    token=$(curl -sS -m 30 -D - -o /dev/null -X POST "$API/users/login" \
        --data-binary "$(jq -n --arg u "$user" --arg p "$PASSWORD" '{login_id:$u,password:$p}')" \
        | awk 'tolower($1)=="token:" {print $2}' | tr -d '\r')
    [ -n "$token" ] || return 1
    TOKEN[$user]=$token
    ID[$user]=$(api "$user" GET /users/me | jq -r .id)
}

# user <name> <first> <last> <position> <avatar colour>
user() {
    local name=$1 first=$2 last=$3 position=$4 colour=$5
    curl -sS -m 30 --fail-with-body -X POST "$API/users" -H 'Content-Type: application/json' \
        --data-binary "$(jq -n --arg u "$name" --arg p "$PASSWORD" --arg f "$first" --arg l "$last" --arg pos "$position" \
            '{username:$u, email:($u+"@example.test"), password:$p, first_name:$f, last_name:$l, position:$pos}')" >/dev/null
    login "$name"
    node make-png.js "$TMP/$name.png" "$colour" 128
    upload "$name" "/users/${ID[$name]}/image" -F "image=@$TMP/$name.png" >/dev/null
    echo "seed: user $name"
}

team() { # team <name> <display name> -> id
    api admin POST /teams "$(jq -n --arg n "$1" --arg d "$2" '{name:$n, display_name:$d, type:"O"}')" | jq -r .id
}

team_add() { # team_add <team id> <users...>
    local team=$1
    shift
    for u in "$@"; do
        api admin POST "/teams/$team/members" "$(jq -n --arg t "$team" --arg u "${ID[$u]}" '{team_id:$t, user_id:$u}')" >/dev/null
    done
}

channel() { # channel <team id> <name> <display> <O|P> <purpose> <header> -> id
    api admin POST /channels "$(jq -n --arg t "$1" --arg n "$2" --arg d "$3" --arg ty "$4" --arg p "$5" --arg h "$6" \
        '{team_id:$t, name:$n, display_name:$d, type:$ty, purpose:$p, header:$h}')" | jq -r .id
}

channel_add() { # channel_add <channel id> <users...>
    local ch=$1
    shift
    for u in "$@"; do
        api admin POST "/channels/$ch/members" "$(jq -n --arg u "${ID[$u]}" '{user_id:$u}')" >/dev/null
    done
}

channel_by_name() { # channel_by_name <team id> <name> -> id
    api admin GET "/teams/$1/channels/name/$2" | jq -r .id
}

post() { # post <user> <channel id> <message> [extra json object] -> id
    local extra=${4:-'{}'}
    api "$1" POST /posts "$(jq -n --arg c "$2" --arg m "$3" --argjson e "$extra" '{channel_id:$c, message:$m} + $e')" | jq -r .id
}

react() { # react <user> <post id> <emoji name>
    api "$1" POST /reactions "$(jq -n --arg u "${ID[$1]}" --arg p "$2" --arg e "$3" '{user_id:$u, post_id:$p, emoji_name:$e}')" >/dev/null
}

view() { # view <user> <channel id>
    api "$1" POST "/channels/members/${ID[$1]}/view" "$(jq -n --arg c "$2" '{channel_id:$c}')" >/dev/null
}

if login admin 2>/dev/null; then
    echo "seed: server already seeded (admin can log in). Use: server.sh reset" >&2
    exit 1
fi

# The first account on a fresh server becomes the system admin.
user admin Ada Admin "Keeper of the server" 3b5bdb
user alice Alice Archer "Backend" c2255c
user bob Bob Brook "Design" 2b8a3e
user carol Carol Cheng "Mobile" e8590c
user dave Dave Duarte "Ops" 1971c2
user erin Erin Eide "Support" 862e9c

LIGHTHOUSE=$(team lighthouse "Lighthouse Crew")
HARBOR=$(team harbor "Harbor Side")
team_add "$LIGHTHOUSE" alice bob carol dave erin
team_add "$HARBOR" alice bob
echo "seed: teams"

TOWN=$(channel_by_name "$LIGHTHOUSE" town-square)
OFFTOPIC=$(channel_by_name "$LIGHTHOUSE" off-topic)
ENG=$(channel "$LIGHTHOUSE" engineering Engineering O "Everything about building the thing" "Standup 09:30 · [Board](https://example.test/board) · :lighthouse:")
DESIGN=$(channel "$LIGHTHOUSE" design Design O "Mockups, reviews, pixels" "")
LINKS=$(channel "$LIGHTHOUSE" random-links "Random Links" O "Things worth reading" "")
NIGHT=$(channel "$LIGHTHOUSE" night-watch "Night Watch" P "On-call coordination" "Rotation: see pinned")
OLD=$(channel "$LIGHTHOUSE" old-projects "Old Projects" O "Archive of finished work" "")
DOCK=$(channel "$HARBOR" dock-ops "Dock Ops" O "Harbor logistics" "")
channel_add "$ENG" alice bob carol dave erin
channel_add "$DESIGN" alice bob carol
channel_add "$LINKS" alice bob dave erin
channel_add "$NIGHT" alice bob
channel_add "$OLD" alice carol
channel_add "$DOCK" alice bob
echo "seed: channels"

DM_AB=$(api alice POST /channels/direct "$(jq -n --arg a "${ID[alice]}" --arg b "${ID[bob]}" '[$a,$b]')" | jq -r .id)
DM_AC=$(api alice POST /channels/direct "$(jq -n --arg a "${ID[alice]}" --arg b "${ID[carol]}" '[$a,$b]')" | jq -r .id)
DM_BD=$(api bob POST /channels/direct "$(jq -n --arg a "${ID[bob]}" --arg b "${ID[dave]}" '[$a,$b]')" | jq -r .id)
GM_ABC=$(api alice POST /channels/group "$(jq -n --arg a "${ID[alice]}" --arg b "${ID[bob]}" --arg c "${ID[carol]}" '[$a,$b,$c]')" | jq -r .id)

# Custom emoji
node make-png.js "$TMP/lighthouse.png" f08c00 128
node make-png.js "$TMP/anchor-party.png" 0c8599 128
for name in lighthouse anchor-party; do
    upload admin /emoji -F "image=@$TMP/$name.png" \
        -F "emoji=$(jq -n --arg n "$name" --arg c "${ID[admin]}" '{name:$n, creator_id:$c}')" >/dev/null
done
echo "seed: custom emoji"

# Slash commands answered by commands/responder.js
for spec in "shout|Shout|Shout text back into the channel|[text]" "lunch|Lunch dialog|Open an interactive dialog|"; do
    IFS='|' read -r trigger display desc hint <<<"$spec"
    api admin POST /commands "$(jq -n --arg t "$LIGHTHOUSE" --arg tr "$trigger" --arg d "$display" --arg desc "$desc" --arg h "$hint" --arg u "$COMMANDS_URL/$trigger" \
        '{team_id:$t, trigger:$tr, method:"P", url:$u, auto_complete:true, auto_complete_desc:$desc, auto_complete_hint:$h, display_name:$d, description:$desc}')" >/dev/null
done
echo "seed: slash commands"

# Welcome and announcements
WELCOME=$(post admin "$TOWN" "Welcome to the Lighthouse Crew. This server is a local test instance; everything here is invented. :lighthouse:")
post admin "$TOWN" "@channel Reminder: the release branch freezes on Friday. Open questions go to ~engineering." >/dev/null
post admin "$TOWN" "Pinned messages, custom emoji, threads, files and slash commands are all set up. Try \`/shout hello\` and \`/lunch\`." >/dev/null
api admin POST "/posts/$WELCOME/pin" >/dev/null

# Markdown showcase in engineering
post alice "$ENG" "$(cat <<'EOF'
# Release 1.2 notes

## What changed
- Faster channel switching
- **Bold**, *italic*, ~~struck~~, `inline code` and a [link](https://example.test/notes)
- Bare URL: https://example.test/changelog
- Nested list
  1. first
  2. second

## Checklist
- [x] migrations
- [ ] docs
- [ ] announce in ~design

> Ship it only when the checklist is done. — @bob

| Area | Owner | Status |
| --- | --- | --- |
| API | @alice | done |
| UI | @carol | in review |
| Infra | @dave | blocked |

```dart
Future<void> main() async {
  final client = Client(baseUrl: Uri.parse('https://example.test'));
  print(await client.ping());
}
```

Inline math $E = mc^2$ and a block:

```latex
\int_0^1 x^2 \, dx = \frac{1}{3}
```

Tags #release #v1-2 and emoji :tada: :anchor-party: :lighthouse:
EOF
)" >/dev/null

post bob "$ENG" "Short one with just an emoji :+1:" >/dev/null
post carol "$ENG" "A very long line without breaks to check wrapping: the quick brown fox jumps over the lazy dog again and again and again and again and again and again and again and again until the line finally wraps around on even the widest tablet screen." >/dev/null
post dave "$ENG" "@alice the infra job failed again, see https://example.test/jobs/4711" >/dev/null
post admin "$ENG" "Urgent: rotate the staging credentials today." "$(jq -n '{metadata:{priority:{priority:"urgent", requested_ack:false}}}')" >/dev/null
post admin "$ENG" "Important: design review moved to 15:00." "$(jq -n '{metadata:{priority:{priority:"important", requested_ack:false}}}')" >/dev/null
EDITED=$(post erin "$ENG" "Typo incomming")
api erin PUT "/posts/$EDITED/patch" "$(jq -n '{message:"Typo incoming, now fixed"}')" >/dev/null

# Files
node make-png.js "$TMP/photo-wide.png" 5c940d 640
node make-png.js "$TMP/photo-small.png" 9c36b5 240
printf 'release checklist\n- migrations\n- docs\n' >"$TMP/checklist.txt"
FILES=$(upload carol "/files?channel_id=$ENG" -F "files=@$TMP/photo-wide.png" -F "files=@$TMP/photo-small.png" -F "files=@$TMP/checklist.txt" | jq -c '[.file_infos[].id]')
post carol "$ENG" "Screenshots and the checklist:" "$(jq -n --argjson f "$FILES" '{file_ids:$f}')" >/dev/null
echo "seed: posts with files"

# A long thread; alice reads up to the middle so a "new messages" line appears.
ROOT=$(post alice "$ENG" "Thread: should we batch the sync requests? Thoughts welcome.")
i=0
for u in bob carol dave erin alice bob carol dave erin alice bob carol dave erin alice; do
    i=$((i + 1))
    post "$u" "$ENG" "Reply $i: $(case $((i % 3)) in 0) echo "batching saves requests but delays the first paint";; 1) echo "we could coalesce identical in-flight calls instead";; *) echo "measure first, then decide";; esac)" "$(jq -n --arg r "$ROOT" '{root_id:$r}')" >/dev/null
done
react bob "$ROOT" +1
react carol "$ROOT" +1
react dave "$ROOT" tada
react erin "$ROOT" lighthouse
react alice "$ROOT" anchor-party
view alice "$ENG"
for u in bob carol dave erin bob carol dave erin bob carol; do
    i=$((i + 1))
    post "$u" "$ENG" "Reply $i: agreed, let's try it on the channel list first" "$(jq -n --arg r "$ROOT" '{root_id:$r}')" >/dev/null
done
post bob "$ENG" "@alice summary of the thread is in the last reply" >/dev/null
echo "seed: thread"

# Saved for alice, pinned in night-watch, header change (system message)
api alice PUT "/users/${ID[alice]}/preferences" "$(jq -n --arg u "${ID[alice]}" --arg p "$ROOT" '[{user_id:$u, category:"flagged_post", name:$p, value:"true"}]')" >/dev/null
ROTA=$(post bob "$NIGHT" "On-call rotation: Mon alice · Tue bob · Wed alice · Thu bob · Fri alice")
api bob POST "/posts/$ROTA/pin" >/dev/null
post bob "$NIGHT" "@alice can you swap Wednesday?" >/dev/null
api admin PUT "/channels/$DESIGN/patch" "$(jq -n '{header:"Figma links in pinned · reviews on Tuesdays"}')" >/dev/null
post bob "$DESIGN" "@alice the new icon set is ready for review" >/dev/null
post carol "$DESIGN" "Spacing looks off on the channel rows, 12 instead of 16" >/dev/null
post dave "$LINKS" "Worth a read: https://example.test/articles/cache-first" >/dev/null
post erin "$LINKS" "@alice this one is about you :smile:" >/dev/null

# Direct and group messages
post bob "$DM_AB" "Hey Alice, got a minute?" >/dev/null
post alice "$DM_AB" "Sure, what's up?" >/dev/null
post bob "$DM_AB" "The release notes need a second pair of eyes." >/dev/null
post carol "$DM_AC" "Lunch at 12?" >/dev/null
post dave "$DM_BD" "Bob, the dock is ready." >/dev/null
post carol "$GM_ABC" "Group: who is on the demo tomorrow?" >/dev/null
post bob "$GM_ABC" "I can do it." >/dev/null

# Bot and webhook posts
BOT=$(api admin POST /bots "$(jq -n '{username:"helper-bot", display_name:"Helper", description:"Answers questions"}')" | jq -r .user_id)
BOT_TOKEN=$(api admin POST "/users/$BOT/tokens" "$(jq -n '{description:"seed"}')" | jq -r .token)
TOKEN[helper-bot]=$BOT_TOKEN
ID[helper-bot]=$BOT
api admin POST "/teams/$LIGHTHOUSE/members" "$(jq -n --arg t "$LIGHTHOUSE" --arg u "$BOT" '{team_id:$t, user_id:$u}')" >/dev/null
post helper-bot "$TOWN" "I am a bot account. Mention me with a question." >/dev/null
HOOK=$(api admin POST /hooks/incoming "$(jq -n --arg c "$TOWN" '{channel_id:$c, display_name:"Deploys", description:"Deployment notices"}')" | jq -r .id)
curl -sS -m 30 --fail-with-body -X POST "$URL/hooks/$HOOK" -H 'Content-Type: application/json' \
    --data-binary "$(jq -n '{text:"Deployed **v1.2.0** to staging :rocket:", username:"Deploy Bot"}')" >/dev/null
echo "seed: bot and webhook"

# Filler for scrolling
for n in $(seq 1 150); do
    u=$(case $((n % 5)) in 0) echo alice;; 1) echo bob;; 2) echo carol;; 3) echo dave;; *) echo erin;; esac)
    post "$u" "$OFFTOPIC" "Off-topic message $n of 150. $(case $((n % 4)) in 0) echo "Coffee is ready. :coffee:";; 1) echo "Anyone up for a walk at lunch?";; 2) echo "Reminder: plants need water.";; *) echo "Nice weather today.";; esac)" >/dev/null
done
echo "seed: 150 filler posts"

# Second team and an archived channel
post alice "$DOCK" "Harbor team: the crane schedule is on the board." >/dev/null
post bob "$DOCK" "Noted." >/dev/null
post carol "$OLD" "This channel is archived; nothing new happens here." >/dev/null
api admin DELETE "/channels/$OLD" >/dev/null

# Statuses, custom status, sidebar preferences for alice
api bob PUT "/users/${ID[bob]}/status" "$(jq -n --arg u "${ID[bob]}" '{user_id:$u, status:"away"}')" >/dev/null
api carol PUT "/users/${ID[carol]}/status" "$(jq -n --arg u "${ID[carol]}" '{user_id:$u, status:"dnd", dnd_end_time:0}')" >/dev/null
api dave PUT "/users/${ID[dave]}/status/custom" "$(jq -n '{emoji:"palm_tree", text:"On holiday until Monday"}')" >/dev/null
api alice PUT "/users/${ID[alice]}/preferences" "$(jq -n --arg u "${ID[alice]}" --arg c "$ENG" '[{user_id:$u, category:"favorite_channel", name:$c, value:"true"}]')" >/dev/null
api alice PUT "/channels/$LINKS/members/${ID[alice]}/notify_props" "$(jq -n --arg u "${ID[alice]}" --arg c "$LINKS" '{user_id:$u, channel_id:$c, mark_unread:"mention"}')" >/dev/null
api alice POST "/users/${ID[alice]}/teams/$LIGHTHOUSE/channels/categories" "$(jq -n --arg u "${ID[alice]}" --arg t "$LIGHTHOUSE" --arg a "$DESIGN" --arg b "$NIGHT" \
    '{user_id:$u, team_id:$t, display_name:"Projects", type:"custom", channel_ids:[$a,$b]}')" >/dev/null
echo "seed: statuses and preferences"

# A long channel for paging, a public channel alice has not joined, a PDF and
# a thread inside a direct message.
FIREHOSE=$(channel "$LIGHTHOUSE" firehose Firehose O "Bot chatter, 1200 messages" "")
channel_add "$FIREHOSE" alice bob carol helper-bot
for n in $(seq 1 1200); do
    u=$(case $((n % 3)) in 0) echo bob;; 1) echo carol;; *) echo helper-bot;; esac)
    post "$u" "$FIREHOSE" "Firehose line $n: $(case $((n % 5)) in 0) echo "build passed";; 1) echo "deploy queued";; 2) echo "metrics nominal";; 3) echo "cache warmed";; *) echo "heartbeat";; esac)" >/dev/null
done
echo "seed: 1200 firehose posts"
OPENMIC=$(channel "$LIGHTHOUSE" open-mic "Open Mic" O "Anyone can join; alice has not" "")
channel_add "$OPENMIC" bob dave
post bob "$OPENMIC" "Welcome to the open mic, join if you dare." >/dev/null
printf "%%PDF-1.4\n1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj\n2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj\n3 0 obj<</Type/Page/Parent 2 0 R/MediaBox[0 0 300 144]/Contents 4 0 R/Resources<</Font<</F1 5 0 R>>>>>>endobj\n4 0 obj<</Length 60>>stream\nBT /F1 24 Tf 24 80 Td (Crew handbook, page 1) Tj ET\nendstream\nendobj\n5 0 obj<</Type/Font/Subtype/Type1/BaseFont/Helvetica>>endobj\ntrailer<</Root 1 0 R>>\n" >"$TMP/handbook.pdf"
PDF=$(upload bob "/files?channel_id=$ENG" -F "files=@$TMP/handbook.pdf;type=application/pdf" | jq -c "[.file_infos[].id]")
post bob "$ENG" "The crew handbook as PDF:" "$(jq -n --argjson f "$PDF" "{file_ids:\$f}")" >/dev/null
DMROOT=$(post bob "$DM_AB" "Thread in a DM: lunch plans?")
post alice "$DM_AB" "Noodles?" "$(jq -n --arg r "$DMROOT" "{root_id:\$r}")" >/dev/null
post bob "$DM_AB" "Noodles it is." "$(jq -n --arg r "$DMROOT" "{root_id:\$r}")" >/dev/null
echo "seed: extras"

# Media: five images (one larger than the server's 1920 px preview), an
# animated GIF, a video when the Android SDK's sample clip is there, and an
# archive no viewer opens.
MEDIA=$(channel "$LIGHTHOUSE" media Media O "Pictures, clips and files" "")
channel_add "$MEDIA" alice bob carol
for c in 1864ab 2b8a3e e67700 c2255c 5f3dc4; do node make-png.js "$TMP/shot-$c.png" "$c" 320; done
node make-png.js "$TMP/poster.png" 0b7285 2400
IMAGES=$(upload carol "/files?channel_id=$MEDIA" -F "files=@$TMP/poster.png" \
    $(for c in 1864ab 2b8a3e e67700 c2255c; do echo "-F files=@$TMP/shot-$c.png"; done) | jq -c '[.file_infos[].id]')
post carol "$MEDIA" "Five pictures from the harbour walk" "$(jq -n --argjson f "$IMAGES" '{file_ids:$f}')" >/dev/null
node make-gif.js "$TMP/blink.gif" e8590c 1971c2 96
GIF=$(upload bob "/files?channel_id=$MEDIA" -F "files=@$TMP/blink.gif" | jq -c '[.file_infos[].id]')
post bob "$MEDIA" "The beacon blinks again" "$(jq -n --argjson f "$GIF" '{file_ids:$f}')" >/dev/null
CLIP="${ANDROID_HOME:-}/emulator/resources/default.mp4"
if [ -f "$CLIP" ]; then
    VIDEO=$(upload alice "/files?channel_id=$MEDIA" -F "files=@$CLIP;filename=harbour-clip.mp4;type=video/mp4" | jq -c '[.file_infos[].id]')
    post alice "$MEDIA" "A short clip" "$(jq -n --argjson f "$VIDEO" '{file_ids:$f}')" >/dev/null
fi
head -c 20000 /dev/urandom >"$TMP/logs.zip"
ZIP=$(upload bob "/files?channel_id=$MEDIA" -F "files=@$TMP/logs.zip;type=application/zip" -F "files=@$TMP/checklist.txt" | jq -c '[.file_infos[].id]')
post bob "$MEDIA" "Logs and the checklist again" "$(jq -n --argjson f "$ZIP" '{file_ids:$f}')" >/dev/null
echo "seed: media"

cat <<EOF

seed: done. Server: $URL (emulator: http://10.0.2.2:8065)
  users: admin (system admin), alice, bob, carol, dave, erin — password "$PASSWORD"
  teams: lighthouse (all), harbor (alice, bob)
  commands: /shout <text>, /lunch
EOF
