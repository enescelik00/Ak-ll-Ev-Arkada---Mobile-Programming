# CoTab

**Shared expenses, shopping and chores for people who live together.**

CoTab is a mobile app for student houses and travel groups. It brings shared spending, a common shopping list and a rotating chore schedule into one place, so nobody has to dig through group chats or spreadsheets to find out who owes what or whose turn it is.

> 🚧 This project is under active development as part of the *Mobile Programming* course (2026–2027 Fall) at Istanbul University-Cerrahpaşa.

---

## Features

### Core
- [ ] Sign up and sign in
- [ ] Create a group and invite members with a code
- [ ] Add expenses and split them equally, by percentage or by exact amounts
- [ ] Per-member balances and expense history
- [ ] Offline-first: everything is saved locally and synced when you're back online

### Extended
- [ ] **Receipt scanning (OCR):** read the date, total and VAT from Turkish market receipts, then review and correct before saving
- [ ] **Item-level splitting:** assign each item on a receipt to one or more people
- [ ] **QR invites:** join a group by scanning a QR code
- [ ] **Debt simplification:** settle up with the minimum number of payments
- [ ] **Chore schedule:** rotating duties with reminder notifications
- [ ] **Shared shopping list:** a bought item turns into an expense with one tap

### Nice to have
- [ ] Spending charts by category
- [ ] Multiple currencies for travel groups
- [ ] Recurring expenses (rent, internet, etc.)
- [ ] Dark theme

The app is built in English with Turkish language support.

---

## Tech Stack

| Layer | Technology |
| --- | --- |
| App | Flutter, Dart, Material 3 |
| State management | StatefulWidget + setState |
| Navigation | Navigator |
| Local storage | SQLite via sqflite (plain SQL) |
| Backend | Firebase Authentication, Cloud Firestore |
| Receipt scanning | Google ML Kit Text Recognition (on-device) |
| Notifications | Local notifications (flutter_local_notifications) |
| Languages | English (default) and Turkish, via Flutter's built-in localization |

The code is kept deliberately simple so that every team member can read and explain every file. The project rules are in [CLAUDE.md](CLAUDE.md).

## How It Works

CoTab is **offline-first**. Every change is written to the local SQLite database first, so the app works without a connection. Pending changes are kept in a sync queue and pushed to Firestore when the device is online, where they reach the other members of the group.

Amounts are stored as integers in kuruş (cents) to avoid floating-point errors. When an amount doesn't divide evenly, the leftover kuruş goes to the person who paid, so the shares always add up to the exact total (e.g. 100.00 TL split three ways → 33.34 + 33.33 + 33.33).

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- Android Studio or VS Code with the Flutter extension
- A Firebase project

### Setup

```bash
git clone https://github.com/enescelik00/CoTab.git
cd CoTab
flutter pub get
```

Connect the app to your own Firebase project using the [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup):

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Firebase configuration files (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`) are not committed to the repository.

### Run

```bash
flutter run
```

---

## Contributing

We use a simple branch-and-pull-request workflow:

- `main` is protected; all changes go through a pull request reviewed by at least one other team member.
- Branch names: `feature/receipt-scan`, `fix/balance-rounding`, `docs/readme`
- Commit messages start with a type: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`
- Every pull request adds a short entry to [docs/CHANGELOG.md](docs/CHANGELOG.md).
- Run `flutter analyze` and `flutter test` before opening a pull request.
- Tasks are tracked in GitHub Issues.

Project documents, including the [roadmap](docs/Road_Map.md), are in the [docs/](docs/) folder.

---

## Team

| Member | Role | Focus |
| --- | --- | --- |
| Enes Çelik | Project Manager | Project setup, groups, expenses, splitting and debt simplification |
| Enes Yahya Bodur | Tech Lead | Camera, OCR and receipt review; code review and testing |
| Ahmet Anıl Çay | Public Relations | Firebase, authentication, sync, notifications, chores and shopping list |
