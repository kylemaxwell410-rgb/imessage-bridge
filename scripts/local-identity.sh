#!/bin/bash
# Create (once) a self-signed code-signing identity so Full Disk Access and
# Automation grants survive rebuilds of a locally built app. Ad hoc signatures
# change with every build and macOS forgets the grants.
#
# Prints the identity name. Idempotent. The first run may show a macOS
# password dialog when the certificate is marked trusted for code signing.
set -euo pipefail

NAME="${LOCAL_SIGN_IDENTITY:-iMessage Bridge Local}"
KEYCHAIN="$HOME/Library/Keychains/login.keychain-db"

if security find-certificate -c "$NAME" "$KEYCHAIN" >/dev/null 2>&1; then
    echo "$NAME"
    exit 0
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

# codesign needs the self-signed root trusted for code signing. Try without
# first; mark it trusted only if that fails (this is the step that may prompt).
echo 'int main(){return 0;}' > "$WORK/t.c" && cc -o "$WORK/t" "$WORK/t.c"
if ! codesign --force --sign "$NAME" "$WORK/t" 2>/dev/null; then
    security add-trusted-cert -r trustRoot -p codeSign -k "$KEYCHAIN" "$WORK/cert.pem"
    codesign --force --sign "$NAME" "$WORK/t"
fi
echo "$NAME"
