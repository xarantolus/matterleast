#!/bin/sh
# Xcode Cloud runs this after cloning: it installs Flutter at the version
# CI builds with, the app's packages and the pods, and writes the build
# settings Xcode reads. Generated Dart code is committed, so build_runner
# doesn't run here.
set -e

cd "$CI_PRIMARY_REPOSITORY_PATH"

version=$(grep -m1 -oE 'flutter-version: [0-9.]+' .github/workflows/android_build.yml | cut -d' ' -f2)
git clone https://github.com/flutter/flutter.git --depth 1 --branch "$version" "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

flutter precache --ios
flutter pub get

HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods

# Xcode Cloud's build number grows with every build, as TestFlight wants.
# Xcode Cloud signs when it archives; there is no certificate here yet.
flutter build ios --config-only --release --no-codesign \
    --build-number "${CI_BUILD_NUMBER:-1}"
