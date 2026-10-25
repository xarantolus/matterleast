# Matterleast

A Flutter (Android first) client for Mattermost servers, rebuilding the
official mattermost-mobile app on the REST API v4 and the WebSocket API.

If `setup-specific-guide.md` and `CLAUDE.local.md` exist next to this file,
read them first. They hold the detailed working agreement and machine-local
notes, and they win over this summary.

## Working

- Research, then plan, then build. Agree on a written plan before anything
  that touches more than one file, including every state each screen can be
  in (empty, loading, cached, refreshing, failed with and without data).
- Ask only real decisions, with a recommendation. Measure instead of
  guessing.
- Verify every change on the emulator (`.devcontainer/emulator.sh`) and back
  it with screenshots. Report exactly what was and wasn't tested.
- Production quality, no shortcuts, but the simplest code that does the job.
- Keep the loop fast. Iterate on UI with hot reload against a running app;
  don't rebuild the APK or rerun the full gate after every small edit. Run
  the gate before committing.
- When there is a visual choice, show a few screenshots or quick mockups, or
  just ask. Don't spend long producing alternatives.

## Engineering

- Prefer maintained packages and stock Flutter widgets over hand-rolled code.
  Check maintenance, licence and SDK constraints on pub.dev when adding one.
- JSON is decoded and encoded only at the boundaries (API, storage), always
  with generated code (`json_serializable`), into statically typed models.
  No `dynamic` past the boundary. Other people's JSON is parsed leniently,
  our own strictly. Dates, enums and durations are converted once on receive.
- Models follow the server's OpenAPI spec, not sample responses.
- Cache-first: screens render local data at once and refresh behind it. A
  failed refresh keeps what is shown. Never move content under the reader.
- One implementation per behaviour and one source of truth per fact.
  Foreground and background share the same code path.
- Every request has a timeout. Coalesce identical in-flight requests and
  don't refetch just because a screen rebuilt.
- Long or costly work is stoppable, visible and resumable.
- No host-, server-, organisation- or machine-specific values in committed
  files, including tests, fixtures and seed data. Test data is invented.
- Never build for one server. Every optional capability is switched on by
  what the server reports (version, client config and feature flags,
  licence, permissions, plugin manifests) and leaves no trace when absent;
  a 501, 403 or 404 from an optional endpoint turns the feature off rather
  than showing an error.
- One bad element never fails a page: decode lists per element and skip
  what doesn't parse, store unknown enum values as unknown, and log the
  id and type of what was skipped.
- Errors keep what the server said. Show the server's message when there is
  one; "offline" or "check the connection" only when no answer arrived.
  One mapper from failure to user-facing text.
- Third-party plugins that touch outside input (shares, intents, files)
  get their native code read before use; sanitise names and paths
  ourselves.
- Security matters: tokens and credentials only in encrypted platform
  storage, TLS verified (no trust-all), no secrets or message content in
  logs, deep links and intents validated, and nothing sensitive in
  notifications beyond what the server is configured to send.

## Code style

- Minimal comments. Only the non-obvious why, never what the code says or
  how it got there. Plain everyday names.
- Small single-purpose classes; decisions in pure, testable functions;
  widgets only render state.
- No `BuildContext` after an `await`; cancel timers and subscriptions.
- Rebuild only what changed. No `setState` in a list's parent on scroll or
  visibility changes; keep callbacks, delegates and inherited values stable
  so unchanged rows don't rebuild; reuse unchanged view-model objects when
  a stream emits; parse and format once per value, never in `build` per
  frame; decode images at the size they are shown.
- Times: relative labels by calendar date in the local time zone
  ("Yesterday" is the previous local date, not 24 hours ago), all through
  one shared set of pure functions, tested across DST changes, midnight
  and the year boundary.
- `flutter analyze` stays at zero. Never silence a lint.
- Delete what's unused, including mock data and experiments.

## Testing

- Test behaviour from the user's point of view (given this server state and
  these actions, the user sees or gets this), not implementation details.
  Tests survive refactors that don't change behaviour.
- Tests use recorded fixtures or the local test server, never real servers.
- A new test must fail when the behaviour it checks is broken.

## UI

- Stock Material 3 with a themed `AppBar`; distinctive through colour,
  typography and spacing. Dark mode and text size follow the system.
- Express things with what Material, Flutter and Android already offer
  (badges, chips, sheets, search views, notification actions, widgets,
  shortcuts) before drawing anything custom.
- Text contrast at least 4.5:1, checked in a theme test.
- Edge-to-edge with correct insets; layouts hold at font scale 2.0 and on
  wide screens.
- Loading keeps content on screen with a slim progress bar. Errors say what
  happened and what to do. Empty states say how to fill them.
- Never move content under the reader. Reserve space for everything that
  arrives late (images, previews, emoji, reactions). When a visible row
  grows, what the reader is looking at stays in place and content below
  moves; only a reader at the newest message stays pinned to the bottom.
- Never show "no results" while a first load is running, and never spin
  forever: a failed first load shows the cause and Retry.

## Git and gate

- Intermediate commits within a batch of work need no checks. The full gate
  (`dart run build_runner build`, always, since CI fails on stale generated
  code; never with `--build-filter`; then `dart format .`,
  `flutter analyze`, `dart analyze`, `flutter test`,
  `flutter build apk --debug`) runs once, close to the finish, before the
  batch is pushed. Velocity matters.
- Commit after every feature or fix, so history shows when each change
  landed and a regression can be bisected. Push after committing.
- Watch CI after pushing but don't block on it; come back to it, and fix it
  at once if it fails.
- Every commit builds on its own. Stage files explicitly (never `git add -A`),
  check `git show --stat`, and keep tooling and app changes in separate
  commits. Imperative, plain-sentence commit messages.
- Never commit secrets, signing material, server credentials, `reference/` or
  the gitignored local notes.
