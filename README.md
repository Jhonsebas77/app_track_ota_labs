# App Track — OTA Labs

A Flutter application to track and manage your own developed apps across platforms. It provides a centralized dashboard to monitor application status, versions, and metadata, with a custom dark **Blueprint** design system.

**Live demo:** https://jhonsebas77.github.io/app_track_ota_labs/

---

## Features

- **Authentication** — Secure login/logout via Supabase Auth
- **Dashboard** — Overview of total registered applications with live stats
- **Applications list** — Full list view with detailed cards per app
- **Register new app** — Form to add applications with name, bundle ID, description, icon upload, and target platform selector (iOS / Android / Web)
- **Settings** — System config, session management, build info, and version display
- **Adaptive layout** — Pill bottom nav on phones, compact rail on tablets, full sidebar on desktop/web (`lib/ui/theme/breakpoints.dart`)
- **Theme** — "Engineering Blueprint" design system shared with *auto_log_mi_nave_ota_labs*
- **Animated UI** — Entrance animations on every screen using `flutter_animate`
- **Custom navigation** — Slide-bottom and fade page transitions
- **Native splash screen** — Branded splash on launch for iOS and Android
- **Portrait lock** — Enforced portrait orientation on mobile

---

## Tech Stack

| Layer | Library |
|---|---|
| Framework | Flutter |
| Backend / Auth | [Supabase](https://supabase.com) |
| State — app data | [Provider](https://pub.dev/packages/provider) |
| State — theme / navigation | [Riverpod](https://riverpod.dev) |
| Animations | [flutter_animate](https://pub.dev/packages/flutter_animate) |
| Font | JetBrains Mono, bundled in `assets/fonts/` |
| Splash screen | [flutter_native_splash](https://pub.dev/packages/flutter_native_splash) |
| App info | [package_info_plus](https://pub.dev/packages/package_info_plus) |

---

## Project Structure

```
lib/
├── main.dart                   # Entry point: DartDefine check, Supabase init, theme wiring
├── core/
│   ├── constants/
│   │   └── constants.dart      # SUPABASE_URL / SUPABASE_PUBLISHABLE_KEY / AUTH_EMAIL (String.fromEnvironment)
│   ├── models/
│   │   └── app_model.dart      # AppModel data class with fromMap factory
│   ├── providers/
│   │   ├── app_provider.dart   # ChangeNotifier: auth (login/logout, session state)
│   │   ├── database.dart       # appsProvider + Supabase queries (fetchAllApps, insertApp)
│   │   ├── app_icon_picker_service.dart # Camera/gallery picker + upload to Storage bucket app-icons
│   │   ├── navigation.dart     # Riverpod Notifier for the selected shell tab
│   │   └── theme.dart          # Riverpod Notifier for ThemeMode
│   └── enums/
│       └── enums.dart          # Shared enums
└── ui/
    ├── theme/                  # "Engineering Blueprint" theme (library + parts)
    │   ├── app_theme.dart      # appTheme / appDarkTheme (ThemeData)
    │   ├── app_text_styles.dart # AppTextStyles (JetBrains Mono)
    │   ├── blueprint_colors.dart # BlueprintColors palette
    │   ├── blueprint_shapes.dart # kSharpShape, kIndustrialBorder, kSharpInputBorder
    │   ├── breakpoints.dart    # WindowSize + Breakpoints for the adaptive layout
    │   └── grid_overlay_painter.dart # Background grid
    ├── views/
    │   ├── login_screen.dart   # Password-only login for AUTH_EMAIL
    │   ├── home.dart           # AppShell: top bar + bottom nav / side nav + tabs
    │   ├── dashboard_view.dart # "Inicio" tab: stats + app list from Supabase
    │   ├── my_applications_screen.dart # "Apps" tab: detailed app list
    │   ├── add_application_screen.dart # App form: register a new app or edit an existing one
    │   ├── app_detail_screen.dart # App detail (opened from any app card): edit / delete
    │   └── settings_view.dart  # Version, build info, logout
    └── widgets/
        ├── blueprint_*.dart    # Scaffold, top/form app bars, bottom/side nav, button, text field, form body
        ├── app_status_badge.dart # Status badge + app icon box
        ├── custom_badge.dart   # Generic outlined badge
        ├── section_header.dart # Accent bar + label (+ optional action)
        ├── dashboard_card.dart / detailed_card.dart / stats_card.dart
        ├── snackbar.dart       # showSuccessSnackBar / showErrorSnackBar / showInformationSnackBar
        ├── version.dart        # VersionWidget using package_info_plus
        └── auth/               # Login decorations: corner brackets, diagnostic strip, grid, scanline, schematic ring
```

---

## Design System — Engineering Blueprint

Same design system as *auto_log_mi_nave_ota_labs* (`lib/ui/theme/`).

- **Font:** JetBrains Mono, bundled in `assets/fonts/` (no runtime download)
- **Colors:** `BlueprintColors` — `background` `#0B1623`, `accentOrange` `#FF9F30`, `successGreen` `#00FF9D`, `danger`, `infoBlue`, `surfaceContainerLow`, `outline`/`outlineVariant`, `textPrimary`/`textMuted`
- **Shapes:** sharp 0px corners everywhere (`kSharpShape`), 1px industrial borders
- **Components:** `BlueprintScaffold` (grid overlay), `BlueprintTopAppBar`, `BlueprintFormAppBar`, `BlueprintBottomNavBar`, `BlueprintSideNav`, `BlueprintPrimaryButton`, `BlueprintTextField`, `CustomBadge`
- **Motifs:** grid backgrounds, scanline overlay, corner brackets, schematic ring (login)

---

## Data Model

```dart
AppModel {
  String id
  String name
  String description
  String bundleId
  String? icon         // Storage URL (bucket app-icons) or asset name in assets/apps/
  Color color
  List<String> platform  // ['iOS', 'Android', 'Web']
  String status        // 'Live' | 'In Review' | 'Draft'
  String developPlatform
  String version
  String? deployUrl    // deploy_url, optional
  DateTime? createdAt  // created_at
}
```

Apps are read from and saved to Supabase (`app_track.all_apps`) through `fetchAllApps` / `insertApp`. Both tabs watch the Riverpod `appsProvider`, which is invalidated after a new app is saved.

---

## Getting Started

### Prerequisites

- Flutter 3.41 / Dart `^3.10`
- A Supabase project

### Configuration

Credentials are passed at build time with `--dart-define`. They are never
committed.

```bash
cp config/dart_defines.example.json config/dart_defines.local.json
# then edit config/dart_defines.local.json
```

| Key | Description |
| --- | --- |
| `SUPABASE_URL` | Project URL (`https://<ref>.supabase.co`) |
| `SUPABASE_PUBLISHABLE_KEY` | Publishable (anon) key |
| `AUTH_EMAIL` | Email used to sign in (see note below) |

`config/dart_defines.local.json` is gitignored. The app throws a
`StateError` at startup if any key is missing.

> **Note:** login always signs in with `AUTH_EMAIL`; the login screen only
> asks for that user's password.

### Database (Supabase)

The `app_track.all_apps` table already exists in the project. The changes the
app needs on top of it are versioned in `supabase/sql/`. Run them **in order**
in Supabase Dashboard → SQL Editor (each file is idempotent, so re-running is
safe):

| Script | What it does |
| --- | --- |
| `0001_all_apps_deploy_url.sql` | Adds the optional `deploy_url` column |
| `0002_all_apps_insert_policy.sql` | Grants + RLS so the signed-in user can insert/read their own apps |
| `0003_storage_app_icons.sql` | Public `app-icons` Storage bucket (1 MB, images only) + per-user folder policies |
| `0004_all_apps_delete_policy.sql` | Grant + RLS so the signed-in user can delete their own apps |
| `0005_all_apps_update_policy.sql` | Grant + RLS so the signed-in user can edit their own apps |

New changes go in a new numbered file; never edit a script that has already
been run against the database.

> `supabase/sql/` is listed in `.gitignore`, so these files exist only
> locally. Get them from a maintainer if your clone doesn't have them.

### Running

```bash
flutter pub get

# Android / iOS (device or emulator)
flutter run --dart-define-from-file=config/dart_defines.local.json

# Web
flutter run -d chrome --dart-define-from-file=config/dart_defines.local.json
```

`.vscode/launch.json` already passes the file (mobile and web configs).

### Building

```bash
flutter build apk --dart-define-from-file=config/dart_defines.local.json
flutter build ipa --dart-define-from-file=config/dart_defines.local.json
flutter build web --dart-define-from-file=config/dart_defines.local.json
```

### Regenerate splash screen

```bash
dart run flutter_native_splash:create
```

---

## Platforms

| Platform | Status |
|---|---|
| Android | Supported |
| iOS | Supported |
| Web | Supported + deployed |
| macOS | Available |
| Linux | Available |
| Windows | Available |

---

## Deploy

### Automatic (GitHub Actions)

Every push to `main` triggers a GitHub Actions workflow that:

1. Sets up Flutter on Ubuntu
2. Builds the web app with `--base-href="/app_track_ota_labs/"`, passing
   `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` and `AUTH_EMAIL` from the
   repository **secrets** (Settings → Secrets and variables → Actions) as
   `--dart-define`
3. Deploys `build/web` to the `gh-pages` branch via `peaceiris/actions-gh-pages`

You can also trigger it manually from the **Actions** tab → **Run workflow**.

### Manual fallback

```bash
flutter build web --base-href="/app_track_ota_labs/" \
  --dart-define-from-file=config/dart_defines.local.json
npx gh-pages -d build/web
```

**URL:** https://jhonsebas77.github.io/app_track_ota_labs/

---

## Code Quality

The project uses a strict `analysis_options.yaml` with:

- `flutter_lints` rule set
- Strict type inference, casts, and raw-type checks
- 80-character line limit
- `dart_code_metrics` for anti-patterns (long parameter lists, redundant async, etc.)
- Custom severity overrides (e.g. `use_build_context_synchronously` → info)

Run the analyzer:

```bash
flutter analyze
```
