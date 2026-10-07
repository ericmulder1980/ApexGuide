# ApexGuide

Whitelabel Flutter app for Android and iPhone that gives licensed kart drivers offline, corner-by-corner track guidance. Content, licenses and theming come from a multi-tenant Drupal central application, which lives in a separate repository.

## Requirements

- Flutter 3.38.10 (Dart 3.10.9), pinned by DEC-012 until a macOS 14+ development machine is available
- JDK 21 and the Android SDK command-line tools
- iOS builds run on a GitHub Actions macOS runner (DEC-006)

Setup steps for the development machine are in [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).

## Commands

| Task | Command |
| --- | --- |
| Run against the mock API | `flutter run --dart-define-from-file=config/dev.json` |
| Run against production | `flutter run --dart-define-from-file=config/prod.json` |
| Tests | `flutter test` |
| Lints (very_good_analysis and riverpod_lint) | `flutter analyze` |
| Format | `dart format lib test` |
| Code generation (Riverpod, later drift) | `dart run build_runner build` |
| Launcher icons | `dart run flutter_launcher_icons`, then `git checkout -- ios/Runner.xcodeproj/project.pbxproj` |
| Android debug APK | `flutter build apk --debug --dart-define-from-file=config/dev.json` |

Without `--dart-define-from-file` the app falls back to the mock API. Generated `*.g.dart` files are committed; run code generation after changing a provider. The production API URL in `config/prod.json` is not set yet (ISS-008).

## Project layout

```
lib/
  main.dart           # portrait lock, ProviderScope, runApp
  app/                # MaterialApp.router, go_router provider, route constants
  core/               # shared code: build configuration, widgets
  features/<area>/    # data, domain and presentation per backlog area
config/               # build-time values per environment; no secrets
assets/icon/          # launcher icon sources
test/
```

## Documentation

| Topic | Location |
| --- | --- |
| Product spec and implementation plan | [docs/specs/Track Guide – Project & Implementation Plan.md](docs/specs/Track%20Guide%20%E2%80%93%20Project%20%26%20Implementation%20Plan.md) |
| Architecture | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| Local database schema | [docs/database/mobile-erd.md](docs/database/mobile-erd.md) |
| Feature specs | [docs/specs/](docs/specs/) |
| Decisions | [.claude/memory/decisions.md](.claude/memory/decisions.md) |
| Known issues | [.claude/memory/issues.md](.claude/memory/issues.md) |
| Visual design (prototype) | [reference/prototype/](reference/prototype/) |
| Claude Code boilerplate used for this repo | [docs/boilerplate/README.md](docs/boilerplate/README.md) |

## License

Proprietary. Copyright © 2026 WebMiller. All rights reserved; see [LICENSE](LICENSE). Open-source packages used by the app keep their own licenses; the app lists them on an open-source licenses page in Settings (SET-001). Files from the Claude Code boilerplate are GPL v3; see [docs/boilerplate/LICENSE](docs/boilerplate/LICENSE).
