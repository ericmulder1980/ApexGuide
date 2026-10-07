# Issue Tracker

Track problems and their resolutions. Build institutional knowledge.

---

## Issue Template

### ISS-XXX: [Title]
**Reported:** YYYY-MM-DD
**Status:** Open | Investigating | Blocked | Resolved
**Severity:** Critical | High | Medium | Low
**Related Feature:** [FEATURE-ID]

**Symptoms:**
- [What was observed]
- [Error messages if any]

**Investigation Log:**
- [HH:MM] [What was checked/tried]
- [HH:MM] [Results]

**Root Cause:**
[Once identified — what actually caused the issue]

**Resolution:**
[How it was fixed]

**Prevention:**
- [ ] Added test case
- [ ] Added validation
- [ ] Updated documentation

**Time to Resolution:** [X hours/days]
**Related Commits:** [commit hashes]

---

## Open Issues

### ISS-002: iOS pilot builds need a CI runner before the Phase 3 pipeline story
**Reported:** 2026-10-02
**Status:** Open
**Severity:** High
**Related Feature:** DST-001, OPS-001

**Symptoms:**
- The pilot (Phase 1) needs TestFlight builds, which require Xcode 26 on a macOS runner (DEC-006).
- The GitHub Actions pipeline is a Phase 3 story ("Operations").

**Resolution:**
DST-001 includes a minimal macOS runner workflow for iOS builds; OPS-001 extends it with tests and automatic store uploads.

---

### ISS-005: Node.js not installed on the development machine
**Reported:** 2026-10-02
**Status:** Open
**Severity:** Medium
**Related Feature:** —

**Symptoms:**
- `npx` not found; all MCP servers (fetch, filesystem, git, github, postgres, puppeteer, sentry) fail with ENOENT.
- `npx -y skills add flutter/skills --agent claude-code` cannot run.

**Investigation Log:**
- Checked PATH, Homebrew, nvm, Volta: no Node install. Homebrew present, but macOS 12.7 is no longer officially supported by Homebrew.

**Resolution:**
Pending: install Node (nodejs.org installer recommended) or clone flutter/skills manually with git.

---

### ISS-008: Production domain not chosen; apexguide.com is registered by someone else
**Reported:** 2026-10-07
**Status:** Open
**Severity:** Medium
**Related Feature:** FND-005, DST-001, DEC-011

**Symptoms:**
- `config/prod.json` has an empty `API_BASE_URL`; the owner's preferred host was `api.apexguide.com`.
- whois (2026-10-07): apexguide.com registered 2016-12-09 via GoDaddy, expires 2027-12-09, transfer and delete locked; the apex domain resolves, `api.apexguide.com` does not.
- The app ID `com.apexguide.app` (DEC-011) follows reverse-domain naming for a domain we do not own. The stores do not verify this, but the ID is permanent once published.

**Resolution:**
Pending: choose a domain (buy apexguide.com from its owner, or another TLD such as apexguide.app or apexguide.nl). Then set `API_BASE_URL` in `config/prod.json` before the first production build, and confirm or change the app ID before DST-001 publishes anything.

---

### ISS-007: Development machine cannot run current Flutter, and the emulator is slow
**Reported:** 2026-10-07
**Status:** Open
**Severity:** High
**Related Feature:** FND-001, DST-001

**Symptoms:**
- Flutter 3.47.6 fails on start: "VM initialization failed: Current Mac OS X version 12.0 is lower than minimum supported version 14.0".
- The MacBook Pro 2016 (MacBookPro13,2, dual-core i7, 16 GB) cannot officially run macOS 14.
- Android emulator: the Android 16 Play Store image hung until the system watchdog restarted `system_server`. The Android 14 image works, but each cold boot spends several minutes at high load with "System UI isn't responding" dialogs before it settles.

**Investigation Log:**
- Ran a hello-world script with each Dart release: 3.8.3, 3.9.4 and 3.10.7 run; every release from 3.11.0 to 3.13.5 fails. `dart --version` alone succeeds and is not a valid test.
- Dart's system requirements list macOS 14, 15 and 26 only; flutter/flutter#182858 was closed as not planned.
- Working emulator setup: AVD `apexguide_pixel`, `system-images;android-34;google_apis;x86_64`, 720 × 1280 at 320 dpi, 2 GB RAM, 2 cores, host GPU, no audio. The first Gradle build took about 8 minutes (downloads the NDK and CMake once).

**Resolution:**
Workaround: DEC-012 pins Flutter 3.38.10 (Dart 3.10.9). Use the emulator only after it has settled, or a physical Android phone over USB. Permanent fix: a macOS 14+ machine (most likely new Apple-silicon hardware), then upgrade to Flutter 3.47+.

---

### ISS-006: Logo variants exist only as one combined PNG
**Reported:** 2026-10-04
**Status:** Open
**Severity:** Medium
**Related Feature:** FND-001, THM-002, DST-001

**Symptoms:**
- The prototype README lists separate SVGs (logo_full, app_icon, mark, mark_app_icon, colors, racing_line, A_shape, kerb_stripe, wordmark, horizontal_lockup) and app_icon.png, but the repo only has `Logo options design.png` (all variants on one sheet) and `ApexGuide - Logo on White.png`.
- Both PNGs have soft edges, which look muddy at small launcher icon sizes.

**Investigation Log:**
- 2026-10-07: `logo_full.svg` is in `reference/prototype/track-guide-ui-designs/`. It is a true vector (three filled paths: white `#fefefe`, navy `#05101e`, red `#ed0a19`, no embedded bitmap), so it scales cleanly. It looks auto-traced from the PNG (dense nodes, slightly wobbly edges) and the white background is a full-canvas path, so cropping to the A mark means adjusting the `viewBox`.

**Resolution:**
Partially resolved: `logo_full.svg` is enough for FND-001-T6 (interim launcher icon from the A mark, DEC-011). Still pending for THM-002 and DST-001: the remaining variants (app_icon, mark, mark_app_icon, wordmark, horizontal_lockup and the others), ideally drawn cleanly rather than traced. Check that the red kerb stripes stay legible at 48 px when generating icons.

---

## Resolved Issues

### ISS-004: App package choices not verified as current
**Reported:** 2026-10-02
**Status:** Resolved (2026-10-05)
**Severity:** Medium
**Related Feature:** FND-001, FND-004, VID-001

**Symptoms:**
- DEC-002 records the spec's package choices (Riverpod, go_router, drift + SQLCipher, dio, youtube_player_flutter, flutter_secure_storage) without checking current versions or maintenance status, as CLAUDE.md requires.

**Resolution:**
Researched each package on 2026-10-05. Kept Flutter (3.47), Riverpod (3), go_router, dio and flutter_secure_storage. Replaced SQLCipher with SQLite3 Multiple Ciphers (`sqlcipher_flutter_libs` is end-of-life) and youtube_player_flutter with youtube_player_iframe (needed for the `origin` fix to YouTube errors 152/153). Recorded as DEC-010, which supersedes DEC-002; spec, ERD, ARCHITECTURE.md, CLAUDE.md and features.json updated.

---

### ISS-003: Inconsistent counts in the spec
**Reported:** 2026-10-02
**Status:** Resolved (2026-10-05)
**Severity:** Low
**Related Feature:** —

**Symptoms:**
- API contract says "Seven purpose-built JSON endpoints" but lists 8 (the Drupal section says "eight endpoints").
- App design says "Seven screens" but the table lists 8.

**Resolution:**
Removed the spelled-out counts instead of correcting them, so they cannot drift again: the API contract, Drupal API row, App design and backlog intro no longer state how many endpoints, screens, stories or epics there are; the tables are the source. No impact on features.

---

### ISS-001: Settings screen has no backlog story
**Reported:** 2026-10-02
**Status:** Resolved (2026-10-05)
**Severity:** Medium
**Related Feature:** SET-001

**Symptoms:**
- The spec's App design section describes a Settings screen (theme, language, track-day mode, license status, version, wipe), but none of the 29 backlog stories covers it.

**Resolution:**
SET-001 was added to features.json as a Phase 1 Must, and the spec backlog now has a matching Settings story. Track-day mode is left out of the Phase 1 Settings screen; UX-001 adds the switch in Phase 2. Demo mode (LIC-006, EXT-011) moved to Phase 1 for rapid testing; LIC-006 adds the real-key activation entry to Settings in demo mode. Both were added to the spec backlog too (now thirty-two stories in ten epics).

---

*Resolved issues are moved here with full investigation and resolution notes.*

---

## Common Patterns

As issues accumulate, document patterns here:

### Environment Issues
*TBD*

### Integration Issues
*TBD*

### Performance Issues
*TBD*
