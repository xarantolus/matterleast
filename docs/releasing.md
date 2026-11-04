# Releasing

## Release signing

CI builds a release APK signed with the upload key on every push, so a green
run is always a real release build. Debug builds need no keystore.

Create the upload keystore once and keep it (and its passwords) outside the
repo; an app update must be signed with the same key:

```sh
keytool -genkeypair -v -keystore upload-keystore.jks -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000
```

Write a `key.properties` next to it:

```properties
storePassword=<keystore password>
keyPassword=<key password>
keyAlias=upload
```

Set the two repository secrets from these files:

```sh
base64 -w0 upload-keystore.jks > keystore.b64
gh secret set SIGNING_KEYSTORE_CONTENT < keystore.b64
gh secret set SIGNING_PROPERTIES_CONTENT < key.properties
rm keystore.b64
```

CI decodes the keystore and passes its path as `X_KEYSTORE_PATH`, which wins
over a `storeFile` line in the properties. For local release builds, copy
`key.properties` to `android/key.properties` (gitignored) and either add
`storeFile=<path>` (relative paths are relative to `android/`) or set
`X_KEYSTORE_PATH`. `tool/release-check.sh <keystore>` builds the release APK
that way and prints its signer and size; install and open it before tagging,
since R8 problems only show at run time.

## Releases

A push to `main` whose `pubspec.yaml` version (without the build number) has
no `v<version>` tag yet publishes a GitHub release `v<version>` with the APK.
Its notes are the subjects of the commits since the previous tag. To release,
bump `version:` in `pubspec.yaml` (for example `0.1.0+1` to `0.2.0+2`) in its
own commit and push it.

## Profile builds

`tool/profile-build.sh` builds the arm64 profile APK and the Linux profile
bundle into `tmp/profile/` (`matterleast-profile.apk`,
`matterleast-linux-profile.tar.gz`) and prints their paths and SHA-256. The
APK is debug-signed and installs next to the normal app as
`Matterleast (profile)`. Pass `--widgets` to name widgets in the timeline
(`--dart-define=PROFILE_WIDGETS=true`); off by default, it floods the Linux ring buffer.

Only profile builds record (frame timings of the last 60 seconds, and the
VM timeline, which both profile builds keep whole through the engine's
`--endless-trace-buffer`, so memory grows while the app runs); release and debug builds contain none of it. To save a recording,
use the app, then long-press an app bar title on Android (it opens the share
sheet) or press Ctrl+Shift+P on Linux (it lands in Downloads). It writes
`matterleast-trace-*.json` and `matterleast-frames-*.csv`; open the trace in
https://ui.perfetto.dev.
