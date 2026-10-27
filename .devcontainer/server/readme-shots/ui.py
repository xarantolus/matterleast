#!/usr/bin/env python3
"""Finds elements on the emulator screen by accessibility label.

  ui.py <adb> tap <regex> [index]   tap the centre of the index-th (default 0, negative counts from the end) element whose label matches
  ui.py <adb> has <regex>           exit 0 when an element matches

<adb> is the command that reaches the device, e.g. "tool/lane.sh adb". A label is the
element's text or content description; the regex must match all of it.
"""
import html
import re
import subprocess
import sys


def elements(adb):
    subprocess.run(adb.split() + ["shell", "uiautomator", "dump", "/sdcard/ui.xml"], capture_output=True, check=True)
    xml = subprocess.run(adb.split() + ["shell", "cat", "/sdcard/ui.xml"], capture_output=True, text=True, check=True).stdout
    found = []
    for node in re.finditer(r"<node [^>]*>", xml):
        attrs = dict(re.findall(r'([\w-]+)="([^"]*)"', node.group(0)))
        label = html.unescape(attrs.get("content-desc") or attrs.get("text") or "")
        x1, y1, x2, y2 = map(int, re.findall(r"\d+", attrs["bounds"]))
        if label:
            found.append((label, (x1 + x2) // 2, (y1 + y2) // 2))
    return found


def main():
    adb, action, pattern = sys.argv[1], sys.argv[2], sys.argv[3]
    index = int(sys.argv[4]) if len(sys.argv) > 4 else 0
    matches = [e for e in elements(adb) if re.fullmatch(pattern, e[0], re.S)]
    if action == "has":
        sys.exit(0 if matches else 1)
    if not -len(matches) <= index < len(matches):
        sys.exit(f"no element labelled {pattern!r} (index {index})")
    _, x, y = matches[index]
    subprocess.run(adb.split() + ["shell", "input", "tap", str(x), str(y)], check=True)


main()
