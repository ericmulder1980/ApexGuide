# Codex Review Task: FND-001 Flutter project scaffold

**Branch:** `review/codex/FND-001` (same commits as `feature/FND-001`)
**Base:** `main`
**Created:** 2026-10-07
**Status:** Open
**Output:** `.ai/tasks/review/261007-codex-FND-001-findings.md` (format in `AGENTS.md`)

## Context

ApexGuide is a whitelabel Flutter app (Android + iPhone) for offline kart track guidance. FND-001 creates the project every later feature builds on. This is Dart/Flutter, not TypeScript; apply the TypeScript strictness points in `AGENTS.md` as "explicit types, no `dynamic` without reason".

- Spec: `docs/specs/FND-001-spec.md`
- Decisions: `.claude/memory/decisions.md` (DEC-010 stack, DEC-011 conventions, DEC-012 Flutter 3.38.10 pin, DEC-013 license)
- Stack: Flutter 3.38.10, flutter_riverpod 3.1.0 with code generation, go_router 17.5.0, very_good_analysis 10.1.0, riverpod_lint 3.1.4 (analyzer plugin)

## Scope

- `lib/` (skip style in generated `*.g.dart`)
- `test/`
- `pubspec.yaml`, `analysis_options.yaml`, `config/*.json`, `flutter_launcher_icons.yaml`
- `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`, security-relevant settings in `ios/Runner.xcodeproj/project.pbxproj`

Out of scope: generated icon PNGs, the boilerplate files (`.claude/` agents and skills, `.ai/`), theme, database, API client and license logic (later features).

## Questions for the reviewer

1. Is the router provider a sound hook for LIC-003's license-state redirect, including the initial route that Android's `FlutterActivity` accepts through the `route` intent extra?
2. Does `AppConfig` defaulting to the mock API without a config file hold up for release builds?
3. Are the tests meaningful, or do any pass without exercising the behaviour they name?
4. Anything in the Android or iOS project settings that is insecure by default for an app that will store a license token and an encrypted database?
