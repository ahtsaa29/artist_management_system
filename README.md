# 🎵 Artist Management System

A Flutter-based admin panel for managing artists and their song collections, built with Clean Architecture, BLoC state management, and Firebase as the backend.

---

## Overview

Artist Management System is a Flutter mobile application that serves as an admin panel to manage records of artists and their song collections. Only authenticated admin users can access the dashboard. The first registered user is automatically promoted to superadmin; all subsequent registrations receive the admin role.

---

## Features

- Authentication — Email/Password login & registration, Google Sign-In
- Auto role assignment — First user → `superadmin`, rest → `admin`
- User Management — List, update, and delete admin users
- Artist Management — Full CRUD (create, read, update, delete)
- Song Management — Full CRUD per artist, with optional album cover (via Firebase Storage)
- Real-time updates — All lists use Firestore streams
- Logout — Confirmation dialog with logout from both Firebase Auth and Google Sign-In
- Dark theme

---

## Tech Stack

| Layer            | Technology                                        |
| ---------------- | ------------------------------------------------- |
| Framework        | Flutter (Dart)                                    |
| State Management | flutter_bloc (BLoC/Cubit)                         |
| Backend / DB     | Firebase Firestore                                |
| Authentication   | Firebase Auth + Google Sign-In                    |
| File Storage     | Firebase Storage                                  |
| DI               | get_it (service locator)                          |
| Architecture     | Clean Architecture (Data / Domain / Presentation) |

---

## Data Schema

### Firestore Collections

#### `users`

| Field        | Type            | Notes                                        |
| ------------ | --------------- | -------------------------------------------- |
| `id`         | String (doc ID) | Firebase Auth UID                            |
| `first_name` | String          |                                              |
| `last_name`  | String          |                                              |
| `email`      | String          |                                              |
| `password`   | —               | Stored in Firebase Auth only (not Firestore) |
| `phone`      | String          |                                              |
| `dob`        | Timestamp?      | Optional                                     |
| `gender`     | String          | `'m'`, `'f'`, `'o'`                          |
| `address`    | String          |                                              |
| `role`       | String          | `'superadmin'` (first user) or `'admin'`     |
| `created_at` | Timestamp       |                                              |
| `updated_at` | Timestamp       |                                              |

#### `artists`

| Field                   | Type            | Notes               |
| ----------------------- | --------------- | ------------------- |
| `id`                    | String (doc ID) | Auto-generated      |
| `name`                  | String          |                     |
| `dob`                   | Timestamp?      | Optional            |
| `gender`                | String          | `'m'`, `'f'`, `'o'` |
| `address`               | String          |                     |
| `first_release_year`    | int?            | Optional            |
| `no_of_albums_released` | int             |                     |
| `created_at`            | Timestamp       |                     |
| `updated_at`            | Timestamp       |                     |

#### `songs`

| Field        | Type            | Notes                                                                                  |
| ------------ | --------------- | -------------------------------------------------------------------------------------- |
| `id`         | String (doc ID) | Auto-generated                                                                         |
| `artist_id`  | String          | Reference to artist doc ID                                                             |
| `title`      | String          |                                                                                        |
| `album_name` | String          |                                                                                        |
| `genre`      | String          | `'rnb'`, `'country'`, `'classic'`, `'rock'`, `'jazz'`, `'pop'`, `'hip-hop'`, `'other'` |
| `mp4_url`    | String?         | Optional — album cover / media via Firebase Storage                                    |
| `created_at` | Timestamp       |                                                                                        |
| `updated_at` | Timestamp       |                                                                                        |

---

## Prerequisites

- Flutter SDK ≥ 3.x (stable channel recommended)
- Dart ≥ 3.x
- Firebase project with Firestore, Authentication, and Storage enabled
- Google Cloud project with OAuth 2.0 configured (for Google Sign-In)
- FlutterFire CLI (for Firebase configuration)

## Running the App

### Install Dependencies

flutter pub get

### Run on Device / Emulator

flutter run

### Build APK (Android)

flutter build apk --release

### Build iOS (macOS required)

flutter build ios --release

## Authentication Flow

```
App Launch
    │
    ▼
AuthBloc → AuthCheckRequested
    │
    ├── Logged in? ──────────────────────► Dashboard Screen
    │
    └── Not logged in? ──────────────────► Login Screen
                                               │
                              ┌────────────────┤
                              │                │
                         Email/Pass        Google Sign-In
                         Login                 │
                              │                │
                         Register ─── Success → Login Screen
                         (new user)            │
                                          Dashboard Screen
```
