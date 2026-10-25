#!/usr/bin/env bash
# Build the dev image and drop into a shell with the repo mounted, Gradle/pub
# caches on volumes, and Claude Code state kept on the host. Any arguments are
# passed to `podman run`, e.g. extra read-only mounts of reference repos.
set -euo pipefail

cd "$(dirname "$0")"
IMAGE=matterleast-flutter-dev:latest
NAME=$(basename "$PWD")
REPO=/workspaces/$NAME
CLAUDE_STATE="$HOME/claude-state/$NAME"
mkdir -p "$CLAUDE_STATE"

podman build -f .devcontainer/Dockerfile -t "$IMAGE" .

args=(
  -it --rm
  # keep-id fails at create on this host's podman store; as root the default
  # rootless mapping already yields host-UID-owned files.
  --net=host
  -v "$PWD":"$REPO":Z
  -v "${NAME}-gradle":/root/.gradle
  -v "${NAME}-pub":/root/.pub-cache
  -v "${NAME}-avd":/root/.android
  # Podman inside the container (.devcontainer/server/): image store on a
  # volume (overlay can't sit on the container's own overlay root), SYS_ADMIN
  # for mount namespaces, unmasked /proc so a nested procfs can be mounted,
  # /dev/fuse for the fuse-overlayfs fallback.
  -v "${NAME}-containers":/var/lib/containers
  --cap-add SYS_ADMIN
  --cap-add SYS_PTRACE
  --security-opt unmask=ALL
  --security-opt label=disable
  --device /dev/fuse
  -e CLAUDE_CONFIG_DIR=/root/.claude
  --mount "type=bind,source=$CLAUDE_STATE,target=/root/.claude,consistency=cached"
  -w "$REPO"
)
# Emulator needs KVM. A shell started before you joined the kvm group won't have
# it, so re-exec through sg to pick it up.
if [ -e /dev/kvm ]; then
  if [ ! -r /dev/kvm ] || [ ! -w /dev/kvm ]; then
    if id -nG | grep -qw kvm || ! getent group kvm | grep -qw "$(id -un)"; then
      echo "warning: /dev/kvm not accessible; the emulator will not start" >&2
    else
      exec sg kvm -c "$(printf '%q ' "$0" "$@")"
    fi
  fi
  args+=(--device /dev/kvm --group-add keep-groups)
fi
if [ -d /dev/bus/usb ]; then
  args+=(--cap-add SYS_RAWIO --cap-add CAP_MKNOD --device /dev/bus/usb:/dev/bus/usb)
fi
[ -d "$HOME/.ssh" ] && args+=(--mount "type=bind,source=$HOME/.ssh,target=/root/.ssh,consistency=cached")
# gh credentials, so .ci-watch/ci-watch.sh can read Actions runs.
[ -d "$HOME/.config/gh" ] && args+=(--mount "type=bind,source=$HOME/.config/gh,target=/root/.config/gh,readonly")

exec podman run "${args[@]}" "$@" "$IMAGE" bash -c 'bash .devcontainer/post-create.sh; exec bash'
