#!/usr/bin/env bash
# Builds the profile APK (arm64) and the Linux profile bundle into tmp/profile/.
# Usage: tool/profile-build.sh [--widgets]   (--widgets names widgets in the timeline)
set -euo pipefail
cd "$(dirname "$0")/.."
out=tmp/profile
defines=()
[ "${1:-}" = --widgets ] && defines=(--dart-define=PROFILE_WIDGETS=true)
mkdir -p "$out"
rm -f "$out"/matterleast-profile.apk "$out"/matterleast-linux-profile.tar.gz

flutter build apk --profile --target-platform android-arm64 "${defines[@]}"
cp build/app/outputs/flutter-apk/app-profile.apk "$out/matterleast-profile.apk"

flutter build linux --profile "${defines[@]}"
tar -czf "$out/matterleast-linux-profile.tar.gz" \
    -C build/linux/x64/profile/bundle .

for f in "$out"/matterleast-profile.apk "$out"/matterleast-linux-profile.tar.gz; do
    realpath "$f"
    sha256sum "$f"
done
