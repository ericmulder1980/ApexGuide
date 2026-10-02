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

### ISS-001: Settings screen has no backlog story
**Reported:** 2026-10-02
**Status:** Open
**Severity:** Medium
**Related Feature:** SET-001

**Symptoms:**
- The spec's App design section describes a Settings screen (theme, language, track-day mode, license status, version, wipe), but none of the 29 backlog stories covers it.

**Resolution:**
SET-001 was added to features.json as a Phase 1 Must. Update the spec's backlog to match.

---

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

### ISS-003: Inconsistent counts in the spec
**Reported:** 2026-10-02
**Status:** Open
**Severity:** Low
**Related Feature:** —

**Symptoms:**
- API contract says "Seven purpose-built JSON endpoints" but lists 8 (the Drupal section says "eight endpoints").
- App design says "Seven screens" but the table lists 8.

**Resolution:**
Correct the wording in the spec. No impact on features.

---

### ISS-004: App package choices not verified as current
**Reported:** 2026-10-02
**Status:** Open
**Severity:** Medium
**Related Feature:** FND-001, FND-004, VID-001

**Symptoms:**
- DEC-002 records the spec's package choices (Riverpod, go_router, drift + SQLCipher, dio, youtube_player_flutter, flutter_secure_storage) without checking current versions or maintenance status, as CLAUDE.md requires.

**Resolution:**
Research each package during `/plan` for FND-001 before adding dependencies. Supersede DEC-002 if anything changes.

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

## Resolved Issues

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
