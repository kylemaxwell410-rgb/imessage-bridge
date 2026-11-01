#!/bin/bash
# Goal command for the macOS 26 send-path work (route Tier 1).
# Green when the send-path unit tests pass. Live sends are checked by hand
# per docs/superpowers/specs/2026-11-01-grok-texting-via-bridge-design.md "Done when".
set -e
cd "$(dirname "$0")/.."
exec swift test --filter SendPath \
  -Xswiftc -plugin-path -Xswiftc /Library/Developer/CommandLineTools/usr/lib/swift/host/plugins/testing
