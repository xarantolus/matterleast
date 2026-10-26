# Matterleast
Matterleast is an Android app for [Mattermost](https://mattermost.com) servers. It opens instantly with what it saved last time, refreshes in the background and keeps working when you're offline. You can use several servers and teams side by side.

It is an independent rebuild of the official [Mattermost mobile app](https://github.com/mattermost/mattermost-mobile) in Flutter and talks to any standard Mattermost server.


### Features
- Several servers and teams in one rail, with sign-in by password, LDAP, multi-factor authentication or single sign-on
- A Home inbox across all servers for unread messages, mentions, threads and saved messages
- Channel list with your categories, unread and mention badges, an unreads filter, drafts and followed threads
- Messages with full Mattermost formatting: code with highlighting, tables, LaTeX, emoji and custom emoji, link and permalink previews
- Images, videos, PDFs and other files in a gallery; send photos, files and things shared from other apps
- Threads, reactions, replies, quotes, edits, pins, saved messages and reminders
- A composer with drafts, suggestions for @people, ~channels, :emoji: and /commands, message priority and scheduled messages
- Bots and integrations: interactive buttons and menus, dialogs, and the Agents plugin with streamed answers
- Search messages and files with filters, and jump to any channel or person from one search field
- Browse, join, create and manage channels; direct and group messages
- Presence, custom status, your profile and other people's profiles
- Notifications without Google's push service: the app checks for direct messages, mentions and replies in the background, or stays connected if you turn that on. Reply and mark as read right from the notification
- No internet? No problem! Saved messages stay readable and what you send is queued until you're back online
- Two or three panes side by side on tablets and in landscape
- Matterleast colours, your Mattermost theme or your wallpaper colours (Material You), dark mode and adjustable text size
- Trust a private certificate authority for a self-hosted server

Features that need a server setting, a plugin or a licence (bookmarks, custom profile attributes, burn-on-read messages, scheduled messages, the Agents plugin) only show up when your server offers them.

### What's not included
Calls, Playbooks and Boards are not supported. Notifications don't go through Mattermost's push proxy, so new messages arrive when the app checks (about every 15 minutes) unless "Stay connected" is on in the notification settings.

### Credits
Matterleast follows the behaviour of the official [Mattermost mobile app](https://github.com/mattermost/mattermost-mobile) and uses the [Mattermost API](https://developers.mattermost.com/api-documentation/). It is not affiliated with or endorsed by Mattermost, Inc. See [NOTICE](NOTICE) for third-party data.


### Installation & updates
[Download the APK file from the releases section of this repository](https://github.com/xarantolus/matterleast-client/releases/latest), then open it from the file manager to install it. It needs Android 7.0 or newer on an ARM phone. You won't get update notifications this way; you can watch this repository to get notified about releases.


### Development
Everything builds inside the dev container (Flutter, Android SDK, a headless emulator and a local Mattermost test server). See [`.devcontainer/README.md`](.devcontainer/README.md) and [docs/releasing.md](docs/releasing.md).

```sh
./run-container.sh
```


### [License](LICENSE)
This is free as in freedom software. Do whatever you like with it.
