# ApexGuide – Project & Implementation Plan

Sep 30, 2026 · @King George

## Purpose and scope

ApexGuide is a whitelabel Flutter app for Android and iOS that gives licensed team drivers offline, corner-by-corner guidance for every kart track their team maintains (no limit; roughly 20 to 30 is expected, which only matters for sizing the offline download). Coaches maintain the content, licenses, feedback and branding per team in a multi-tenant Drupal central application; the app syncs from it over a REST API.

This plan is the source for the development phase. It fixes the requirements, architecture, data model, API contract, license rules, screens, backlog, phases, testing, distribution and maintenance approach.

In scope: app v1 (both platforms), central application v1, and three delivery phases up to a maintained production release. Roles: driver (team member, often a minor), coach (content and license admin per team), publisher (your organisation, owner of the store listings and the central application).

## Consolidated requirements

These are the agreed requirements after the analysis round; every story in the backlog traces back to one of these IDs.

| ID | Area | Requirement |
| --- | --- | --- |
| R-01 | Platform | Flutter app, Android and iOS, portrait only, one app name and icon for all tenants |
| R-02 | Platform | UI in English and Dutch; content delivered by the central application in both languages |
| R-03 | Platform | Dark and light mode, following the system setting with a manual override |
| R-04 | Theming | After activation the app applies the tenant logo, primary and secondary color (separate light and dark sets) |
| R-05 | Theming | Native splash stays neutral; the Flutter start screen is branded once the theme is cached |
| R-06 | Tracks | A track has name, address, country, indoor or outdoor flag, layout images and corners |
| R-07 | Tracks | Multiple layouts of one circuit are separate tracks with the layout name as suffix |
| R-08 | Tracks | Track list supports search by name, filter by country and local favorites |
| R-09 | Layout | Layout image with clickable corner numbers at coordinates supplied by the central application, normalized 0 to 1 |
| R-10 | Layout | Pinch-to-zoom on the layout to ease corner selection |
| R-11 | Layout | One layout image per condition; the racing line is drawn in the image |
| R-12 | Corners | Corners are sequential integers; a corner is selectable from the layout and from a numbered list |
| R-13 | Corners | Corner detail shows four sections: Approach, Braking zone, Apex / Turning point, Overtaking / Defending |
| R-14 | Conditions | Dry and wet only; all four sections and the layout image differ per condition |
| R-15 | Conditions | Wet content is mandatory for outdoor tracks and absent for indoor tracks; the toggle is hidden for indoor tracks |
| R-16 | Videos | Videos are YouTube links, streamed online only, never stored on the device, not protected |
| R-17 | Videos | Coaches mark start and end timestamps per corner; the corner detail offers those clips |
| R-18 | Sync | After activation all tenant content (both languages) is downloaded for offline use |
| R-19 | Sync | On every app start the app fetches new and changed tracks in the background, based on a track version bumped by the central application |
| R-20 | Sync | One request returns a full track including corners, content, image references and video markers |
| R-21 | License | Access requires a license key issued by a coach per driver; the key is bound to one app installation and refused on any other until a coach resets the binding |
| R-22 | License | The central application records which person (first name or alias) received which license key |
| R-23 | License | Daily license check when online; the license token has a maximum age of 7 days |
| R-24 | License | Token expired without revocation: local content is wiped, the installation id is kept, and the driver re-enters the same key on the same installation to continue |
| R-25 | License | License revoked by a coach: local data is wiped, the key entry screen is shown and the key is refused from then on |
| R-26 | Protection | Android: FLAG\_SECURE blocks screenshots and recording app-wide |
| R-27 | Protection | iOS: corner text is rendered in a secure text-field layer; no screenshot detection |
| R-28 | Protection | Text cannot be selected or copied; local content is stored encrypted |
| R-29 | Feedback | Anonymous thumbs up or down plus optional text, per track and condition, sent to the central application; no coach response |
| R-30 | UX | Track-day mode: larger type, high contrast, screen stays awake, quick next and previous corner |
| R-31 | Central app | Drupal, multi-tenant: each team has its own coaches, drivers, content, codes, feedback and theme |
| R-32 | Central app | Coaches manage tracks, corners, videos, license keys, key bindings, revocation and theming; they read feedback |

## Out of scope and future releases

Nothing below is built in v1, but the data model and API leave room for each item so none requires a rewrite.

| Feature | Business value | Design hook kept in v1 |
| --- | --- | --- |
| Vector racing lines drawn by the app | Animated dry/wet toggle, braking markers, less image work for coaches | Corner coordinates are already normalized; a line is a list of the same coordinates |
| Personal driver notes per corner | Drivers keep their own learnings next to coach content | Local-only table keyed by track, corner and condition |
| Usage analytics for coaches | Shows which tracks and corners are viewed, where content is missing | Event queue in the local database, flushed when online |
| Setup data per track (gear ratio, tyre pressure) | Premium add-on for teams with owned karts | Optional block on the track entity; hidden when empty |
| Feedback attributed to the driver or alias | Coaches can follow up on specific remarks | Feedback carries the key binding id server-side; alias is only exposed when enabled |
| Multiple layouts under one track entity | Cleaner track list for circuits with many configurations | Track has an optional parent reference and layout name |
| Landscape and tablet layouts | Bigger track map in the paddock | Layout screen is built responsive from the start |
| Push notification on content updates | Drivers know a coach changed something before a race weekend | Track version already supports an updated badge |
| Coach replies to feedback | Two-way coaching | Feedback keeps a thread id field |
| Kart class dimension on corner content | Different advice per class at the same track | Content is keyed by condition; a second key can be added |

## Solution architecture

&#91;embedded content: solution architecture · Drupal, Flutter app, YouTube\]

Coaches work in Drupal; the app pulls everything through the `trackguide` API with a tenant-scoped JWT, stores it encrypted, and only reaches the internet for the daily license check, sync, feedback and YouTube playback.

Stack choices: Flutter 3 with Riverpod for state, go\_router for navigation, drift over SQLCipher for storage, dio for HTTP, youtube\_player\_flutter for video, flutter\_secure\_storage for keys, and two small platform channels for FLAG\_SECURE and the iOS secure layer. Drupal 11 on PHP 8.3 with MariaDB, behind HTTPS on a managed host.

## Data model

One tenant owns tracks, codes, licenses, feedback and a theme; a track owns corners, two layout images and videos; a corner owns one content block per condition, each stored in both languages. The same model is used in Drupal (as content types, paragraphs and custom entities) and in the app's local database (as tables), so the API is a plain serialization of it.

| Entity | Fields | Notes |
| --- | --- | --- |
| Tenant | id, name, default\_language, active | One Drupal group per racing team |
| Theme | tenant\_id, logo (PNG or SVG), light: primary, secondary; dark: primary, secondary; updated\_at | Served with the activation response and refreshed on sync |
| Track | id, tenant\_id, name, address, country (ISO 3166-1 alpha-2), indoor (bool), version (int), updated\_at, deleted (bool) | Version bumps on any change to the track or its children; deleted tracks are removed locally |
| LayoutImage | track\_id, condition (dry or wet), url, width\_px, height\_px, checksum | Wet image only for outdoor tracks; racing line is part of the image |
| Corner | track\_id, number (int, sequential), x (0 to 1), y (0 to 1) | Coordinates relative to the image size; the same point is used on both images |
| CornerContent | corner\_id, condition, language (en or nl), approach, braking\_zone, apex, overtaking | Four plain-text or light-markdown fields; wet rows absent for indoor tracks |
| Video | track\_id, youtube\_id, title, sort\_order | Streamed via the YouTube player; never cached |
| VideoMarker | video\_id, corner\_id, start\_seconds, end\_seconds, condition (dry, wet or both), label | A corner can have markers in several videos |
| LicenseKey | tenant\_id, key (unique, reusable), assigned\_to (first name or alias), created\_by, created\_at, status (active or revoked), revoked\_at | Only assigned\_to is stored about the person |
| KeyBinding | id, tenant\_id, license\_key\_id, installation\_id, platform, app\_version, bound\_at, last\_check\_at, refused\_attempts | At most one binding per key; a second installation is refused and counted until a coach resets the binding |
| Feedback | id, tenant\_id, track\_id, condition, rating (up or down), text, app\_version, created\_at, thread\_id (unused in v1) | Anonymous in v1; device id is not stored on the feedback row |
| Local: SyncState | last\_full\_sync\_at, last\_license\_check\_at, license\_expires\_at, last\_server\_time, tenant\_id | App-only |
| Local: Favorite | track\_id | App-only, lost on wipe or uninstall |

## API contract

Seven purpose-built JSON endpoints under `/api/v1/`, served by a custom Drupal module; the app never talks to Drupal's generic JSON:API. All endpoints except `activate` require `Authorization: Bearer <license token>`; the token is a signed JWT carrying tenant\_id, key\_binding\_id, iat and exp (7 days).

| Method | Path | Purpose | Response |
| --- | --- | --- | --- |
| POST | activate | Bind a license key to this installation, or re-enter it on its bound installation: body {key, installation\_id, platform, app\_version} | 200 {token, expires\_at, server\_time, tenant, theme}; 404 unknown key; 403 revoked; 409 key bound to another installation |
| POST | license/refresh | Daily check; issues a new 7-day token | 200 {token, expires\_at, server\_time}; 401 invalid token; 403 revoked |
| GET | tenant/theme | Logo and colors for both modes | 200 theme with updated\_at; 304 when If-None-Match matches |
| GET | tracks | Index for delta sync | 200 \[{id, version, updated\_at, deleted}\] |
| GET | tracks/{id} | Full track: fields, both layout images, corners, content in both languages, videos and markers | 200 track; 404 if not in tenant |
| GET | media/{id} | Layout image or logo, tenant-checked | 200 binary with ETag; 403 wrong tenant |
| POST | feedback | Body {track\_id, condition, rating, text, app\_version} | 201; queued locally when offline and retried on next start |
| GET | app/config | Minimum supported app version | 200 {min\_version, message}; app shows an update screen below it |

Common rules: every response carries `server_time` in its header; errors use `{error: code, message}`; 403 on any endpoint means revoked and triggers the wipe; 426 means the app version is too old. Images are fetched only through `media/{id}` so a leaked URL is useless without a token.

The track payload, trimmed to its shape:

```json
{
  "id": 12, "version": 7, "name": "Kartbaan Lelystad - Long", "country": "NL",
  "address": "Talingweg 85, Lelystad", "indoor": false,
  "layouts": {
    "dry": {"media_id": "m-1", "width": 2000, "height": 1400, "checksum": "sha256:..."},
    "wet": {"media_id": "m-2", "width": 2000, "height": 1400, "checksum": "sha256:..."}
  },
  "corners": [
    {"number": 1, "x": 0.412, "y": 0.173,
     "content": {
       "dry": {"en": {"approach": "...", "braking_zone": "...", "apex": "...", "overtaking": "..."}, "nl": {}},
       "wet": {"en": {}, "nl": {}}
     }}
  ],
  "videos": [
    {"youtube_id": "dQw4w9WgXcQ", "title": "Onboard, dry",
     "markers": [{"corner": 1, "start": 42, "end": 51, "condition": "dry", "label": "Late apex"}]}
  ]
}
```

Sync on every app start, when online:

1. If the last license check is older than 24 hours, call `license/refresh` first; a 403 aborts sync and wipes.
2. Call `app/config`; block the app if below `min_version`.
3. Call `tracks`; compare each version with the local copy.
4. For each new or changed track call `tracks/{id}`, then download images whose checksum changed; write the track in one transaction so a half-finished sync never shows.
5. Delete local tracks marked deleted or missing from the index.
6. Refresh `tenant/theme` when its updated\_at changed; flush queued feedback.

The first sync after activation runs the same steps with an empty local store and shows a progress screen; later syncs run silently behind the track list.

## License and activation flow

&#91;embedded content: license states · 4 states, revocation in red\]

The app lives in Active and refreshes its token every day it is online; 7 days without a refresh, or a 403 from the server, wipe the content and return the driver to key entry. A valid key re-entered on the same installation restores access; a revoked key or another installation is refused.

Rules the app enforces:

1. First launch generates an installation id that survives every wipe: on Android the app-scoped `ANDROID_ID`, on iOS a UUID stored in the Keychain. Both normally survive a reinstall on the same phone, so re-entry usually works there too, although Apple does not guarantee Keychain persistence.
2. Key entry sends the key and the installation id. An unbound key is bound to this installation; a key already bound here is accepted again; a key bound elsewhere returns 409 and the attempt is counted for the coach.
3. A successful `activate` returns a token with `exp` 7 days ahead plus the tenant theme; the app then runs the full sync.
4. On start and on return to the foreground, if online and the last successful check is more than 24 hours old, the app calls `license/refresh`; a 200 stores the new token and the server time.
5. A refresh that fails for network reasons is ignored; the current token stays valid until its `exp`.
6. When `exp` has passed, or the device clock is earlier than the last stored server time, the app wipes everything except the installation id and shows the key entry screen with the reason.
7. A 403 from any endpoint means revoked: the same wipe, and the key is refused on re-entry until a coach reissues or reactivates it.
8. A driver with a new phone, or an iOS reinstall where the Keychain id was lost, asks the coach to reset the binding; the same key then works on the new installation.
9. Coaches see per key: alias, bound platform, app version, last check, refused attempts and status; reset and revoke are single actions with a confirmation.

## Content protection

The corner text is the asset; it is blocked from capture on Android, hidden from capture on iOS, and encrypted on disk on both. Layout images get the same storage encryption. Videos are public YouTube links and get no protection.

| Layer | Android | iOS |
| --- | --- | --- |
| Screenshots and recording | `FLAG_SECURE` on the main activity, set at start-up, covers every screen | Corner text rendered in a native `UITextField` with `isSecureTextEntry` as its layer host, embedded through a platform view; captures show the text area blank |
| Text selection and copy | Flutter `SelectionContainer.disabled` around content; no share or copy actions | Same, plus the secure layer never exposes a selection |
| Storage | Encrypted SQLite (drift with SQLCipher); key generated per install and stored in Android Keystore | Same database; key in the Keychain with `whenUnlockedThisDeviceOnly` |
| Images | Written to the app sandbox encrypted with the same key; decrypted into memory on view | Same |
| Transport | TLS only; license token in the Authorization header; media only via the tenant-checked endpoint | Same |
| Wipe | Delete the database, image folder, Keystore key and shared preferences, keep only the installation id, then restart to the key entry screen | Same via Keychain |

Known limits, to be stated to coaches: the iOS secure layer is a widely used but unofficial technique that an iOS update could weaken; a second phone can photograph any screen; a rooted or jailbroken device can be read by its owner. Root and jailbreak detection is not in v1.

Accessibility: the secure layer hides text from screen readers too. Accept this for v1 and revisit if a driver needs it.

## App design

Seven screens, three levels deep: activation, track list, track, corner. The app opens on the track list once activated; the license state gates everything below the activation screen.

| Screen | Purpose | Key elements |
| --- | --- | --- |
| Activation | Enter the license key | Key field, language switch, privacy note, error states for unknown, revoked, bound elsewhere and offline |
| First sync | Download all tenant content | Branded progress screen with track count; retry on failure |
| Track list | Find a track | Search by name, country filter chips, favorites first, indoor or outdoor badge, updated badge |
| Track | Select a corner | Zoomable layout image with numbered hotspots, dry/wet toggle (outdoor only), numbered corner list, videos row, feedback button |
| Corner | Read the guidance | Condition badge, the four sections in order, previous and next corner, video clip buttons that open the YouTube player at the marker |
| Feedback sheet | Send a remark | Thumbs up or down, optional text, condition preselected from the toggle, sent or queued |
| Settings | Preferences and status | Theme: system, light, dark; language: en, nl; track-day mode; license status and next check; version; wipe and re-activate |
| Locked | Token expired offline | Message that the license expired and data was cleared, then the key entry screen |

Theming: the tenant primary color drives app bar, toggle and hotspots; the secondary drives accents and the active corner; each has a light and dark value from the central application. Logo shows on the branded start screen and the track list header; the activation screen always uses the neutral publisher logo, because after a wipe no tenant is known.

Language: the app follows the device language for en and nl, with an override in Settings; content and UI switch together because both languages are stored locally.

Track-day mode: a Settings switch that raises the base font one step, forces high contrast, keeps the screen awake on the Track and Corner screens, and enlarges the previous and next controls for use with gloves.

Corner hotspots: each number is drawn at (x times image width, y times image height) inside the zoomable viewer, with a minimum tap target of 44 px on screen regardless of zoom. The dry/wet toggle swaps the image and the loaded content set; the selected corner stays selected.

## Central application (Drupal)

Drupal 11 with the Group module for tenancy, Paragraphs for corners and video markers, core Content Translation for en and nl, Media for images, and one custom module `trackguide` for the API, licenses, feedback and theming. Coaches only ever see their own group; the publisher administers all groups.

| Building block | Module | What it holds |
| --- | --- | --- |
| Tenant | Group (group type `racing_team`) | Team name, default language, coach members with the group role `coach`, theme fields (logo, four colors) |
| Track | Node type `track`, group content, translatable | Name, address, country, indoor flag, dry image, wet image (required when outdoor), corners, videos |
| Corner | Paragraph `corner` | Number, x, y, dry content (4 translatable text fields), wet content (4 translatable text fields) |
| Video | Paragraph `video` with nested `video_marker` | YouTube URL, title, markers: corner number, start, end, condition, label |
| Track version | Node `changed` timestamp plus revision id | Saving the node form after any paragraph edit updates `changed`; the API sends the revision id as `version` |
| License key | Custom entity `license_key` | Key, assigned\_to, created\_by, status, revoked\_at |
| Key binding | Custom entity `key_binding` | Installation id, platform, app version, bound at, last check, refused attempts |
| Feedback | Custom entity `feedback` | Track, condition, rating, text, app version, created at |
| API | Custom routes in `trackguide` | The eight endpoints, JWT issuing and validation (firebase/php-jwt), key binding checks, tenant scoping on every query |
| Validation | Custom constraints | Sequential corner numbers, coordinates within 0 to 1, wet content required for outdoor tracks, layout images at most 2000 px on the long side (PNG or JPEG), both languages filled before a track can be published |

Coach workflows, each a page inside the group:

1. Create or edit a track: fill the fields, upload both images, add corners with coordinates picked by clicking on the image (a small JavaScript picker writes x and y), add videos and markers, translate, publish.
2. Issue a license key: enter first name or alias, get a generated key of 4 groups of 4 characters to hand over; keys stay viewable and the list shows unbound, bound (platform, last check, refused attempts) and revoked keys.
3. Revoke a driver: one action on the key; the driver's next refresh returns 403, the app wipes, and the key is refused from then on.
4. Reset a binding: one action that clears the bound installation when a driver changes phones or reinstalls; the same key then works on the new installation.
5. Set the theme: upload the logo and pick four colors; a preview shows both modes.
6. Read feedback: a list filtered by track and condition, newest first, with an archive action.

Publisher tasks: create groups, add the first coach per group, maintain the minimum app version, apply Drupal security updates.

## Phases and milestones

&#91;embedded content: roadmap · 3 phases, 2 gates\]

Phase 1 delivers everything the pilot needs on both platforms and nothing more; Phase 2 turns the pilot build into a store release; Phase 3 adds the operational tooling and opens the future-release backlog. No calendar dates are set yet; the backlog's Must and Should stories in Phase 1 define its size.

Phase 1 milestones, in order:

1. API contract signed off from this document; Apple and Google developer accounts opened.
2. Drupal v1: tenancy, content types, coach editor, the `activate`, `license/refresh`, `tracks` and `tracks/{id}` endpoints, demo tenant filled.
3. App alpha on Android: activation, sync, track list, track and corner screens, protection.
4. App alpha on iOS with the secure layer; feedback and video markers on both.
5. Pilot build handed to the drivers when ready; used at the next training sessions and races; exit criteria reviewed after three on-track days.

## Development backlog

Twenty-nine stories in eight epics; Must and Should stories in Phase 1 form the pilot release, and Priority and Phase are editable here as the plan evolves.

| Epic | Story | Req | Priority | Phase |
| --- | --- | --- | --- | --- |
| Foundation | Flutter project: navigation, theme engine, en/nl localization scaffold, dark/light | R-01, R-02, R-03 | Must | Phase 1 |
| Foundation | Encrypted local database, repository layer and sync engine | R-18, R-28 | Must | Phase 1 |
| Foundation | Drupal install: Group, content types, paragraphs, translation, `trackguide` module skeleton | R-31 | Must | Phase 1 |
| License | Key entry screen and `activate` endpoint binding a key to one installation | R-21, R-22 | Must | Phase 1 |
| License | Daily refresh, 7-day token, wipe on expiry and on 403 keeping the installation id, clock-tamper guard | R-23, R-24, R-25 | Must | Phase 1 |
| License | Coach pages: issue, list, reset and revoke license keys | R-32 | Must | Phase 1 |
| License | Binding reset flow, including the 409 message in the app telling the driver to contact the coach | R-21 | Should | Phase 2 |
| Content | Track list with search, country filter, favorites and indoor badge | R-06, R-08 | Must | Phase 1 |
| Content | Track screen: zoomable layout image with corner hotspots and corner list | R-09, R-10, R-12 | Must | Phase 1 |
| Content | Dry/wet toggle swapping image and content; hidden for indoor tracks | R-11, R-14, R-15 | Must | Phase 1 |
| Content | Corner detail with the four sections and previous/next navigation | R-13 | Must | Phase 1 |
| Content | Delta sync by track version, deletes, first-sync progress screen | R-19, R-20 | Must | Phase 1 |
| Content | Coach track editor with click-to-place corner coordinate picker | R-09, R-32 | Must | Phase 1 |
| Content | Coach translation workflow and publish validation (both languages, wet for outdoor) | R-02, R-15 | Must | Phase 1 |
| Video | YouTube player opening at a corner marker from the corner detail | R-16, R-17 | Should | Phase 1 |
| Video | Coach video and marker editor | R-17 | Should | Phase 1 |
| Protection | Android FLAG\_SECURE and disabled text selection | R-26, R-28 | Must | Phase 1 |
| Protection | iOS secure text-field layer as a platform view for corner content | R-27 | Must | Phase 1 |
| Protection | Wipe routine: database, images, keys, preferences | R-25 | Must | Phase 1 |
| Feedback | Feedback sheet with offline queue and retry | R-29 | Should | Phase 1 |
| Feedback | Coach feedback list with filters and archive | R-29, R-32 | Should | Phase 1 |
| Theming | Tenant theme endpoint, coach theme page with preview, branded start screen | R-04, R-05 | Must | Phase 1 |
| UX | Track-day mode | R-30 | Could | Phase 2 |
| UX | Updated badge on tracks changed since last visit | R-19 | Could | Phase 2 |
| UX | Minimum-version check and update screen | R-19 | Should | Phase 2 |
| Distribution | Manual Android APK and iOS TestFlight builds for the pilot | R-01 | Must | Phase 1 |
| Distribution | Store listings, Apple unlisted distribution request, reviewer demo code | R-01 | Must | Phase 2 |
| Operations | GitHub Actions pipeline with automated store uploads | R-01 | Should | Phase 3 |
| Operations | Sentry crash reporting and maintenance calendar | R-01 | Should | Phase 3 |

## Testing and pilot plan

Automated tests cover the two parts that fail silently, the license state machine and the sync engine; everything visual is tested by hand on real devices, then by a pilot group of drivers and one coach.

| Level | What | How |
| --- | --- | --- |
| Unit (app) | License states: bind, re-enter on the same installation, refuse on another, refresh, expiry wipe, revocation, clock moved back, offline paths | Dart tests with a fake clock and a fake API |
| Unit (app) | Sync: new, changed, deleted tracks; failed image download; interrupted sync leaves the old track intact | Dart tests against an in-memory database |
| Unit (Drupal) | Endpoints: tenant scoping, code reuse refused, revoked returns 403, version bumps on paragraph edits | PHPUnit kernel tests |
| Manual matrix | Every screen in light and dark, en and nl, indoor and outdoor track, with and without wet content, with and without videos | Checklist run per build on Android 12+ and iOS 16+ |
| Protection | Screenshot and screen recording attempts on both platforms; text selection; database file unreadable without the key | Manual, recorded in the checklist |
| Offline | Airplane mode after sync; 8 days offline (device clock forward with a fake-time build); wipe, re-enter the key, re-sync | Manual on both platforms |
| Pilot | Tenant Chrono Motorsport with coaches Max and Vincent; 5 to 10 drivers over the first available races and training sessions; 5 to 10 real tracks | Feedback through the app plus a short interview |

There is no fixed timeline: the app is ready when it is ready, and the pilot starts at the first races or training sessions after that. Training sessions suit the first build best, because a failing app costs nothing there; races then test the offline and license behaviour under real conditions.

Candidate occasions, in no committed order: the NK Huurkarten rounds at Antwerpen (17 October), Eefde (28 November) and Lelystad (12 December 2026), later championship rounds, and Chrono Motorsport training days. The exit criteria are reviewed after the app has been used on three on-track days, whichever they turn out to be.

Pilot exit criteria: no data loss reported, no unrecoverable license state, every track viewable offline at the track, coach can maintain content without developer help, and the feedback feature has been used by at least half the pilot drivers.

Test data: one demo tenant in Drupal with one indoor and one outdoor track, both languages filled, one video with two markers, and a standing license key for the Apple reviewer.

## Distribution

The pilot runs on manually built packages; production uses the public Play listing gated by the key entry screen and Apple's unlisted distribution, so the app is installable by link but not searchable.

| Stage | Android | iOS |
| --- | --- | --- |
| Pilot (Phase 1) | Signed APK shared by link; testers allow installs from unknown sources | TestFlight internal group (up to 100 testers); needs an Apple Developer account and a build machine on macOS 15.6 or later with Xcode 26, which the 2016 MacBook Pro cannot provide, so a GitHub Actions macOS runner does the iOS builds |
| Wider test (Phase 2) | Play Console closed testing track with a tester list | TestFlight external group after a light review |
| Production (Phase 2) | Public Play listing; the store text says a team code is required. Google's private-app option needs managed devices, so it is not used | Unlisted App Store distribution, requested through Apple's form; the app has a link but no search presence |
| Updates | Play Console upload per release | App Store Connect upload per release |

Store review needs: a demo license key and a short reviewer note explaining the team-only model; a privacy policy URL covering the alias and installation id; an age rating that fits minors; screenshots in both modes.

Accounts to open early: Google Play developer account, Apple Developer Program, and a code-signing setup kept by the publisher. Both accounts take days to approve, so they start in Phase 1.

## Maintenance plan (Phase 3)

After the pilot the app moves to a fixed rhythm: a monthly maintenance release, security updates within a week, and one planned release per OS cycle. Nothing here is needed to ship the pilot.

| Item | Rhythm | What is done |
| --- | --- | --- |
| Drupal security updates | Weekly check, patch within 7 days for critical | Composer update on a staging copy, smoke test of the API, deploy |
| Flutter and package updates | Monthly | Upgrade, run the unit tests, manual matrix on both platforms |
| OS releases | Yearly, iOS in September and Android in the third quarter | Test on the beta at least a month ahead, with attention to the iOS secure layer and Android FLAG\_SECURE behaviour |
| Store policy changes | As announced | Check target SDK and privacy declarations; Play raises the required target SDK every year |
| CI/CD | Set up once, then per commit | GitHub Actions: tests, build the APK on Linux and the IPA on a macOS runner, upload to Play internal and TestFlight |
| Crash reporting | Continuous | Sentry for Flutter and for the Drupal module, alerts on new crash types, no personal data in reports |
| License administration | As needed | Coaches revoke and reissue; the publisher answers escalations |
| Backups | Daily | Drupal database and media files, restore tested quarterly |
| Token secret rotation | Yearly or on suspicion | New signing key; old tokens keep validating for 7 days |

Support model: drivers ask their coach; coaches reach the publisher through a single email address; a known-issues page lives in the central application.

## Risks, assumptions and open decisions

The three risks that can stop the pilot are iOS build access, the iOS secure layer and the Drupal custom module; each has a fallback.

| Risk | Impact | Mitigation |
| --- | --- | --- |
| iOS builds need Xcode 26 on macOS 15.6+, which the 2016 MacBook Pro cannot run | No TestFlight or store uploads; iOS slips out of Phase 1 | The 2016 Intel MacBook Pro stops at macOS 12 and cannot run Xcode 26, which App Store Connect and TestFlight have required since 28 April 2026. Write Flutter code on it, but build and upload iOS on a GitHub Actions macOS runner (the same pipeline Phase 3 automates) or a used Apple-silicon Mac mini |
| iOS secure text-field layer breaks on a new iOS version | Corner text visible in screenshots on iOS | Layer is isolated in one platform view; fallback is blur-on-background plus screenshot detection |
| Drupal custom module grows beyond a small module | Central application delays the app | Freeze the API contract in this document first; build the app against a mocked API in parallel |
| Coaches find the Drupal editing UI too heavy | Content stays incomplete | Coordinate picker and inline paragraph editing; a coach joins the pilot from day one |
| Apple rejects a login-only app or the unlisted request | No iOS production release | Reviewer notes with a demo code; TestFlight external testing as a bridge |
| Multi-tenant leak through a missed group check | One team sees another team's tracks | Every endpoint scoped by the tenant claim in the token; a kernel test per endpoint asserts cross-tenant 403 |
| Device clock manipulation extends offline access | Revoked driver keeps content for longer | Token exp is checked against the last server time; a backwards jump locks the app |
| Drivers are minors | GDPR obligations on personal data | Only a first name or alias is stored; feedback is anonymous; no analytics in v1; privacy policy reviewed before the store release |

Assumptions: one tenant per device (a driver in two teams needs two devices or a re-activation); the app keeps both languages downloaded and switches locally; a license key stays valid until revoked and can be re-entered any number of times on its bound installation; the installation id survives wipes and, in practice, reinstalls (Android app-scoped id, iOS Keychain item); the layout images come from coaches already sized and oriented, with the racing line drawn in; corner coordinates apply equally to the dry and wet image because both share the same canvas.

Open decisions before development starts:

- [x] App name: ApexGuide; the neutral icon is still to be designed
- [x] Crash reporting: Sentry; CI: GitHub Actions, with a macOS runner for iOS builds
- [x] License key format: 4 groups of 4 characters, no ambiguous letters; coaches can view existing keys in the central application
- [x] Maximum layout image size: 2000 px on the long side, PNG or JPEG
- [x] Pilot tenant: Chrono Motorsport, coaches Max and Vincent
- [x] Pilot period: not fixed; the app is ready when it is ready, then the next races and training sessions are used
