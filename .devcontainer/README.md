# Dev container (Flutter + Android)

A self-contained Android build environment for this app, plus the Claude Code
CLI so an agent can work inside it.

## What's in the image

| Component | Version |
| --- | --- |
| Flutter | 3.47.8 stable (Dart 3.13.7) |
| JDK | 17 (headless) — required by AGP 9 / Gradle 9 |
| Android SDK | platforms 37.0 + 36 + 34, build-tools 37.0.0 + 36.0.0 + 34.0.0, NDK 28.2, CMake 3.22.1, platform-tools, emulator |
| Node | 20 |
| Claude Code | latest at build time (`claude` on `PATH`) |

Base image is `ubuntu:24.04`. Android build artifacts are pre-cached
(`flutter precache --android`), so the first build in a fresh container doesn't
re-download them.

`flutter doctor` reports "Android license status unknown": recent command-line
tools dropped `sdkmanager --licenses`, and the check is stale. Builds work.

## Running it

VS Code: "Reopen in Container". Otherwise:

```sh
./run-container.sh [extra podman run args]
```

The container runs as **root**; with rootless podman the default mapping keeps
files owned by your host user. It deliberately avoids `--userns=keep-id`, which
fails at create on some podman stores, and would otherwise run as a UID that
does not own `/root` or the cache volumes.

Flutter's "running as root" warning is suppressed by the `/.dockerenv` marker
the image creates — podman doesn't add it, and Flutter uses it to detect that
root is expected here.

## Persistence

- Claude Code state is bind-mounted to `/root/.claude` with
  `CLAUDE_CONFIG_DIR=/root/.claude`, so sessions and config survive rebuilds.
  Sessions are keyed by the in-container path, so keep the workspace at
  `/workspaces/matterleast` for `claude --resume` to find them.
- Gradle (`/root/.gradle`) and pub (`/root/.pub-cache`) caches live on named
  volumes.

## Emulator

The image ships a headless x86_64 AVD (`matterleast`, android-36) and the
`mobile-mcp` server. Start the device, then interact with it over MCP or adb:

```sh
.devcontainer/emulator.sh start
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb exec-out screencap -p > shot.png
.devcontainer/emulator.sh stop
```

This needs `/dev/kvm` inside the container, which `run-container.sh` passes
through; the host user needs to be in the `kvm` group. AVDs are
stored on a volume so extra API levels persist.

## Local Mattermost server

`server/server.sh start` runs a throwaway Mattermost server with podman inside
the dev container, seeded with invented users and content; see
[`server/README.md`](server/README.md). The emulator reaches it at
`http://10.0.2.2:8065`. This is why `run-container.sh` passes `--cap-add
SYS_ADMIN --security-opt unmask=ALL --device /dev/fuse` and a volume for
`/var/lib/containers`.

## Building the app

```sh
flutter build apk --debug     # debug keystore, works out of the box
```

`flutter build apk --release` needs signing material that is not in the repo:
`android/key.properties` (`storePassword`, `keyAlias`, `keyPassword`) plus
either a `storeFile` line in it or the `X_KEYSTORE_PATH` environment variable.
See "Release signing" in the [README](../README.md).
