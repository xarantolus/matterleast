# Local Mattermost test server

A throwaway Mattermost Team Edition server for development and tests, run with
podman *inside* the dev container. It listens on the loopback only, so the
emulator reaches it at `http://10.0.2.2:8065` and nothing is exposed on the
network. Everything on it is invented.

```sh
.devcontainer/server/server.sh start    # create or start, seed on first start
.devcontainer/server/server.sh status
.devcontainer/server/server.sh logs     # or: logs db | logs commands
.devcontainer/server/server.sh stop
.devcontainer/server/server.sh reset    # delete all data, start and seed again
```

## What runs

| Container | Image | Purpose |
| --- | --- | --- |
| `matterleast-db` | `postgres:17-alpine` | database, on volume `matterleast-db-data` |
| `matterleast-server` | `mattermost/mattermost-team-edition:12.0.1` | the server; settings in `mattermost.env` |
| `matterleast-commands` | `node:22-alpine` | answers the custom slash commands (`commands/responder.js`) |

All three use host networking. The image store lives on the
`matterleast-containers` volume of the dev container, so images survive a
container restart; `reset` only deletes the server's data volumes.

## Seeded content (`seed.sh`)

Password for every user: `matterleast`.

- Users: `admin` (system admin), `alice`, `bob`, `carol`, `dave`, `erin`, each
  with a coloured avatar; a bot `helper-bot`; an incoming webhook posting as
  "Deploy Bot".
- Teams: `lighthouse` (everyone) and `harbor` (alice, bob).
- Channels in lighthouse: `town-square`, `off-topic` (150 filler posts),
  `engineering` (markdown showcase, a 25-reply thread with reactions, files,
  priority posts, an edited post), `design`, `random-links` (muted for alice),
  `night-watch` (private, pinned post), `old-projects` (archived). DMs and a
  group message for alice.
- For alice: unread channels and mentions in several channels, a half-read
  thread, a saved post, a favourite channel and a custom sidebar category.
- Custom emoji `:lighthouse:` and `:anchor-party:`.
- Slash commands `/shout <text>` and `/lunch` (opens an interactive dialog).
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
