
## 🛠️ Flutter Technologies Used

| Technology | Package | Used for |
|---|---|---|
| Flutter / Dart, Material 3 | `flutter` | UI, widgets and layouts |
| State management | `provider` | AuthProvider, PaintingProvider, CartProvider, ThemeProvider |
| Backend (Auth + Postgres) | `supabase_flutter` | Authentication, CRUD, comments, Row Level Security |
| Local storage | `shared_preferences` | Dark mode, favorites, cart |
| REST API | `http` | Art Institute of Chicago API (Discover screen) |

## 🎓 Course Topics Covered

| Topic | Where |
|---|---|
| Widgets & layouts | All screens (Column, Row, ListView, Card, Badge, Dismissible, Form…) |
| Navigation & routing | Named routes in `routes.dart` with arguments (`/details`, `/form`, …) |
| State management | Provider — AuthProvider, PaintingProvider, CartProvider, ThemeProvider |
| API integration | Supabase REST + Art Institute of Chicago API (`art_api_service.dart`, with timeout and status-code check) |
| Local storage | SharedPreferences — dark mode, likes, cart (`local_storage.dart`) |
| Authentication | Supabase Auth (`supabase_service.dart`) + AuthGate (switches Login / Home by session) |
| Supabase | Auth, Postgres tables, Row Level Security |
| CRUD | Paintings (create / read / update / delete, optimistic delete with rollback) and comments |
| Form validation | `Form` + `TextFormField` validators in `validators.dart` |
| Async programming | `async/await`, `Future`, `FutureBuilder`, `StreamBuilder` |
| Error handling | `try/catch/finally`, `friendlyError()` in `error_helper.dart`, SnackBars, Retry button |

## 🧗 Challenges & How I Solved Them

| Challenge | Solution |
|---|---|
| Name clash: `LocalStorage` exists in my code and in `supabase_flutter` | Imported the package with `hide LocalStorage` |
| Images not showing: asset names did not match the database | Unified the names as `.jpg` in `assets/images/` and in the database |
| `anonKey` is deprecated in `Supabase.initialize` | Switched to `publishableKey` |
| Empty database after setup | Added `supabase/schema.sql` (tables, RLS policies, seed data) |
| Data mismatch between a painting record and its image | Updated the record to match its image |

## 🚀 Getting Started

1. Clone the repo and install packages:
```bash
   git clone https://github.com/sgdhelnemr/artify.git
   cd artify
   flutter pub get
```
2. Create a Supabase project at [supabase.com](https://supabase.com).
3. Open **SQL Editor** and run `supabase/schema.sql`.
4. (For easy testing) go to **Authentication → Providers → Email** and turn off "Confirm email".
5. Copy `lib/config/env.example.dart` to `lib/config/env.dart`, then put your **Project URL** and **anon / publishable key** (Project Settings → API) in it, or run:
```bash
   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_ANON_KEY=your_key
```
6. Make sure the painting images are in `assets/images/` (`1.jpg` … `6.jpg`).
7. Run the app: `flutter run`

> Android release builds need `<uses-permission android:name="android.permission.INTERNET"/>` in `android/app/src/main/AndroidManifest.xml`.

## 👥 Team

| Name | Role |
|---|---|
| sgdh elnemr | Developer |

**Course:** Mobile App Development (Flutter) — NTI
**Submitted to:** Yousef Hossam

---
