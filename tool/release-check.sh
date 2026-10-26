#!/usr/bin/env bash
# Builds the signed release APK the way CI does and prints its signer and
# size, as a check before bumping the version.
# Usage: tool/release-check.sh <keystore>
# The passwords and alias come from android/key.properties.
set -euo pipefail
cd "$(dirname "$0")/.."
if [ $# -ne 1 ] || [ ! -f "$1" ]; then
    echo "Usage: $0 <keystore>" >&2
    exit 2
fi
if [ ! -f android/key.properties ]; then
    echo "android/key.properties is missing (storePassword, keyPassword, keyAlias)." >&2
    exit 2
fi
keystore=$(realpath "$1")
apk=build/app/outputs/flutter-apk/app-release.apk
rm -f "$apk"
X_KEYSTORE_PATH=$keystore flutter build apk --release --target-platform android-arm,android-arm64
apksigner=$(find "${ANDROID_HOME:?}/build-tools" -name apksigner | sort -V | tail -n 1)
"$apksigner" verify --print-certs "$apk" | grep -E 'certificate (DN|SHA-256)'
du -h "$apk"
