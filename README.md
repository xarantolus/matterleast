# Matterleast

A Flutter client for [Mattermost](https://mattermost.com) servers, modelled on
the official [mattermost-mobile](https://github.com/mattermost/mattermost-mobile)
app.

## Development

Everything builds inside the dev container (Flutter, Android SDK, headless
emulator). See [`.devcontainer/README.md`](.devcontainer/README.md).

```sh
./run-container.sh
```

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
