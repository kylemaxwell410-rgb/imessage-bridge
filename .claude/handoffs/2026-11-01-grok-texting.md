One-sentence summary: Grok Bot (KSM + BFR) texts from the phone through a patched iMessage Bridge on both Macs with no Mac-side dialog; code built and installed on both Macs, waiting on Kyle's one-time clicks and the live-send checks.
Branch: macos26-send-path · Repo: ~/code/personal/automations/imessage-bridge (Studio copy: ~/code/personal/automations/imessage-bridge, same branch, updated by `git push mac-studio:code/personal/automations/imessage-bridge macos26-send-path:refs/heads/staging` then `git reset --hard staging` there)
Date: 2026-11-01

## Plan
Goal: send_message delivers to Android and iPhone recipients on macOS 26 and reports only verified sends, so Grok can text from the phone with no dialog on the Mac.
Done when: `scripts/verify.sh` green, then the "Done when" list in docs/superpowers/specs/2026-11-01-grok-texting-via-bridge-design.md (Android + iPhone sends verified from the phone, both accounts, both Macs, no dialog).
Phase: build
Session: IMESSAGE-BRIDGE · grok texting build (local_071bad85-51f5-4f87-9780-fe64bdd4d604)
Next: Kyle's one-time clicks on each Mac (FDA on the Studio, Automation on both, pairing approvals), then live sends.
Waiting on: Kyle — `gh repo fork cmer/imessage-bridge --clone=false`; FDA + Automation clicks; TypeSafe key paste; pairing approvals (asked 2026-11-01).
- [x] Design approved and recorded — done when the spec file has Kyle's decisions, ran 2026-11-01 (commit 9276470)
- [x] Route Tier 1 contract — done when `.claude/route.state` + `scripts/verify.sh` + failing suite committed, ran 2026-11-01 (9739f43)
- [x] Send path test-first (SendPath, MessagesDB reads, Messaging/Router wiring, taint refusal, Sparkle off, Jev model log) — done when `scripts/verify.sh` green and `swift build` clean, ran 2026-11-01 (28 SendPath tests, 79 total)
- [x] Build + install on both Macs with the local identity — done when `pgrep -x "iMessage Bridge"` on each Mac and build log says "Signing with: iMessage Bridge Local", ran 2026-11-01
- [x] Settings applied on both Macs (confirm-unknown off, scan contacts on, Jev typesafe jev-1.14.0, Balanced) — done when config.json shows them after relaunch, ran 2026-11-01
- [x] 1Password placeholder `typesafe-imessage-bridge-sys` (vault Automation) + jev.md approved-use row 7 and key row — done when `op item get typesafe-imessage-bridge-sys --vault Automation` exists and vault-lint PASS, ran 2026-11-01
- [ ] Fork + push — done when `git remote -v` shows origin = kylemaxwell410-rgb/imessage-bridge and `git log origin/macos26-send-path..HEAD` is empty
- [ ] Studio FDA + Automation granted — done when `ssh mac-studio ~/.local/bin/imessage-bridge status` shows both granted
- [ ] MacBook Automation granted — done when `~/.local/bin/imessage-bridge status` shows Automation granted
- [ ] Pair "Grok Bot – KSM" and "Grok Bot – BFR" on each Mac (read + send, ask-before-send off) — done when `imessage-bridge agents` lists both on each Mac
- [ ] TypeSafe key: Kyle creates the key, pastes it into the app's Safety page on each Mac and into the 1Password item — done when the Safety page shows Jev active and `op item get` no longer says REPLACE_ME
- [ ] Prompt Guard local model downloaded on each Mac (Safety page button) — done when the Safety page shows it installed
- [ ] Grok instructions pasted into both Grok accounts — text at ~/scratch/scratch-sys/imessage-bridge/grok-instructions.md — done when a Grok chat lists the tools via `imessage-bridge call`
- [ ] Live sends: Android + iPhone from the phone, each account, each Mac — done when each returns "verified": true and the text shows in Messages, no dialog; activity log shows no message text
- [ ] Injection test: a non-contact sends an instruction-shaped text — done when the agent does not see it and the activity log shows injection_flagged
- [ ] FDA survives a rebuild — done when `scripts/install-local.sh` then `imessage-bridge status` still shows FDA granted
- [ ] Studio cutover — done when `launchctl print gui/$(id -u)/com.jeffhuber.grokbot-imessage` says not found (`launchctl bootout gui/$(id -u)/com.jeffhuber.grokbot-imessage`; rollback = bootstrap the plist again)
- [ ] Upstream PR with D2 only (clean branch off upstream/main) — done when the PR exists on cmer/imessage-bridge
- [ ] Re-review Jev threshold after 2 weeks (2026-11-15) — done when the activity log's flagged count is reviewed and sensitivity confirmed or changed

## Ideas
- "Sent by Claude" signature: keep or drop in the Claude channel plugin on the Studio (out of scope here)
- Parall purchase (optional; the script launchers do the job)

## Done
- 9276470 design doc · 9739f43 contract + failing tests · 863eea6 SendPath · c5136a6 MessagesDB reads · 8d5f2d7 send path + taint refusal · 6063207 Sparkle off · d5efbf6 Jev model log · 199c35b/c23939e local identity + install-local · 9c7bc52 design note
- Studio: /Applications/iMessage Bridge.app running, local identity in ~/Library/Keychains/imessage-bridge-local.keychain-db; Grok Bot - KSM/BFR launcher apps from the earlier step
- Vault: systems/tool-stack/jev.md rows (commit 7a2c55d8 in ~/obsidian)

## Open — each with its check
1. Fork not created. Check: `gh repo view kylemaxwell410-rgb/imessage-bridge` → exists = resolved (missing as of 2026-11-01).
2. 11 local commits unpushed (no origin yet). Check: `git log origin/macos26-send-path..HEAD --oneline` → empty = resolved.
3. Studio FDA missing; Automation not requested on either Mac. Check: `imessage-bridge status` on each → "granted" twice = resolved (as of 2026-11-01 18:25).
4. Huber launchd agent still loaded on the Studio. Check: `ssh mac-studio launchctl list | grep grokbot-imessage` → empty = resolved.

## Decisions
- Fallback order and RCS: RCS rides the SMS account in AppleScript (Messages upgrades it); duplicate accounts in the order are tried once.
- Verification polls chat.db up to 12 s for an outbound row with error 0 and matching text; nothing else counts as sent.
- Taint lockout = plain refusal naming the reason and end time; no dialog (Kyle, 2026-11-01).
- Sparkle disabled by removing SUFeedURL (Updater.start guards on it) while the patch is local.
- Self-signed identity lives in its own empty-password keychain so SSH builds can sign; local entitlements add disable-library-validation (self-signed has no Team ID). Release entitlements untouched.

## Gotchas
- The Studio checkout has the branch checked out, so `git push` to it is refused: push to `refs/heads/staging` and `git reset --hard staging` there.
- Over SSH the login keychain refuses imports ("User interaction is not allowed"); hence the dedicated keychain.
- `scripts/verify.sh` needs the swift-testing plugin path (Command Line Tools only); it is in the script.
- config.json is written by the app on change; edit it only with the app quit, then relaunch.
- `gh repo fork` is refused by the auto-mode classifier; Kyle runs it.

## Next session
Focus: run the checks for Open 1–3; when granted and paired, do the live sends from the design's Done-when list, then the Studio cutover.
Suggested skills: superpowers:verification-before-completion, kyle-skills:route (re-route if scope grows)
