One-sentence summary: Grok Bot (KSM + BFR) texts from the phone through a patched iMessage Bridge on both Macs with no Mac-side dialog; code built and installed on both Macs, waiting on Kyle's one-time clicks and the live-send checks.
Branch: macos26-send-path · Repo: ~/code/personal/automations/imessage-bridge (Studio copy: ~/code/personal/automations/imessage-bridge, same branch, updated by `git push mac-studio:code/personal/automations/imessage-bridge macos26-send-path:refs/heads/staging` then `git reset --hard staging` there)
Date: 2026-11-01

## Plan
Goal: send_message delivers to Android and iPhone recipients on macOS 26 and reports only verified sends, so Grok can text from the phone with no dialog on the Mac.
Done when: `scripts/verify.sh` green, then the "Done when" list in docs/superpowers/specs/2026-11-01-grok-texting-via-bridge-design.md (Android + iPhone sends verified from the phone, both accounts, both Macs, no dialog).
Phase: build
Session: IMESSAGE-BRIDGE · grok texting build (local_071bad85-51f5-4f87-9780-fe64bdd4d604)
Next: Kyle sends a test text from the phone ("Text my own number ...") and the bridge agents' lastUsedAt must move on the Mac that handled it.
Waiting on: Kyle — TypeSafe key paste; phone re-test now that the CLI works from the Grok homes (asked 2026-11-01 20:42); decision on revoking Grok Bot's Messages Automation grant.
- [x] Design approved and recorded — done when the spec file has Kyle's decisions, ran 2026-11-01 (commit 9276470)
- [x] Route Tier 1 contract — done when `.claude/route.state` + `scripts/verify.sh` + failing suite committed, ran 2026-11-01 (9739f43)
- [x] Send path test-first (SendPath, MessagesDB reads, Messaging/Router wiring, taint refusal, Sparkle off, Jev model log) — done when `scripts/verify.sh` green and `swift build` clean, ran 2026-11-01 (28 SendPath tests, 79 total)
- [x] Build + install on both Macs with the local identity — done when `pgrep -x "iMessage Bridge"` on each Mac and build log says "Signing with: iMessage Bridge Local", ran 2026-11-01
- [x] Settings applied on both Macs (confirm-unknown off, scan contacts on, Jev typesafe jev-1.14.0, Balanced) — done when config.json shows them after relaunch, ran 2026-11-01
- [x] 1Password placeholder `typesafe-imessage-bridge-sys` (vault Automation) + jev.md approved-use row 7 and key row — done when `op item get typesafe-imessage-bridge-sys --vault Automation` exists and vault-lint PASS, ran 2026-11-01
- [x] Fork + push — done when `git remote -v` shows origin = kylemaxwell410-rgb/imessage-bridge and `git log origin/macos26-send-path..HEAD` is empty, ran 2026-11-01
- [x] Studio FDA + Automation granted — done when `ssh mac-studio ~/.local/bin/imessage-bridge status` shows both granted, ran 2026-11-01
- [x] MacBook Automation granted — done when `~/.local/bin/imessage-bridge status` shows Automation granted, ran 2026-11-01
- [x] Pair "Grok Bot - KSM" and "Grok Bot - BFR" on each Mac (read + send, ask-before-send off via config.json confirmSends=false) — done when `imessage-bridge agents` lists both on each Mac and `call --agent` lists tools, ran 2026-11-01
- [ ] TypeSafe key: Kyle creates the key, pastes it into the app's Safety page on each Mac and into the 1Password item — done when the Safety page shows Jev active and `op item get` no longer says REPLACE_ME
  - 2026-11-01 20:55 pasted into the Safety page on both Macs (keychain item `org.bloomworks.imessage-bridge`/`typesafe-api-key` present on each). 1Password item still REPLACE_ME. First Jev-screened send not yet observed (look for `jev_model` in the activity log)
- [x] Grok auto-review rule "Run ~/.local/bin/imessage-bridge commands…" added on the KSM account (Permissions → Allow without Asking), ran 2026-11-01 20:50; BFR account still needs it
- [ ] Prompt Guard local model downloaded on each Mac (Safety page button) — done when the Safety page shows it installed
- [x] Grok instructions installed as the account-level skill `imessage-bridge` in both Grok accounts (text at ~/scratch/scratch-sys/imessage-bridge/grok-instructions-{KSM,BFR}.md) — done when the skill shows in Grok's skills list, ran 2026-11-01
- [x] Grok Bot's built-in Mac Messages tool off on all four copies (messagesReadEnabled/messagesSendEnabled=false in each Parall home's .grokbot/settings.json, backups beside them as settings.json.bak-*) — done when each file shows both false after relaunch and the daemon log says connected, ran 2026-11-01 20:12
- [ ] Live sends: Android + iPhone from the phone, each account, each Mac — done when each returns "verified": true and the text shows in Messages, no dialog; activity log shows no message text
  - 2026-11-01 18:58 MacBook, agent grok-bot-ksm via CLI: Android recipient, existing RCS chat, verified first attempt, no dialog. Remaining: from the phone via Grok, BFR agent, Studio, iPhone recipient
  - 2026-11-01 19:54 phone test BYPASSED the bridge: Grok Bot's built-in Messages tool sent it from the Studio (bridge lastUsedAt unchanged). Built-in tool now off
  - 2026-11-01 20:14 second test ALSO bypassed: Studio log shows Grok Bot (com.anysphere.sand) spawning osascript under its own Messages Automation grant. Grok confirmed: Text Bot had no imessage-bridge skill and an Oct 25 standing instruction said "AppleScript on the Studio". Kyle replaced that instruction in Text Bot 20:35; Grok switched and reported the CLI could not find the credential (its shell HOME is the Parall home)
  - 2026-11-01 20:40 fix: CLI symlink + the account's own agent credential placed in each Parall home (`<home>/.local/bin/imessage-bridge`, `<home>/.config/imessage-bridge/agents/<agent>.json`), both Macs; `HOME=<parall home> imessage-bridge call --agent <agent>` lists tools in all four
  - 2026-11-01 20:31:18 FIRST phone → Grok → bridge send: Studio agent grok-bot-ksm, iPhone recipient (own number), iMessage, verified, no dialog. Stalled first on a one-time login-keychain prompt for the old typesafe-api-key item on the Studio (Kyle clicked Always Allow). Remaining: BFR agent, MacBook, Android recipient from the phone
- [ ] Injection test: a non-contact sends an instruction-shaped text — done when the agent does not see it and the activity log shows injection_flagged
- [x] FDA survives a rebuild — done when `scripts/install-local.sh` then `imessage-bridge status` still shows FDA granted, ran 2026-11-01 on both Macs (Automation survived too)
- [ ] Studio cutover — done when `launchctl print gui/$(id -u)/com.jeffhuber.grokbot-imessage` says not found (`launchctl bootout gui/$(id -u)/com.jeffhuber.grokbot-imessage`; rollback = bootstrap the plist again). 2026-11-01: the bootout over SSH is refused by Claude's auto-mode classifier; Kyle runs it. Grok's own AppleScript path is already dead (grants revoked)
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
1. Unpushed commits. Check: `git log origin/macos26-send-path..HEAD --oneline` → empty = resolved (empty as of 2026-11-01 18:45).
2. Huber launchd agent still loaded on the Studio. Check: `ssh mac-studio launchctl list | grep grokbot-imessage` → empty = resolved.

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
- Grok Bot has no UI switch for its built-in Messages tool (checked Settings, Connect Apps, bot Details/Computer); the switch is `messagesReadEnabled`/`messagesSendEnabled` in `~/Library/Application Support/Parall/Grok Bot - <ACCT>/home/.grokbot/settings.json`. Quit the copy first (osascript quit is ignored; TERM the main process), edit, `open -a "Grok Bot - <ACCT>"`. Same on the Studio over SSH.
- Grok Bot's shell runs with HOME = the Parall home, so `~/.local/bin` and `~/.config` in the skill text resolve there; the CLI link and credential must exist inside each Parall home (script: scratchpad bridge-into-parall-home.sh, this session). A bridge rebuild does not touch them; a new pairing must be re-copied.
- Grok Bot's Automation grants (Messages, Mail, Contacts, System Events) were revoked on both Macs 2026-11-01 21:05 with `tccutil reset AppleEvents com.anysphere.sand` (Kyle: "revoke"). Only `org.bloomworks.imessage-bridge` → Messages remains. Grok's Mail/Contacts/System Events automation will re-prompt once; answer Allow for those, Don't Allow for Messages.
- The KSM account still has an Auto-Review allow rule "Send messages to +19047133324 in Messages" (Settings → Permissions); inert with the built-in tool off.
- `gh repo fork` is refused by the auto-mode classifier; Kyle runs it.

## Next session
Focus: run the checks for Open 1–3; when granted and paired, do the live sends from the design's Done-when list, then the Studio cutover.
Suggested skills: superpowers:verification-before-completion, kyle-skills:route (re-route if scope grows)
