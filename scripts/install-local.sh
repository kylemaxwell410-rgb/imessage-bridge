#!/bin/bash
# Build and install with the self-signed local identity (scripts/local-identity.sh),
# so permission grants survive rebuilds. Everything else is scripts/install.sh.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# A self-signed identity has no Team ID, so library validation would reject the
# bundled Sparkle framework; the local entitlements turn that one check off.
SIGN_IDENTITY="$("$ROOT/scripts/local-identity.sh")" \
SIGN_ENTITLEMENTS="$ROOT/Resources/IMessageBridge.local.entitlements" \
exec "$ROOT/scripts/install.sh"
