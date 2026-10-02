# Architectural Decision Records

Track significant decisions. Each decision is immutable once accepted — supersede rather than edit.

---

## Decision Template

### DEC-XXX: [Title]
**Date:** YYYY-MM-DD
**Status:** Proposed | Accepted | Superseded by DEC-YYY | Deprecated
**Deciders:** [Who made this decision]
**Related:** [Feature IDs, Issue IDs, other Decision IDs]

**Context:**
[What is the issue that we're seeing that is motivating this decision?]

**Options Considered:**
1. **[Option A]**
   - Pros: [...]
   - Cons: [...]

2. **[Option B]**
   - Pros: [...]
   - Cons: [...]

**Decision:**
[What is the change that we're proposing and/or doing?]

**Rationale:**
[Why did we choose this option over others?]

**Consequences:**
- [What becomes easier]
- [What becomes harder]
- [What new constraints are introduced]

---

## Active Decisions

### DEC-001: Flutter app in this repo, Drupal in a separate repo
**Date:** 2026-10-02
**Status:** Accepted
**Deciders:** Project owner
**Related:** All features; EXT-001 – EXT-010

**Context:**
The spec defines two deliverables: a mobile app for Android and iOS, and a multi-tenant Drupal central application. A native Android skill (Kotlin/Compose) had been added to `.claude/skills/`.

**Options Considered:**
1. **Flutter, app-only repo**
   - Pros: one codebase for both platforms; clean separation from PHP/Drupal tooling
   - Cons: Drupal progress must be tracked as external dependencies
2. **Monorepo with app and Drupal**
   - Pros: one place for the API contract
   - Cons: mixes two toolchains and deployment flows
3. **Native Android (Kotlin) + native iOS**
   - Pros: full platform control
   - Cons: two codebases for a solo developer; contradicts the spec

**Decision:**
This repo contains only the Flutter app. Drupal stories are tracked as `EXT-*` features with `"external": true`. The native Kotlin skill is not used.

**Rationale:**
The spec selects Flutter (R-01). A single codebase suits a solo developer, and separate repos keep the toolchains separate.

**Consequences:**
- App work depends on EXT features for real integration (mitigated by DEC-003)
- Native code is limited to the two protection platform channels

---

### DEC-002: App technology stack
**Date:** 2026-10-02
**Status:** Accepted
**Deciders:** Project owner (from spec)
**Related:** FND-001 – FND-006, PRT-001, PRT-002, VID-001

**Context:**
The spec's Solution architecture section fixes the app libraries.

**Decision:**
Flutter 3, Riverpod (state), go_router (navigation), drift over SQLCipher (storage), dio (HTTP), youtube_player_flutter (video), flutter_secure_storage (keys), plus two platform channels: Android FLAG_SECURE and the iOS secure text layer.

**Rationale:**
These are the spec's choices. They are recorded as given, and their versions and maintenance status have not been verified yet (see ISS-004).

**Consequences:**
- Package currency must be verified during `/plan` for FND-001 before adding dependencies
- If a package turns out to be unmaintained, a new decision supersedes this one

---

### DEC-003: Build the app against a mock API from the frozen contract
**Date:** 2026-10-02
**Status:** Accepted
**Deciders:** Project owner (from spec risk mitigation)
**Related:** FND-005, all EXT features

**Context:**
The Drupal custom module may grow and delay the app.

**Decision:**
Treat the spec's API contract as frozen. FND-005 includes a mock API serving a demo tenant (one indoor and one outdoor track, both languages, one video with two markers). Features are built and tested against the mock, then integrated when the matching EXT feature is ready.

**Rationale:**
This removes Drupal from the app's critical path.

**Consequences:**
- Contract changes must update the spec, the mock and the models together
- Integration testing is still required per EXT feature

---

### DEC-004: License model — 7-day JWT bound to one installation
**Date:** 2026-10-02
**Status:** Accepted
**Deciders:** Project owner (from spec)
**Related:** LIC-001 – LIC-005, PRT-003

**Decision:**
A coach-issued key is bound to one installation id. `activate` returns a signed JWT (7 days). The app refreshes it daily when online. When it expires, the app wipes content and keeps the installation id, so the driver can re-enter the same key. A 403 from any endpoint means the key is revoked: the app wipes and the key is refused. If the device clock is earlier than the last server time, the app locks.

**Rationale:**
This allows offline use at tracks while limiting how long a revoked driver keeps content.

**Consequences:**
- The license state machine needs thorough unit tests with a fake clock
- The installation id must be the only data that survives a wipe

---

### DEC-005: Content protection layers
**Date:** 2026-10-02
**Status:** Accepted
**Deciders:** Project owner (from spec)
**Related:** PRT-001 – PRT-003, FND-004, SYN-002

**Decision:**
- Android: FLAG_SECURE app-wide
- iOS: corner text in a secure UITextField layer, isolated in one platform view
- Both: text selection disabled, encrypted database and images, media only through the tenant-checked endpoint

**Rationale:**
The corner text is the protected asset. Videos are public YouTube links and are not protected.

**Consequences:**
- Known limits, to be stated to coaches: an iOS update may weaken the secure layer (fallback: blur plus screenshot detection); a second phone can photograph the screen; rooted or jailbroken devices are not detected in v1
- The secure layer hides text from screen readers (accepted for v1)

---

### DEC-006: iOS builds on a GitHub Actions macOS runner
**Date:** 2026-10-02
**Status:** Accepted
**Deciders:** Project owner (from spec)
**Related:** DST-001, OPS-001

**Context:**
The development machine is a 2016 Intel MacBook Pro limited to macOS 12. App Store Connect and TestFlight have required Xcode 26 (macOS 15.6+) since 28 April 2026.

**Options Considered:**
1. **GitHub Actions macOS runner** — no hardware cost; the same pipeline is reused in Phase 3
2. **Used Apple-silicon Mac mini** — local builds, but costs money

**Decision:**
Write code locally. Build and upload iOS in a GitHub Actions macOS runner, set up minimally in Phase 1 (DST-001).

**Consequences:**
- iOS debugging on device is harder from the local machine
- Signing secrets live in GitHub secrets

---

### DEC-007: Claude Design prototype is the visual source of truth
**Date:** 2026-10-02
**Status:** Accepted
**Deciders:** Project owner
**Related:** All UI features

**Decision:**
`reference/prototype/track-guide-ui-designs/project/ApexGuide Screens.dc.html` and the files it imports (modernist design system) define the visual design. Screens are recreated in Flutter to match it; the prototype's HTML/JS structure is not copied.

**Consequences:**
- UI features read the prototype before implementation
- Conflicts between prototype and spec are logged in issues.md and resolved by the project owner

---

### DEC-008: Local database schema
**Date:** 2026-10-02
**Status:** Accepted
**Deciders:** Project owner
**Related:** FND-004, FND-006, SYN-001, FBK-001; `docs/database/mobile-erd.md`

**Context:**
The spec's data model describes the server. The app's local schema needs to fit the API payload and the one-tenant-per-device assumption.

**Decision:**
1. Corners keyed by `(track_id, number)` and videos by `(track_id, youtube_id)`, because the payload carries no corner or video ids
2. No `tenant_id` on TRACK (one tenant per device; a wipe clears everything)
3. No `deleted` flag locally; deleted tracks are removed
4. A `FEEDBACK_QUEUE` table holds only unsent feedback
5. All foreign keys to TRACK use `ON DELETE CASCADE`
6. Token, DB key and installation id live in secure storage, not in the database

**Consequences:**
- Removing a track during sync cleans up all its child rows automatically
- Supporting more than one tenant per device later would need a migration

---

## Superseded/Deprecated Decisions

*Decisions that have been replaced or are no longer relevant go here for historical reference.*
