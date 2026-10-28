/// Pure: whether the open conversation is marked read now. The newest
/// message must be in view while the app is in front, and something new
/// must have arrived since the last mark; [ready] is false while the
/// opening refresh still runs, which may fetch newer messages.
bool shouldMarkRead({
  required bool atNewest,
  required bool inFront,
  required bool pending,
  required bool ready,
}) => atNewest && inFront && pending && ready;
