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

### DEC-009: Demo mode uses a server-side demo tenant and a shared demo key
**Date:** 2026-10-04
**Status:** Accepted
**Deciders:** Project owner
**Related:** LIC-006, EXT-011, DST-002, DEC-004; prototype screen 3a

**Context:**
The activation screen in the prototype (3a) offers "Continue in demo mode" for drivers without a code. Apple also needs a working path in for app review. The original idea was to bundle demo content in the app.

**Decision:**
1. Demo content lives in a separate demo tenant in Drupal, not in the app, so it can change without an app release
2. The app has a shared demo key built in and uses the normal `activate` endpoint; license, sync and wipe flows stay the same
3. Exception to DEC-004: a platform admin (not a coach) can mark a key as allowed on many devices. The demo key carries this flag, so it never returns 409
4. The same demo key serves as the Apple reviewer key

**Alternatives considered:**
- Bundled demo content: needs an app release for every content change
- A separate endpoint that needs no login: a second way into the API, plus special cases in license and sync logic

**Consequences:**
- The demo key can be extracted from the app, so the demo tenant must only hold content that is safe to show publicly
- Replacing a leaked or abused demo key needs an app release; Drupal rate-limits `activate` for multi-device keys
- The license state machine needs no demo-specific branch

---

### DEC-010: App stack verified and pinned
**Date:** 2026-10-05
**Status:** Accepted; framework and package versions amended by DEC-012 (2026-10-07)
**Deciders:** Project owner
**Related:** Supersedes DEC-002; resolves ISS-004; FND-001, FND-004, VID-001

**Context:**
DEC-002 recorded the spec's package choices without checking them (ISS-004). A research pass on pub.dev and the official docs on 2026-10-05 found two problems: `sqlcipher_flutter_libs` is end-of-life, and YouTube has refused unidentified embeds since August 2025 (errors 152/153).

**Decision:**
| Area | Package | Version at decision |
| --- | --- | --- |
| Framework | Flutter (Dart 3.13) | 3.47.x |
| State | flutter_riverpod | 3.x (3.4.3) |
| Navigation | go_router | 18.x (18.0.2) |
| Storage | drift over sqlite3 with source `sqlite3mc` (SQLite3 Multiple Ciphers) | drift 2.35.1, sqlite3 3.7.0 |
| HTTP | dio | 5.x (5.11.1) |
| Video | youtube_player_iframe, behind our own player widget, with the `origin` parameter set | 6.x (6.0.2) |
| Keys | flutter_secure_storage | 11.x (11.2.0) |

Plus the two platform channels from DEC-005: Android FLAG_SECURE and the iOS secure text layer.

**Rationale:**
- `sqlcipher_flutter_libs` is end-of-life (`0.7.0+eol`); `package:sqlite3` 3.x now selects the engine with a `hooks: user_defines: sqlite3: source:` entry in `pubspec.yaml`. drift's encryption docs recommend SQLite3 Multiple Ciphers: MIT licensed, actively maintained, current SQLite. The SQLCipher build can lag behind on SQLite version and pulls in OpenSSL on Android. No existing encrypted databases need SQLCipher's file format.
- youtube_player_flutter 10.x is a thin wrapper over youtube_player_iframe. Using the iframe package directly exposes `origin` (needed to avoid errors 152/153) and `loadVideoById(startSeconds, endSeconds)`, which VID-001 needs for corner markers. A wrapper widget keeps future YouTube changes to one file.
- Riverpod 3 from the start avoids a 2.x to 3.x migration later.
- go_router is feature-complete (bug fixes only by the Flutter team), which suits our small route tree.

**Alternatives considered:**
- SQLCipher via the `sqlcipher` hook source: still supported, but an older SQLite and an OpenSSL dependency on Android
- youtube_player_flutter: works, but adds a layer over the same package

**Consequences:**
- The database key is still per install, in Android Keystore / iOS Keychain (`whenUnlockedThisDeviceOnly`); confirm the matching flutter_secure_storage iOS accessibility option during FND-004
- flutter_secure_storage 10+ requires Android 6.0 (API 23) as minimum
- Flutter plans to move Material and Cupertino out of the core into separate packages; stay on 3.47.x through the pilot and plan the migration afterwards
- Pin exact versions in `pubspec.yaml` during FND-001; this table records the versions current at decision time

---

### DEC-011: Project conventions for the Flutter app
**Date:** 2026-10-06
**Status:** Accepted
**Deciders:** Project owner
**Related:** FND-001, DST-001, DEC-006, DEC-010, ISS-006; spec `docs/specs/FND-001-spec.md`

**Context:**
FND-001 creates the Flutter project. Several choices are hard to change later (the app ID is permanent once published) or shape every later feature (folder layout, state management style, lints).

**Decision:**
1. App ID `com.apexguide.app` on Android and iOS; display name "ApexGuide"
2. Minimum Android API 24 and iOS 15, the current floor of Flutter's supported platforms
3. Feature-first folders: `lib/app/`, `lib/core/`, `lib/features/<feature>/{data,domain,presentation}`
4. Riverpod with code generation (`@riverpod`, riverpod_generator, build_runner)
5. very_good_analysis for lints, plus riverpod_lint
6. Build configuration through `--dart-define-from-file` with `config/dev.json` and `config/prod.json`; no secrets in these files
7. iOS build verification is deferred to DST-001; FND-001 proves Android only
8. Interim launcher icon: the "A" mark cropped from `logo_full.svg` on a square white background, until ISS-006 delivers `app_icon`
9. iPhone only on iOS (`TARGETED_DEVICE_FAMILY = 1`); no iPad build (added 2026-10-07)

**Rationale:**
- drift already needs build_runner, so Riverpod code generation adds little cost and catches provider mistakes at build time
- very_good_analysis enforces explicit types, matching the project rule
- The demo key (LIC-006) and the mock/real API switch (DEC-003) both need build-time configuration
- The full logo's wordmark is illegible at launcher size, and store guidelines discourage text in icons

**Alternatives considered:**
- flutter_lints: lighter, less enforcement
- Manual Riverpod providers: no code generation, but more boilerplate and fewer build-time checks
- Minimal iOS CI build in FND-001: rejected by the owner; iOS waits for DST-001

**Consequences:**
- iOS-specific problems (CocoaPods, the SQLite3 Multiple Ciphers native build, PRT-002) surface at DST-001, so DST-001 should be scheduled directly after FND-001
- Devices below Android 7.0 or iOS 15 cannot install the app
- iPads can still run the iPhone app in compatibility mode; a portrait-only iPad build would have needed all orientations or full-screen mode for iPad multitasking

---

### DEC-012: Pin Flutter 3.38.10 until there is a macOS 14+ development machine
**Date:** 2026-10-07
**Status:** Accepted
**Deciders:** Project owner
**Related:** Amends DEC-010 (framework and package versions); ISS-007; FND-001, DST-001

**Context:**
FND-001-T1 found that the Dart VM refuses to start on macOS 12 from Dart 3.11.0 onwards ("Current Mac OS X version 12.0 is lower than minimum supported version 14.0"), tested on the development machine for each Dart release from 3.8 to 3.13. Dart 3.10.x is the last line that runs, shipped with Flutter 3.38.x. The development machine (MacBook Pro 2016, MacBookPro13,2) cannot officially run anything newer than macOS 12.

**Decision:**
Use Flutter 3.38.10 (Dart 3.10.9) for development and CI until a macOS 14+ machine is available, with the newest package versions that support Dart 3.10:

| Package | DEC-010 version | Version under DEC-012 |
| --- | --- | --- |
| Flutter | 3.47.x | 3.38.10 |
| flutter_riverpod | 3.4.3 | 3.1.0 (corrected from 3.3.2 at T4) |
| riverpod_annotation / riverpod_generator | 4.0.7 / 4.0.9 | 4.0.0 / 4.0.0+1 (corrected from 4.0.3 / 4.0.4 at T4) |
| riverpod_lint | 3.1.9 | 3.1.4 |
| go_router | 18.0.2 | 17.5.0 |
| very_good_analysis | 11.0.0 | 10.1.0 |
| build_runner | 2.16.2 | 2.15.1 |
| drift / drift_dev, sqlite3, dio, youtube_player_iframe, flutter_secure_storage, flutter_launcher_icons | unchanged | unchanged |

Versions checked on pub.dev on 2026-10-07; FND-001 pins the exact versions in `pubspec.yaml`. Correction at FND-001-T4: the first check only compared Dart SDK constraints. Flutter 3.38 pins `meta` 1.17.0 through flutter_test, and riverpod_generator 4.0.4+ needs analyzer 12 (meta 1.18), so pub resolves riverpod_generator 4.0.0+1, which locks riverpod_annotation 4.0.0 and flutter_riverpod 3.1.0. riverpod_lint 3.1.4 runs as an analyzer plugin in its own environment and is unaffected.

**Rationale:**
- Development can start now on the existing machine
- Every package keeps the major version chosen in DEC-010 except go_router (17 instead of 18) and very_good_analysis (10 instead of 11), so the later upgrade is small
- One Flutter version across the dev machine and CI avoids "works on my machine" differences

**Alternatives considered:**
- Buy an Apple-silicon Mac now: the long-term fix, deferred by the owner
- OpenCore Legacy Patcher to run macOS 14/15: unofficial, and the T1 chip in this model is only partly supported
- Linux (dual boot or VM): supported for Android, but a weak emulator and a bigger change to the workflow

**Consequences:**
- Upgrade to Flutter 3.47+ once a macOS 14+ machine is available, preferably early while the codebase is small: `flutter pub upgrade --major-versions`, go_router 17 to 18 migration, new very_good_analysis lints, `dart fix --apply`, Flutter breaking changes for 3.41 to 3.47
- Flutter 3.38 receives no further fixes
- DST-001 must confirm that Flutter 3.38.10 builds with the Xcode on GitHub's macOS runners and meets Apple's current App Store SDK requirement
- The emulator is slow on this machine: the first boot needs several minutes of background work, and the Android 16 Play Store image was unusable (ISS-007)

### DEC-013: Proprietary license held by WebMiller
**Date:** 2026-10-07
**Status:** Accepted
**Deciders:** Project owner
**Related:** SET-001, DST-002; `LICENSE`, `docs/boilerplate/LICENSE`

**Context:**
The repository's `LICENSE` was the GPL v3 file from the Claude Code boilerplate by Songbird Digital, which has no connection to ApexGuide. A check on 2026-10-07 of every package the app bundles (Flutter, Riverpod, go_router and their dependencies) and of the planned ones (drift, sqlite3, SQLite3 Multiple Ciphers, dio, youtube_player_iframe, flutter_secure_storage) found only BSD-3-Clause, MIT and Apache-2.0, plus public-domain SQLite. None requires a particular license for the app; all require keeping their copyright notices.

**Decision:**
1. ApexGuide is proprietary: "Copyright (c) 2026 WebMiller, the Netherlands. All rights reserved." in the root `LICENSE`
2. The boilerplate's GPL v3 text moves to `docs/boilerplate/LICENSE` and covers only the boilerplate files (agents, skills, commands and templates in `.claude/`, `.ai/`, `AGENTS.md`, `GEMINI.md`, `SETUP.md`, `TESTING.md`, `CHANGELOG.md`, `docs/boilerplate/`); project content such as `.claude/memory/` is WebMiller's
3. Third-party notices are shown in the app through Flutter's `showLicensePage`, which lists the LICENSE files the Flutter tool bundles automatically; SET-001 adds the Settings entry

**Rationale:**
- Permissive licenses allow closed-source commercial use as long as notices are reproduced
- The boilerplate is development tooling, not part of the shipped app

**Consequences:**
- Before adding a package, check its license; GPL, LGPL, AGPL or MPL code in the app needs a new decision
- The end-user terms for the stores are a separate document (DST-002); legal review recommended before the store release
- Drupal (GPLv2+) runs server-side in a separate repository and does not affect the app's license

---

## Superseded/Deprecated Decisions

*Decisions that have been replaced or are no longer relevant go here for historical reference.*

### DEC-002: App technology stack
**Date:** 2026-10-02
**Status:** Superseded by DEC-010 (2026-10-05)
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
