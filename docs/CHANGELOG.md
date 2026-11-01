# Changelog

Every change merged into `main` gets an entry here, newest first. Keep entries short: what changed, and why when it is not obvious.

Entry format:

```markdown
## YYYY-MM-DD — Short title (Author name)

- What changed
- Why, if it is not obvious
```

---

## 2026-11-01 — Sync columns and roadmap decisions (Enes Çelik)

- Added `updated_at` and `deleted_at` (INTEGER, milliseconds since epoch) to the `users` and `groups` tables. Every future table except `sync_queue` gets them too: the newer `updated_at` wins when syncing, and rows are soft-deleted with `deleted_at`.
- QR invites moved from the MVP to Phase 2. The MVP uses invite codes only.
- Receipt images stay on the phone that scanned them for now; no Firebase Storage.
- Branch names are in English (`feature/receipt-scan`). The roadmap now lists `refactor:` as a commit type, like the README.
- README: updated the tech stack (setState, Navigator, sqflite, local notifications) and the team table, and added the changelog rule.
- Roadmap: the project skeleton is now listed under Enes Çelik; the Phase 2 Turkish item became "review the Turkish translations".
- Roadmap: noted how the plan now differs from the scope and work plan document sent to the instructor (skeleton owner, simpler tech stack); these are reported in the first weekly report.

## 2026-11-01 — Project skeleton (Enes Çelik)

- Created the Flutter project: name `cotab`, package id `io.github.enescelik00.cotab`, Android and iOS only. The app is shown as "CoTab" on both platforms.
- Moved `README.md` from `docs/` to the project root. `docs/Road_Map.md` stays in `docs/`.
- Added packages: `sqflite`, `path`, `flutter_localizations`, `intl`. Removed `cupertino_icons` (we only use Material icons).
- Created the folder structure: `lib/models`, `lib/screens`, `lib/services`, `lib/widgets`, `lib/utils`.
- Added `lib/services/database_helper.dart`: opens `cotab.db` and creates the `users` and `groups` tables with plain SQL. IDs are `TEXT` because they will come from Firebase.
- Added `lib/main.dart` (Material 3 theme) and an empty home screen in `lib/screens/home_screen.dart`.
- Set up localization: English is the default, Turkish is the second language (`l10n.yaml`, `lib/l10n/app_en.arb`, `lib/l10n/app_tr.arb`). The generated `app_localizations*.dart` files are committed.
- Replaced the default counter test with a test that checks the home screen opens.
- `.gitignore`: removed the `*.lock` rule so `pubspec.lock` is committed and everyone uses the same package versions. Added IDE folders and Firebase config files (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`).
- Added `CLAUDE.md` with the project rules and this changelog.
