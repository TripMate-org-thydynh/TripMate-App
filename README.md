# 📱 TripMate Mobile Application — Gen Z Group Travel Companion

Plan chill. Chia tiền ez. Lưu moment. ✈️

**TripMate** is the ultimate all-in-one collaborative group travel ecosystem optimized for Gen Z explorers. This Flutter mobile application resolves the complex chaos of squad travel — combining real-time group itinerary builders, collaborative location voting, dynamic expense splitters with minimal debt transaction algorithms, live memories feeds, and gamified travel profiles into a beautiful, glassmorphic visual playground.

[![Flutter SDK](https://img.shields.io/badge/Flutter-v3.22+-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-v3.0+-0175C2?style=flat-square&logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=flat-square)](https://flutter.dev)
[![Lint Status](https://img.shields.io/badge/flutter--analyze-No%20Issues-brightgreen?style=flat-square)](https://pub.dev/packages/flutter_lints)

---

## 🎨 Design Systems & Glassmorphic Themes (Rule 2)

Designed natively around elite modern visual ergonomics, the application implements a gorgeous, glassmorphic layout:
*   **Dual Mode Adaptability**: Fully adaptive light and dark themes checking system brightness (`theme.brightness`).
*   **Obsidian Dark Mode**: Deep cinematic navy backdrop (`0xFF0B1326`) overlaid with high-fidelity translucent neon card meshes, smooth gradient blurs, and border glare glows.
*   **Ivory Light Mode**: Clean, high-contrast, minimalist ivory surface accents with soft pastel blurs.
*   **Typography**: Rounded, premium modern typography powered by Google Fonts (Plus Jakarta Sans, Inter, Outfit).
*   **Micro-Animations**: Tactile scaling animations (`active:scale-95`) on interactive cards and action buttons.

---

## 🛠️ Dynamic Backend API Gateway Setup

The mobile application utilizes a **Dynamic Platform Network Resolver** to ensure out-of-the-box connectivity during local testing:
*   **Android Emulator Loopback**: Automatically detects if running on an Android sandboxed VM and translates host requests to `http://10.0.2.2:3000/api/v1`.
*   **Standard Localhost Fallback**: Routes to `http://localhost:3000/api/v1` on iOS simulators or web layouts.
*   **Auth Token Interceptor**: Secures all outgoing connections automatically attaching bearer tokens cached inside `ApiService.authToken`.
*   **Offline Fallback Mode**: If the NestJS database backend is unreachable, the application degrades gracefully to gorgeous local mock assets and visuals, avoiding layout crashes.

---

## ⚙️ Mobile Repository Folder Structure

The code is organized cleanly into modular folders:
```text
lib/
├── core/
│   ├── theme/        # Custom typography, theme presets, light/dark rules
│   └── api_service.dart # Dynamic endpoint resolver & bearer token injector
└── features/
    ├── dashboard/    # Snappy onboarding carousels & landing flow screens
    ├── profile/      # Main Profile setting dashboard & statistics
    │   └── pages/    # Decoupled custom settings screens
    │       ├── edit_profile_screen.dart       # Sync to PATCH /users/me
    │       ├── social_links_manager_screen.dart # Sync to GET/PATCH /users/me/social-links
    │       ├── theme_marketplace_screen.dart  # Spend phượt thủ XP on app themes
    │       ├── sticker_store_screen.dart      # Purchase emojis with XP
    │       ├── sticker_inventory_screen.dart  # View personal sticker collections
    │       └── badge_collection_screen.dart   # Review earned travel trophies
    └── trip_planner/ # Realtime timeline planning
```

---

## 🚀 Setup & Launch Steps

### 1. Developer Prerequisites
*   [Flutter SDK (>= 3.22.0)](https://flutter.dev/docs/get-started/install)
*   [Dart SDK (>= 3.0.0)](https://dart.dev/overview)
*   Android Studio / Xcode with emulator configurations.

### 2. Dependency Loading
Run the following commands inside the `TripMate_app` root directory:
```bash
# Fetch required packages
$ flutter pub get

# Execute Dart static code analyzer
$ flutter analyze
```
*Note: Make sure static analysis passes with zero warnings (`No issues found!`).*

### 3. Application Execution
Verify your target mobile emulator is active, and boot the application:
```bash
$ flutter run
```
*   Use `r` in the terminal to execute hot-reload changes instantly.
*   Use `R` in the terminal to trigger complete system hot-restart, refreshing API database states.
