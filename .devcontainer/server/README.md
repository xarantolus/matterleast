# Local Mattermost test server

A throwaway Mattermost Team Edition server for development and tests, run with
podman *inside* the dev container. It listens on the loopback only, so the
emulator reaches it at `http://10.0.2.2:8065` and nothing is exposed on the
network. Everything on it is invented.

```sh
.devcontainer/server/server.sh start           # create or start, seed on first start
.devcontainer/server/server.sh start --second  # also a second server on port 8067
.devcontainer/server/server.sh status
.devcontainer/server/server.sh logs            # or: logs db | logs server2 | logs commands
.devcontainer/server/server.sh stop
.devcontainer/server/server.sh reset           # delete all data, start and seed again
```

## What runs

| Container | Image | Purpose |
| --- | --- | --- |
| `matterleast-db` | `postgres:17-alpine` | database, on volume `matterleast-db-data` |
| `matterleast-server` | `mattermost/mattermost-team-edition:12.0.1` | the server on port 8065; settings in `mattermost.env` |
| `matterleast-server2` | same | optional second server on port 8067 with its own database, for multi-server tests |
| `matterleast-commands` | `node:22-alpine` | side services on port 8066: the custom slash commands and a fake GitLab for SSO (`commands/responder.js`) |

All use host networking on the loopback. Containers and data volumes survive a
dev-container restart, so `start` just brings them back; the image store
lives on the `matterleast-containers` volume. `reset` deletes the data
volumes and seeds again.

## SSO

GitLab login is enabled and points at the fake provider, which approves every
login as the invented user `sso-sam`. Opening
`http://10.0.2.2:8065/oauth/gitlab/mobile_login?redirect_to=mmauth://callback`
in the emulator's browser ends on the server's "Authentication complete" page,
which redirects to `mmauth://callback?MMAUTHTOKEN=…&srv=…`, the same flow a
real provider produces.

## Seeded content (`seed.sh`)

Password for every user: `matterleast`.

- Users: `admin` (system admin), `alice`, `bob`, `carol`, `dave`, `erin`, each
  with a coloured avatar; a bot `helper-bot`; an incoming webhook posting as
  "Deploy Bot".
- Teams: `lighthouse` (everyone) and `harbor` (alice, bob).
- Channels in lighthouse: `town-square`, `off-topic` (150 filler posts),
  `engineering` (markdown showcase, a 25-reply thread with reactions, files
  including a PDF, priority posts, an edited post), `design`, `random-links`
  (muted for alice), `night-watch` (private, pinned post), `old-projects`
  (archived), `firehose` (1,200 posts for paging), `open-mic` (public, alice
  is not a member). DMs with a thread and a group message for alice.
- For alice: unread channels and mentions in several channels, a half-read
  thread, a saved post, a favourite channel and a custom sidebar category.
- Custom emoji `:lighthouse:` and `:anchor-party:`.
- Slash commands `/shout <text>`, `/lunch` (opens an interactive dialog) and
  `/blocks attachment|blockkit|card|mmblocks`: helper-bot posts interactive
  content in that format (message attachments, Slack Block Kit, Adaptive
  Cards, MM Blocks). Its buttons and menus are answered by the responder:
  Approve updates the post, Ping me and the menus send an ephemeral reply,
  Open form returns a trigger id and opens the lunch dialog, Docs sends the
  app to a page. Only a bot's or a webhook's post may carry the
  `mm_blocks_actions` the server needs for the non-attachment formats, so
  the responder signs in as the invented admin and makes helper-bot a token.
- Statuses: bob away, carol do-not-disturb, dave with a custom status.

Not available without a licence (the server answers 501): post
acknowledgements, SAML/LDAP/most SSO providers. GitLab SSO and MFA are free.

## How the nested podman works

The dev container is itself a rootless podman container. Podman inside it runs
rootful and needs, from `run-container.sh`: `--cap-add SYS_ADMIN` (mount
namespaces), `--security-opt unmask=ALL` (a fresh `/proc` can't be mounted
while the outer `/proc` has masked paths), a volume at `/var/lib/containers`
(overlay storage can't sit on the container's own overlay root) and
`/dev/fuse` as a fallback. `containers.conf` disables cgroups (read-only
`/sys/fs/cgroup`) and uses the file event logger. Seccomp stays on and
`--privileged` is not needed.
