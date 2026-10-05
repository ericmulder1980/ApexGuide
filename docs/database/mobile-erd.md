# ApexGuide Mobile – Local Database ERD

Status: **Proposal**, not implemented yet. Based on `docs/specs/Track Guide – Project & Implementation Plan.md` (Data model, API contract, Content protection).

Engine: SQLite encrypted with SQLite3 Multiple Ciphers, accessed through drift (DEC-010). The database key is generated per install and stored in Android Keystore / iOS Keychain.

---

## 1. Full overview

```mermaid
erDiagram
    TENANT ||--|| THEME : "is branded by"
    TENANT ||--|| SYNC_STATE : "is synced by"
    TRACK ||--|{ LAYOUT_IMAGE : "has 1 (indoor) or 2 (outdoor)"
    TRACK ||--|{ CORNER : "has"
    CORNER ||--|{ CORNER_CONTENT : "has per condition and language"
    TRACK ||--o{ VIDEO : "has"
    VIDEO ||--o{ VIDEO_MARKER : "has"
    CORNER ||--o{ VIDEO_MARKER : "is shown in"
    TRACK ||--o| FAVORITE : "can be"
    TRACK ||--o{ FEEDBACK_QUEUE : "receives"

    TENANT {
        int id PK "from activate response"
        text name
        text default_language "en or nl"
    }

    THEME {
        int tenant_id PK, FK
        text logo_path "encrypted file on disk"
        text light_primary "hex color"
        text light_secondary "hex color"
        text dark_primary "hex color"
        text dark_secondary "hex color"
        datetime updated_at "compared on sync"
    }

    SYNC_STATE {
        int id PK "always 1 (single row)"
        int tenant_id FK
        datetime last_full_sync_at
        datetime last_license_check_at "refresh when older than 24h"
        datetime license_expires_at "token exp, max 7 days"
        datetime last_server_time "clock-tamper guard"
    }

    TRACK {
        int id PK "server id"
        text name "layout name as suffix"
        text address
        text country "ISO 3166-1 alpha-2"
        bool indoor "hides dry/wet toggle"
        int version "server revision id, drives delta sync"
        datetime updated_at
    }

    LAYOUT_IMAGE {
        int track_id PK, FK
        text condition PK "dry or wet"
        text media_id "fetched via media/{id}"
        int width_px
        int height_px
        text checksum "sha256, re-download when changed"
        text local_path "encrypted file on disk"
    }

    CORNER {
        int track_id PK, FK
        int number PK "sequential 1..n"
        real x "0 to 1, relative to image width"
        real y "0 to 1, relative to image height"
    }

    CORNER_CONTENT {
        int track_id PK, FK
        int corner_number PK, FK
        text condition PK "dry or wet (no wet for indoor)"
        text language PK "en or nl"
        text approach
        text braking_zone
        text apex
        text overtaking
    }

    VIDEO {
        int track_id PK, FK
        text youtube_id PK "streamed, never cached"
        text title
        int sort_order "array position in payload"
    }

    VIDEO_MARKER {
        int id PK "local autoincrement"
        int track_id FK
        text youtube_id FK
        int corner_number FK
        int start_seconds
        int end_seconds
        text condition "dry, wet or both"
        text label
    }

    FAVORITE {
        int track_id PK, FK "local only, lost on wipe"
    }

    FEEDBACK_QUEUE {
        int id PK "local autoincrement"
        int track_id FK
        text condition "dry or wet"
        text rating "up or down"
        text text "optional"
        text app_version
        datetime created_at
        int attempts "retried on next app start"
    }
```

---

## 2. Track content (synced from the central application)

Everything in this group is replaced in **one transaction per track** during sync (`tracks/{id}`), so a half-finished sync never shows.

```mermaid
erDiagram
    TRACK ||--|{ LAYOUT_IMAGE : "has"
    TRACK ||--|{ CORNER : "has"
    CORNER ||--|{ CORNER_CONTENT : "has"
    TRACK ||--o{ VIDEO : "has"
    VIDEO ||--o{ VIDEO_MARKER : "has"
    CORNER ||--o{ VIDEO_MARKER : "is shown in"

    TRACK {
        int id PK
        int version
    }
    LAYOUT_IMAGE {
        int track_id PK, FK
        text condition PK
    }
    CORNER {
        int track_id PK, FK
        int number PK
    }
    CORNER_CONTENT {
        int track_id PK, FK
        int corner_number PK, FK
        text condition PK
        text language PK
    }
    VIDEO {
        int track_id PK, FK
        text youtube_id PK
    }
    VIDEO_MARKER {
        int id PK
        int track_id FK
        text youtube_id FK
        int corner_number FK
    }
```

Row counts per corner in `CORNER_CONTENT`:

| Track type | Conditions | Languages | Rows per corner |
| --- | --- | --- | --- |
| Outdoor | dry, wet | en, nl | 4 |
| Indoor | dry | en, nl | 2 |

---

## 3. License, theme and local-only state

```mermaid
erDiagram
    TENANT ||--|| THEME : "is branded by"
    TENANT ||--|| SYNC_STATE : "is synced by"
    TRACK ||--o| FAVORITE : "can be"
    TRACK ||--o{ FEEDBACK_QUEUE : "receives"

    TENANT {
        int id PK
    }
    THEME {
        int tenant_id PK, FK
        datetime updated_at
    }
    SYNC_STATE {
        int id PK
        int tenant_id FK
        datetime license_expires_at
        datetime last_server_time
    }
    TRACK {
        int id PK
    }
    FAVORITE {
        int track_id PK, FK
    }
    FEEDBACK_QUEUE {
        int id PK
        int track_id FK
        int attempts
    }
```

---

## 4. Data kept outside the database

Some things the app needs are not stored in the database. They live in secure storage or as encrypted files:

| Item | Where | Survives wipe? |
| --- | --- | --- |
| Installation id | Android: app-scoped `ANDROID_ID`; iOS: Keychain UUID | **Yes**, the only item kept |
| Database encryption key | Android Keystore / iOS Keychain (`whenUnlockedThisDeviceOnly`) | No |
| License token (JWT) | flutter_secure_storage | No |
| Layout images and logo | App sandbox, encrypted with the DB key; path in `LAYOUT_IMAGE.local_path` / `THEME.logo_path` | No |
| UI preferences (theme mode, language, track-day mode) | Shared preferences | No |

---

## 5. Sync and wipe rules per table

| Table | Written by | Deleted when |
| --- | --- | --- |
| TENANT, THEME | `activate`; THEME refreshed via `tenant/theme` | Wipe |
| SYNC_STATE | `activate`, `license/refresh`, every sync | Wipe |
| TRACK and its children | `tracks/{id}` when the version changed | Track marked deleted or missing from `tracks` index; wipe |
| FAVORITE | User | Track removed (cascade); wipe |
| FEEDBACK_QUEUE | Feedback sheet while offline | Successfully sent (`201`); wipe |

All foreign keys to `TRACK` use `ON DELETE CASCADE`, so removing a track removes its images, corners, content, videos, markers, favorite and queued feedback in one go.

---

## 6. Deviations from the spec's data model

The spec's data model describes the server. The local schema differs in a few places:

1. **No `corner_id` or `video_id`.** The track payload identifies corners by `number` and videos by `youtube_id`, so the local tables use composite keys `(track_id, number)` and `(track_id, youtube_id)` instead of server ids.
2. **No `tenant_id` on `TRACK`.** The spec assumes one tenant per device, and a wipe clears everything, so each track belongs to the single `TENANT` row implicitly.
3. **No `deleted` flag on `TRACK`.** Deleted tracks are removed locally instead of being flagged.
4. **Added `FEEDBACK_QUEUE`.** The spec requires an offline queue for feedback but doesn't list it as a local table. Only feedback that hasn't been sent yet is stored here.
5. **Server-only entities are absent:** `LicenseKey`, `KeyBinding` and the server-side `Feedback` table.

---

## 7. Future extensions (not in v1)

These tables come from the spec's "design hooks" for future releases. They are shown here only to confirm the v1 schema leaves room for them.

```mermaid
erDiagram
    CORNER ||--o{ DRIVER_NOTE : "has (future)"
    TRACK ||--o{ ANALYTICS_EVENT : "logs (future)"

    CORNER {
        int track_id PK, FK
        int number PK
    }
    TRACK {
        int id PK
    }
    DRIVER_NOTE {
        int track_id PK, FK
        int corner_number PK, FK
        text condition PK
        text note "local only"
    }
    ANALYTICS_EVENT {
        int id PK
        int track_id FK
        text event_type
        datetime created_at
        bool flushed
    }
```
