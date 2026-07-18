# 🍽️ MakanKira

> **Order together. Kira fairly. Pay easily.**

**MakanKira** is a Malaysia-localized web app that makes organizing a shared team, family, or friend-group meal simple and fair. One person (the *organizer*) creates a meal, collects everyone's orders, sends a clean order sheet to the restaurant, pays the bill, and then lets the app calculate exactly how much each person owes — ready to collect over DuitNow or bank transfer.

The name says it all: **Makan** (to eat / a meal) + **Kira** (to calculate / count). Organize the makan, kira the amount, collect payment fairly.

---

## Table of contents

- [What problem it solves](#what-problem-it-solves)
- [Who it's for](#who-its-for)
- [Features](#features)
- [How it works](#how-it-works)
- [Tech stack](#tech-stack)
- [Project structure](#project-structure)
- [Getting started (run locally)](#getting-started-run-locally)
- [Common commands](#common-commands)
- [Deployment](#deployment)
- [License](#license)

---

## What problem it solves

Organizing a group meal is a mess of manual steps:

1. Share the restaurant menu.
2. Ask each person what they want.
3. Combine everything into one bulk order.
4. Send the final order to the restaurant.
5. Pay the full bill first.
6. Work out how much each person owes (with tax, service charge, discounts…).
7. Chase each person to transfer the correct amount.

MakanKira turns that whole flow into a few guided screens — traceable, fair, and exportable to Excel.

## Who it's for

| Role | What they do |
| --- | --- |
| **Organizer** | Creates the meal, enters/imports the menu, collects orders, confirms the order with the restaurant, pays the bill, enters final prices, and sends payment requests. |
| **Participants** | View the menu, pick their items with remarks (no spicy, less ice, takeaway…), and later see exactly what they owe and how to pay. |
| **Restaurant** | Not a system user — the organizer just sends them a clean, generated order sheet (Excel / WhatsApp / print). |

## Features

**🔐 Accounts & language**
- Login-first landing page with **Google Sign-In** (the only login method).
- Trilingual UI — **English** (default), **简体中文**, and **Bahasa Melayu** — switchable before login and any time after.
- Session dashboard with search and status filters (draft → collecting → finalized → bill entered → payment requested → closed).
- Personal profile (display name, mobile) and reusable **Payment Defaults** that auto-prefill each new meal.

**📋 Menu & meal setup**
- Create a meal session with restaurant, date/time, seat/table, and organizer payment details.
- Provide the menu any way you have it: **add items manually, import from Excel, paste a menu URL, or upload menu images**.
- Download a menu Excel template and export the menu reference.

**🧾 Ordering**
- Participants submit orders with name, mobile number, items, quantities, and per-item remarks.
- **Shareable invite links** so participants can join a meal and submit from their own phones.
- Edit orders until the organizer finalizes; then orders lock.

**👀 Review & restaurant order**
- Two review lenses: **Restaurant view** (grouped by item for the kitchen) and **Participant view** (grouped by person).
- Finalize to lock the order, then **export a multi-tab restaurant order workbook** (meal info, item summary, individual orders, menu reference).

**➗ Bill splitting**
- Enter actual item prices, tax, service charge, discount, company claim/subsidy, and rounding after the meal.
- Three calculation modes:
  - **Item-based** — everyone pays for what they ordered (default).
  - **Equal split** — the bill divided evenly.
  - **Farewell mode** — one or more honorees eat free; their cost is shared across paying participants.
- Flexible allocation for tax / service charge / discount / company claim (proportional, equal, or manual), plus per-participant manual overrides.

**💸 Payment collection**
- Receiving methods: **bank account, DuitNow ID, and uploaded DuitNow QR image**.
- Auto-generated, per-participant, localized payment request messages.
- **Free WhatsApp click-to-chat** (`wa.me`) delivery — the organizer taps Send; copy-one and copy-all also supported.
- Export **payment calculation to Excel** and **payment requests to CSV**.
- Mark participants paid/pending with a payment-status audit trail.

**🔔 Reminders & app-like experience**
- Order-submission reminders by **email** (Gmail SMTP — no domain needed) and **Web Push** (VAPID), scheduled on a free **GitHub Actions** cron.
- Delivered as an installable **PWA** on Android/desktop and a responsive web app on iOS.

> Money is stored and calculated in **integer cents** end-to-end to avoid rounding drift, and all sensitive operations run server-side.

## How it works

```
Sign in → Create meal → Add / import menu → Collect orders → Review & finalize
   → Export order for the restaurant → Pay the bill → Enter final prices
   → Calculate each person's share → Send payment requests → Track who paid
```

## Tech stack

| Layer | Technology |
| --- | --- |
| **Frontend** | Flutter Web (Dart) — Riverpod, go_router, `google_sign_in`, `intl` + ARB localization |
| **API** | TypeScript serverless functions on Node.js ≥ 20 (a single Vercel function under `/api`) |
| **Database** | [Turso](https://turso.tech) (libSQL / SQLite) via `@libsql/client`, SQL migrations |
| **Auth** | Google ID token obtained in the browser, **verified server-side** (`jose` + Google JWKS); signed **HttpOnly session cookie** |
| **File storage** | [Vercel Blob](https://vercel.com/storage/blob) (DuitNow QR & menu images) |
| **Email / Push** | Gmail SMTP via `nodemailer` (order-reminder email, no domain needed) · Web Push (VAPID) |
| **Excel** | `exceljs` for import/export (runs in the API layer) |
| **Hosting / CI** | One Vercel project (UI + `/api` on the same origin); GitHub Actions for deploy and the reminder cron |

The UI and API ship as **one app on one domain**. The browser bundle holds only public values (API base URL, OAuth client ID, locale); every secret lives only in the `/api` runtime, which is the only layer that talks to the database.

## Project structure

```
makankira/
├── lib/                     # Flutter Web UI (Dart) — browser layer, public values only
│   ├── app/  features/  shared/  l10n/  main.dart
├── api/                     # Serverless API (TypeScript) — holds secrets, talks to Turso
│   ├── index.ts             # single entry function; routes /api/* to _lib/*
│   └── _lib/                # domain logic: auth, meals, menu, orders, bill, calc, payments, exports…
├── config/                  # Profile-based config (local | staging | production)
│   ├── app-config.yaml      # master: selects the active profile + shared defaults
│   ├── app-config.local.yaml
│   └── secrets.local.example # template for your git-ignored config/secrets.local
├── scripts/                 # load-config.mjs, migrate.ts, sync-vercel-env.mjs
├── migrations/              # *.sql schema migrations (applied by scripts/migrate.ts)
├── .github/workflows/       # deploy.yml (build+deploy) and reminders.yml (cron)
├── web/                     # Flutter web shell (index.html, manifest, service worker)
├── pubspec.yaml             # Flutter project + dependencies
├── package.json             # API dependencies + tooling scripts
└── vercel.json              # serves build/web and exposes /api on one domain
```

---

## Getting started (run locally)

These steps take you from cloning the repo to a working app in your browser. Everything below uses **free service tiers** — no payment required.

### Prerequisites

Install these first:

| Tool | Version | Used for |
| --- | --- | --- |
| [Git](https://git-scm.com) | any | cloning the repo |
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | stable channel (Dart ≥ 3.12) | building/running the web UI |
| [Node.js](https://nodejs.org) | **≥ 20** | the `/api` layer and tooling |
| [Vercel CLI](https://vercel.com/docs/cli) | latest — `npm i -g vercel` | running UI + API together locally |
| [Turso CLI](https://docs.turso.tech/cli/installation) | latest | creating your dev database |

Enable Flutter web support once:

```bash
flutter config --enable-web
```

You'll also create two free accounts during setup: a **Google Cloud** project (for Google Sign-In) and a **Turso** account (for the database).

### 1. Clone the repository

```bash
# HTTPS
git clone https://github.com/jleong963/makankira.git

# …or SSH
git clone git@github.com:jleong963/makankira.git

cd makankira
```

### 2. Install dependencies

```bash
flutter pub get     # Flutter/Dart packages
npm install         # API layer + tooling
```

### 3. Get your free credentials

You only need these four to sign in and use the core meal flow. The rest unlock specific features (see the table at the end of this section).

**a) Turso database** — create a dev database and grab its URL + token:

```bash
turso db create makankira-dev
turso db show --url makankira-dev        # → TURSO_DATABASE_URL
turso db tokens create makankira-dev     # → TURSO_AUTH_TOKEN
```

**b) Google OAuth client ID** — in the [Google Cloud Console](https://console.cloud.google.com):
1. Create a project (e.g. `MakanKira`).
2. Configure the **OAuth consent screen** (External; scopes `email` and `profile`).
3. **Credentials → Create credentials → OAuth client ID → Web application**.
4. Under **Authorized JavaScript origins**, add `http://localhost:3000`.
5. Copy the **Client ID** → `GOOGLE_OAUTH_CLIENT_ID`. *(No redirect URI is needed — this app verifies the ID token server-side. The client secret is not used.)*

**c) Session secret** — generate a random string (works on any OS with Node):

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('base64url'))"   # → SESSION_SECRET
```

### 4. Configure your local secrets

Copy the template to the git-ignored `config/secrets.local` and fill in the values from step 3:

```bash
cp config/secrets.local.example config/secrets.local
```

> On Windows PowerShell use: `Copy-Item config/secrets.local.example config/secrets.local`

Open `config/secrets.local` and set at least:

```ini
GOOGLE_OAUTH_CLIENT_ID=your-client-id.apps.googleusercontent.com
TURSO_DATABASE_URL=libsql://makankira-dev-...
TURSO_AUTH_TOKEN=your-turso-token
SESSION_SECRET=your-generated-secret
```

**Never commit `config/secrets.local`** — it's already git-ignored.

### 5. Generate the app config

This reads `config/app-config.yaml` + the local profile, resolves your secrets, and writes the two files the build and API need — `config/frontend.local.json` (public, compiled into the UI) and `.env` (backend, consumed by `vercel dev`):

```bash
npm run config
```

### 6. Create the database schema

Apply the SQL migrations to your Turso dev database (idempotent — safe to re-run):

```bash
npm run migrate
```

### 7. Build the UI and run the app

Because sign-in uses an HttpOnly cookie and the API rejects cross-origin writes, the UI and `/api` must be served from the **same origin** in local dev. The simplest way is to build the web app and let `vercel dev` serve both on `http://localhost:3000`:

```bash
npm run build:web     # compiles the Flutter web app into build/web
npm run dev           # vercel dev → serves build/web + /api on http://localhost:3000
```

### 8. Open it

Visit **http://localhost:3000** and click **Continue with Google**. You now have MakanKira running locally. 🎉

After changing Dart/UI code, re-run `npm run build:web` and refresh the browser.

<details>
<summary><strong>Optional: hot-reload while working on the UI</strong></summary>

For fast UI iteration you can run `flutter run -d chrome --dart-define-from-file=config/frontend.local.json` to get hot reload. Note that Flutter serves the UI on its own port, so calls to the `/api` on `:3000` are cross-origin — login and other backend calls won't work in that mode. Use the **build + `vercel dev`** flow above to exercise the full app end-to-end.
</details>

<details>
<summary><strong>Which credentials unlock which features?</strong></summary>

Env vars are read only when a feature needs them, so the app runs with just the four core values. Add the rest to `config/secrets.local` (then re-run `npm run config`) when you want that feature:

| Env var | Required for | How to get it (free) |
| --- | --- | --- |
| `TURSO_DATABASE_URL`, `TURSO_AUTH_TOKEN` | **Core** — all data | Turso CLI (step 3a) |
| `GOOGLE_OAUTH_CLIENT_ID` | **Core** — login | Google Cloud Console (step 3b) |
| `SESSION_SECRET` | **Core** — session cookie | `openssl rand -base64 32` or the Node one-liner |
| `BLOB_READ_WRITE_TOKEN` | DuitNow QR & menu **image uploads** | Vercel → Storage → Blob store |
| `GMAIL_USER`, `GMAIL_APP_PASSWORD` | order-reminder **emails** | a Gmail address + an [App Password](https://myaccount.google.com/apppasswords) (needs 2-Step Verification; no domain) |
| `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY` | **Web Push** reminders | `npx web-push generate-vapid-keys` |
| `CRON_SECRET` | protects the reminder cron endpoint | `openssl rand -base64 32` or the Node one-liner |

</details>

---

## Common commands

| Command | What it does |
| --- | --- |
| `npm run config` | Resolve config + secrets → write `config/frontend.local.json` and `.env` |
| `npm run migrate` | Apply `migrations/*.sql` to the Turso database |
| `npm run build:web` | Build the Flutter web app into `build/web` |
| `npm run dev` | `vercel dev` — serve the UI + `/api` on `http://localhost:3000` |
| `npm run typecheck` | Type-check the `api/` + `scripts/` TypeScript |
| `npm test` | Run the `/api` unit tests |
| `flutter test` | Run the Flutter widget/unit tests |

## Deployment

MakanKira deploys as a single Vercel project via **GitHub Actions**:

- `.github/workflows/deploy.yml` builds the Flutter web app and deploys it with `/api` to Vercel. All secrets come from **GitHub repository secrets** (and are synced to the Vercel project environment).
- `.github/workflows/reminders.yml` runs on a free schedule and calls `POST /api/cron/reminders` (protected by `CRON_SECRET`) to send due order reminders — no paid cron plan needed.

For the full list of secrets and how to obtain each one, see `config/secrets.local.example` and the `config/app-config.*.yaml` profiles.

## License

[MIT](LICENSE) © 2026 James Leong
