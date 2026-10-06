# FND-001: Flutter project scaffold

## Overview

Create the ApexGuide Flutter project that every later feature builds on: an Android and iOS app with one name and icon for all tenants (R-01), locked to portrait, with Riverpod, go_router placeholder routes for every screen, strict lints, build configuration through `--dart-define-from-file`, and a working test setup. FND-001 also sets up the development machine, which has no Flutter installed yet. Stack versions come from DEC-010; project conventions are recorded in DEC-011.

## User Stories

**Primary:** As the developer, I want a working, linted, tested Flutter project with navigation and state management wired up, so every later feature has a consistent place to land.

## Acceptance Criteria

- [ ] App builds and runs on an Android emulator or device
- [ ] Portrait orientation locked in Dart, `AndroidManifest.xml` and `Info.plist`
- [ ] App ID `com.apexguide.app` on both platforms; display name "ApexGuide"; minimum Android API 24 and iOS 15
- [ ] go_router placeholder routes for start, activation, first sync, track list, track, corner, settings and locked
- [ ] Riverpod wired with a `ProviderScope` at the root and code generation through `build_runner`
- [ ] `AppConfig` read from `config/dev.json` or `config/prod.json` via `--dart-define-from-file`
- [ ] `flutter analyze` (very_good_analysis) and `flutter test` run clean, with app, router and config tests
- [ ] Launcher icons generated from the "A" mark of `logo_full.svg`, on a square white background (Android adaptive icon and iOS)
- [ ] Exact versions from DEC-010 pinned for the packages FND-001 adds

## Scope

**Out of scope:**
- iOS build verification: deferred to DST-001 (DEC-011), which should be scheduled directly after FND-001
- Theme engine (FND-002), localization (FND-003), database (FND-004), API client and mock API (FND-005)
- License-state redirects (LIC-003); FND-001 only adds the router hook where they plug in
- Signed builds and store setup (DST-001, DST-002)

## Technical Design

### Development environment

The development machine is a 2016 MacBook Pro on macOS 12.7.6 (Intel). Flutter supports macOS 12 as a host but has deprecated Intel Macs. Xcode cannot be installed on macOS 12, so iOS builds run on a GitHub Actions macOS runner (DEC-006). An Android SDK folder already exists at `~/Library/Android/sdk`.

### Project creation

- `flutter create --platforms android,ios --project-name apexguide`
- Android: `applicationId` and `namespace` set to `com.apexguide.app`, `minSdk` 24
- iOS: `PRODUCT_BUNDLE_IDENTIFIER` set to `com.apexguide.app`, deployment target 15.0
- Display name "ApexGuide" on both platforms

### Folder structure

```
lib/
  main.dart                  # reads config, ProviderScope, portrait lock, runApp
  app/
    app.dart                 # MaterialApp.router
    router.dart              # go_router provider and route table
    routes.dart              # route names and paths as constants
  core/
    config/app_config.dart   # values from --dart-define-from-file
  features/
    <feature>/
      data/                  # repositories, API and database access (later features)
      domain/                # models and business rules (later features)
      presentation/          # screens and widgets
config/
  dev.json                   # mock API, development values; no secrets
  prod.json                  # real API; no secrets
test/
  app_test.dart
  router_test.dart
  config_test.dart
```

Feature-first layout: each backlog area (activation, sync, tracks, settings, license) keeps its own code together.

### Routes

| Path | Screen | Filled in by |
| --- | --- | --- |
| `/` | Branded start screen | THM-002 |
| `/activate` | Activation | LIC-002 |
| `/sync` | First sync | SYN-003 |
| `/tracks` | Track list | CNT-001 |
| `/tracks/:trackId` | Track | CNT-002 |
| `/tracks/:trackId/corners/:cornerNo` | Corner | CNT-005 |
| `/settings` | Settings | SET-001 |
| `/locked` | Locked | LIC-004 |

The feedback sheet is a bottom sheet over the Track screen, not a route. Route paths and names live in `routes.dart` so screens never use string literals. The router is exposed through a Riverpod provider so LIC-003 can add a `redirect` driven by license state.

### Build configuration

`AppConfig` reads values defined at build time with `String.fromEnvironment` and `bool.fromEnvironment`, passed with `flutter run --dart-define-from-file=config/dev.json`. Initial keys:

| Key | dev | prod |
| --- | --- | --- |
| `API_BASE_URL` | mock API URL (FND-005) | production URL |
| `USE_MOCK_API` | `true` | `false` |

LIC-006 adds the demo key here later. These files hold no secrets; signing keys and tokens never enter the repository.

### Packages added in FND-001

| Package | Kind | Version |
| --- | --- | --- |
| flutter_riverpod | dependency | 3.x, pinned at T4 |
| riverpod_annotation | dependency | matching riverpod_generator |
| go_router | dependency | 18.x, pinned at T5 |
| riverpod_generator | dev | pinned at T4 |
| build_runner | dev | pinned at T4 |
| very_good_analysis | dev | 11.x, pinned at T3 |
| riverpod_lint | dev | pinned at T3; check whether it needs custom_lint or the analyzer plugin system |
| flutter_launcher_icons | dev | 0.14.x, pinned at T6 |

Other DEC-010 packages are added by the features that need them.

### Key decisions

Recorded as DEC-011: app ID, minimum versions, folder layout, Riverpod code generation, very_good_analysis, build configuration through `--dart-define-from-file`, iOS verification deferred to DST-001, and the interim launcher icon.

### Risks

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Android Studio or current SDK tools do not run on macOS 12 Intel | Medium | High | Verify in T1; fall back to the command-line SDK tools in `~/Library/Android/sdk` |
| Flutter drops Intel Mac host support during the project | Medium | High | Pin Flutter 3.47.x; plan for an Apple-silicon Mac (spec risk table) |
| iOS-specific problems surface late | Medium | Medium | Schedule DST-001 directly after FND-001 |
| Launcher icon derived from `logo_full.svg` looks rough at small sizes | Low | Low | Replace with `app_icon` when ISS-006 delivers it; one file and one command |

## Implementation Tasks

1. **FND-001-T1**: Development environment
   - Description: Install Flutter 3.47.x, complete the Android SDK (command-line tools, platform, build-tools, emulator), create an emulator, accept licenses; `flutter doctor` green for Android. Some steps need the owner to run installers.
   - Files: `SETUP.md`
   - Tests: `flutter doctor`; `flutter --version` reports 3.47.x
   - Depends on: none
   - Estimate: M

2. **FND-001-T2**: Create the project
   - Description: `flutter create`; set app ID, display name, minimum versions and portrait lock on both platforms
   - Files: `pubspec.yaml`, `android/app/build.gradle(.kts)`, `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`, `ios/Runner.xcodeproj/project.pbxproj`, `lib/main.dart`
   - Tests: default widget test passes; app starts on the emulator in portrait and stays portrait when rotated
   - Depends on: T1
   - Estimate: S

3. **FND-001-T3**: Lints
   - Description: very_good_analysis and riverpod_lint; fix all findings in generated code
   - Files: `analysis_options.yaml`, `pubspec.yaml`
   - Tests: `flutter analyze` reports no issues
   - Depends on: T2
   - Estimate: S

4. **FND-001-T4**: Riverpod and build configuration
   - Description: Riverpod with code generation and `build_runner`; `ProviderScope` at the root; `AppConfig` and its provider; `config/dev.json` and `config/prod.json`; folder structure from this spec
   - Files: `lib/main.dart`, `lib/app/app.dart`, `lib/core/config/app_config.dart`, `config/*.json`, `pubspec.yaml`
   - Tests: `test/config_test.dart` (values parsed, defaults when undefined)
   - Depends on: T3
   - Estimate: S

5. **FND-001-T5**: Router and placeholder screens
   - Description: go_router provider, route constants, one placeholder screen per route in its feature folder
   - Files: `lib/app/router.dart`, `lib/app/routes.dart`, `lib/features/*/presentation/*_screen.dart`
   - Tests: `test/router_test.dart` (every route renders its placeholder, path parameters reach the screen, unknown path shows an error screen); `test/app_test.dart` (app boots to `/`)
   - Depends on: T4
   - Estimate: M

6. **FND-001-T6**: Launcher icon
   - Description: Crop the "A" mark with racing line from `logo_full.svg` into a square SVG with a white background, render a 1024 × 1024 PNG, generate icons with flutter_launcher_icons (Android adaptive icon and iOS)
   - Files: `assets/icon/app_icon.svg`, `assets/icon/app_icon.png`, `flutter_launcher_icons.yaml`, generated platform icon files
   - Tests: launcher icon visible and legible on the emulator home screen
   - Depends on: T2
   - Estimate: S

7. **FND-001-T7**: Wrap-up
   - Description: README run and test commands, full analyze and test run, run on the emulator, update domain memory
   - Files: `README.md`, `.claude/memory/features.json`, `.claude/memory/progress.log`
   - Tests: `flutter analyze` and `flutter test` clean; manual smoke test of all routes
   - Depends on: T5, T6
   - Estimate: S

**Order:** T1 → T2 → T3 → T4 → T5 → T7. T6 can run alongside T3–T5.

**Estimated effort:** 6–9 hours; most uncertainty is in T1.

## Test Plan

### Unit Tests
- `AppConfig`: parses values from the environment; sensible defaults when a key is missing

### Widget Tests
- App boots to the start route inside a `ProviderScope`
- Every route renders its placeholder; path parameters (`trackId`, `cornerNo`) reach the screen
- Unknown path shows the error screen

### Manual
- Emulator: app starts, stays portrait on rotation, launcher icon and name correct

## Rollout Plan

- [ ] Feature flag: none (scaffold)
- [ ] Metrics: none
- [ ] Rollback: revert the commits; nothing depends on FND-001 yet

## Open Questions

- Does Android Studio, or only the command-line SDK tools, run on macOS 12 Intel? (T1)
- Does riverpod_lint use custom_lint or the analyzer plugin system in its current version? (T3)

---
Created: 2026-10-06
Last Updated: 2026-10-06
Status: Ready for Implementation
