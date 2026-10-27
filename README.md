# Matterleast
Matterleast is an unofficial Android client for [Mattermost](https://mattermost.com) servers that tries have a feel closer to Discord.

### Features
- Discord-style feel and navigation: you can swipe between chats, swipe on messages to react/reply etc.
- One Home inbox across all servers for unread messages, mentions, threads and saved messages
- Notifications without Google's push service via a background job
- Tablet layout in landscape
- Different theming options: Matterleast colours, your Mattermost theme or Material You

Other (obvious) features that exist: threads, reactions, file previews, sharing, search, custom emojis, bots, channel management and more.

[**Click here to download the latest APK**](https://github.com/xarantolus/matterleast/releases/latest/download/matterleast.apk) (Android 7.0 or newer, ARM phones). There are no update notifications; watch this repository's releases to hear about new versions.

### Screenshots (dark/light mode)
|                  Channel list                   |                  Conversation                   |                  Home inbox                   |
| :---------------------------------------------: | :---------------------------------------------: | :-------------------------------------------: |
| ![Channel list](.github/screenshots/d-list.jpg) | ![Conversation](.github/screenshots/d-chat.jpg) | ![Home inbox](.github/screenshots/d-home.jpg) |

|                  Channel list                   |                  Conversation                   |                  Home inbox                   |
| :---------------------------------------------: | :---------------------------------------------: | :-------------------------------------------: |
| ![Channel list](.github/screenshots/l-list.jpg) | ![Conversation](.github/screenshots/l-chat.jpg) | ![Home inbox](.github/screenshots/l-home.jpg) |

### Development
Matterleast is a Flutter app. [Install Flutter](https://docs.flutter.dev/get-started/install) with the Android toolchain, then:

```sh
git clone https://github.com/xarantolus/matterleast.git
cd matterleast
flutter pub get
flutter build apk --debug    # or: flutter run
```

Please commit generated code, and regenerate it after changing models, providers or the database. To do this, run `dart run build_runner build`.

There is also a dev container with Flutter, the Android SDK, an emulator and a local Mattermost test server, see [`.devcontainer/README.md`](.devcontainer/README.md).

### Limitations
- Calls, Playbooks and Boards are not supported, nor are Apps framework forms and message translation.
- Notifications don't go through Mattermost's push proxy, so new messages arrive when the app checks (about every 15 minutes) unless "Stay connected" is on.
- Android only; there is no iOS or desktop version. These are however possible to support in the future, as this is a Flutter app.
- Features that need a server setting, a plugin or a licence only show up when your server offers them.

### License
Matterleast is licensed under the [Apache License 2.0](LICENSE), the same licence as the official [Mattermost mobile app](https://github.com/mattermost/mattermost-mobile), whose behaviour it rebuilds without using its code.

The emoji table comes from Mattermost's emoji data (Apache 2.0), which is based on [emoji-data](https://github.com/iamcal/emoji-data) (MIT). The REST client is generated from the structure of Mattermost's published API description. Details are in [NOTICE](NOTICE).

Mattermost is a trademark of Mattermost, Inc. Matterleast is not affiliated with or endorsed by Mattermost, Inc., and the licence grants no rights to the Mattermost name or logo.
