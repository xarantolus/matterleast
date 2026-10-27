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
  --net=host
  --security-opt label=disable
  -v "$PWD":"$REPO"
  -v "${NAME}-gradle":/root/.gradle
  -v "${NAME}-pub":/root/.pub-cache
  -v "${NAME}-avd":/root/.android
  -v "$CLAUDE_STATE":/root/.claude
  -e CLAUDE_CONFIG_DIR=/root/.claude
  -w "$REPO"
  # Podman inside the container (.devcontainer/server/): image store on a
  # volume (overlay can't sit on the container's own overlay root), SYS_ADMIN
  # for mount namespaces, unmasked /proc so a nested procfs can be mounted,
  # /dev/fuse for the fuse-overlayfs fallback.
  -v "${NAME}-containers":/var/lib/containers
  --cap-add SYS_ADMIN
  --cap-add SYS_PTRACE
  --security-opt unmask=ALL
  --device /dev/fuse
  # Each emulator runs ~200 threads; the default cap of 2048 fits about five
  # lanes next to Gradle and the Dart tools.
  --pids-limit 16384
)
# The emulator needs KVM, through the host user's kvm group.
if [ -e /dev/kvm ]; then
  [ -r /dev/kvm ] && [ -w /dev/kvm ] ||
    echo "warning: no access to /dev/kvm (join the kvm group and log in again); the emulator won't start" >&2
  args+=(--device /dev/kvm --group-add keep-groups)
fi
[ -d /dev/bus/usb ] && args+=(--cap-add SYS_RAWIO --cap-add MKNOD --device /dev/bus/usb)
[ -d "$HOME/.ssh" ] && args+=(-v "$HOME/.ssh":/root/.ssh)
# gh credentials, so .ci-watch/ci-watch.sh can read Actions runs.
[ -d "$HOME/.config/gh" ] && args+=(-v "$HOME/.config/gh":/root/.config/gh:ro)

exec podman run "${args[@]}" "$@" "$IMAGE" bash -c 'bash .devcontainer/post-create.sh; exec bash'
