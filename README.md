# HR Management — Flutter App (v2.0)

**Better People. Stronger Teams.**

A complete, production-style HR Management app built with Flutter from the
provided UI design — now with **zero demo data**, **binary local storage**,
a **responsive desktop UI**, and **GitHub Actions builds for Android,
Windows, Linux, macOS and iOS**.

## What's new in v2.0

- **No demo data, ever.** A fresh install starts completely empty. The
  first launch asks for your company name, your name/role, currency and
  overtime rate (one-time setup) — every number in the app is then computed
  from *your* real data.
- **Binary local storage.** All data auto-saves on the device as ONE binary
  blob (custom `HRMB` format: magic header + version + length + payload +
  checksum) inside a Hive binary box — see `lib/data/binary_store.dart`.
  Works on Android, iOS, Windows, macOS, Linux and Web. No server, no
  account, fully offline.
- **Binary backup & restore.** Settings → Export Binary Backup gives you
  the same binary blob (Base64 for easy copying); paste it into Restore on
  any device to move your data. Corrupted backups are rejected by checksum.
- **Responsive desktop UI.** Below 900dp you get the phone layout with the
  design's bottom navigation. At 900dp and above the app switches to a
  desktop layout: permanent navy sidebar (profile + full menu), wide
  dashboards, and multi-column employee grids.
- **More features:** edit employees (not just add), joining date, employee
  sorting (newest / name / salary), per-employee attendance marking
  (Present / Late / Absent), "request on behalf of an employee" for leave
  and overtime, configurable leave allowances, payslips you can mark
  Paid/Unpaid, and a danger-zone **Erase All Data**.

## Features by screen

| Screen | What works |
|---|---|
| Setup | One-time company/profile/currency/overtime-rate setup |
| Home | Real counters (employees, present/late today, on leave, overtime people), getting-started checklist when empty, quick actions |
| Employees | Search, Total/Active/On-Leave filters, sorting, add/edit/details/status/delete, responsive grid |
| Attendance | Live Clock In/Out with progress ring + worked-time log, per-employee marking for today, real Present/Late/Absent counters |
| Leave | My/Team tabs, real remaining balances (allowance − approved), create for me or an employee, approve/reject team requests |
| Payroll | Pick person + month; basic salary + approved-overtime pay + your allowances/deductions; Generate Payslip saves a snapshot; mark Paid/Unpaid; delete |
| Overtime | My/Team tabs, live hour stats, add with date + hours slider (rate from Settings), approve/reject |
| Reports | Attendance rate today, employees by department, pending leaves, saved-payroll totals |
| Settings | Profile & company, my salary, currency, overtime rate, leave allowances, backup export/import, erase all data |

## Run it locally

```bash
flutter pub get
flutter run
```

The repository intentionally ships text platform files; if any platform
scaffold file is missing in your checkout (binary files such as icons or
the Gradle wrapper are not stored in git), regenerate it once with:

```bash
flutter create --project-name hr_management --platforms=android,ios,windows,linux,macos .
```

## Build release apps (GitHub Actions)

The workflow in `.github/workflows/build.yml` builds on every push to
`main` and on demand (Actions tab → *Build Apps* → Run workflow):

| Job | Output artifact |
|---|---|
| Android | `android-apk` → `app-release.apk` |
| Windows | `windows-exe` → zip of the Release folder (contains the `.exe`) |
| Linux | `linux-app` → `hr-management-linux.tar.gz` |
| macOS | `macos-app` → `hr-management-macos.zip` |
| iOS | `ios-app-unsigned` → `Runner.app` zip, built `--no-codesign` |

> The iOS build is **unsigned** (no Apple Developer certificate in CI).
> To install on a real iPhone, open the project in Xcode on a Mac, set
> your own Signing Team, and build — or add signing secrets to the
> workflow.

## Tests

```bash
flutter analyze   # clean
flutter test      # 11 tests: setup flow, empty state, binary codec
                  # round-trip + corruption check, persistence restore,
                  # add/search employee, clock in/out + marking,
                  # payroll/overtime empty states, desktop sidebar layout
```

## Data format (`.hrmb` binary)

```
bytes 0-3   magic "HRMB"
byte  4     format version (1)
bytes 5-8   payload length (big-endian)
bytes 9..   payload (UTF-8 JSON of the whole app state)
last 4      checksum (sum of payload bytes mod 2^32, big-endian)
```

## Project structure

```
lib/
  main.dart                 Startup: opens binary storage, restores state
  theme/app_theme.dart      Colours/theme from the design
  models/models.dart        Employee, Leave, Overtime, Payroll, Attendance
  data/app_state.dart       State + all actions + toMap/fromMap
  data/binary_store.dart    HRMB binary codec + Hive local storage
  widgets/common.dart       Avatar, chips, stat boxes, money formatter
  screens/                  splash, setup, main_shell (responsive),
                            home, employees, add_employee, attendance,
                            leave, payroll, overtime, more (+ reports,
                            settings)
test/                       widget_test.dart, navigation_test.dart
.github/workflows/          build.yml (APK / EXE / Linux / macOS / iOS)
```
