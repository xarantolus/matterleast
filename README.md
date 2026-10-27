# Matterleast
Matterleast is an unofficial Android app for [Mattermost](https://mattermost.com) servers that tries to feel closer to Discord than to a classic team chat. All your servers and teams sit in one rail, and chats slide in over the channel list and away again with a swipe.

### Features
- Discord-style navigation: a rail with every server and team, swipe a chat away to the channel list and swipe it back
- One Home inbox across all servers for unread messages, mentions, threads and saved messages
- Notifications without Google's push service: the app checks in the background, or stays connected if you turn that on, and you can reply or mark as read from the notification
- Two or three panes side by side on tablets and in landscape
- Matterleast colours, your Mattermost theme or your wallpaper colours (Material You)

Everything else you'd expect from Mattermost is there too: threads, reactions, files, search, custom emoji, bots, channel management and more.

[**Download the latest APK**](https://github.com/xarantolus/matterleast/releases/latest/download/matterleast.apk) (Android 7.0 or newer, ARM phones). There are no update notifications; watch this repository's releases to hear about new versions.

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

Generated code is committed; after changing models, providers or the database, run `dart run build_runner build`. There is also a dev container with Flutter, the Android SDK, an emulator and a local Mattermost test server, see [`.devcontainer/README.md`](.devcontainer/README.md).

### Limitations
- Calls, Playbooks and Boards are not supported, nor are Apps framework forms and message translation.
- Notifications don't go through Mattermost's push proxy, so new messages arrive when the app checks (about every 15 minutes) unless "Stay connected" is on.
- Android only; there is no iOS or desktop version.
- Features that need a server setting, a plugin or a licence only show up when your server offers them.

### License
Matterleast is licensed under the [Apache License 2.0](LICENSE), the same licence as the official [Mattermost mobile app](https://github.com/mattermost/mattermost-mobile), whose behaviour it rebuilds without using its code. Third-party packages keep their own licences. The emoji table comes from Mattermost's emoji data (Apache 2.0), which is based on [emoji-data](https://github.com/iamcal/emoji-data) (MIT). The REST client is generated from the structure of Mattermost's published API description; none of its documentation text is included. Details are in [NOTICE](NOTICE).

Mattermost is a trademark of Mattermost, Inc. Matterleast is not affiliated with or endorsed by Mattermost, Inc., and the licence grants no rights to the Mattermost name or logo.
