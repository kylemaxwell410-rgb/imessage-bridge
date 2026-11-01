#!/bin/bash
# Create (once) a self-signed code-signing identity so Full Disk Access and
# Automation grants survive rebuilds of a locally built app. Ad hoc signatures
# change with every build and macOS forgets the grants.
#
# The identity lives in its own keychain (empty password, so headless builds
# over SSH can sign: the login keychain refuses "user interaction" there). It
# holds nothing but this self-signed key. Prints the identity name. Idempotent.
set -euo pipefail

NAME="${LOCAL_SIGN_IDENTITY:-iMessage Bridge Local}"
KEYCHAIN="$HOME/Library/Keychains/imessage-bridge-local.keychain-db"

if [[ -f "$KEYCHAIN" ]]; then
    security unlock-keychain -p "" "$KEYCHAIN"
fi
if security find-certificate -c "$NAME" >/dev/null 2>&1; then
    echo "$NAME"
    exit 0
fi

if [[ ! -f "$KEYCHAIN" ]]; then
    security create-keychain -p "" "$KEYCHAIN"
    security set-keychain-settings "$KEYCHAIN"          # never auto-lock
    chmod 600 "$KEYCHAIN"
fi
security unlock-keychain -p "" "$KEYCHAIN"
if ! security list-keychains -d user | grep -q "imessage-bridge-local.keychain-db"; then
    # shellcheck disable=SC2046
    security list-keychains -d user -s $(security list-keychains -d user | tr -d ' "') "$KEYCHAIN"
fi

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
    -keyout "$WORK/key.pem" -out "$WORK/cert.pem" \
    -subj "/CN=$NAME" \
    -addext "keyUsage=critical,digitalSignature" \
    -addext "extendedKeyUsage=critical,codeSigning" \
    -addext "basicConstraints=critical,CA:false" >/dev/null 2>&1
openssl pkcs12 -export -inkey "$WORK/key.pem" -in "$WORK/cert.pem" \
    -out "$WORK/id.p12" -passout pass:local -legacy 2>/dev/null \
  || openssl pkcs12 -export -inkey "$WORK/key.pem" -in "$WORK/cert.pem" \
    -out "$WORK/id.p12" -passout pass:local
security import "$WORK/id.p12" -k "$KEYCHAIN" -P local -T /usr/bin/codesign -T /usr/bin/security >/dev/null
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "" "$KEYCHAIN" >/dev/null

echo 'int main(){return 0;}' > "$WORK/t.c" && cc -o "$WORK/t" "$WORK/t.c"
codesign --force --sign "$NAME" "$WORK/t"
echo "$NAME"
