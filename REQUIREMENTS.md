**App Name:** Color Connect

**Summary:**
Color Connect is designed to be a state-of-the-art, top-tier mobile puzzle game in its category. The goal is to deliver the most polished, scalable, and viral connect-style experience available on mobile platforms.

Color Connect is a minimalist, flow-style puzzle game where players connect matching colored endpoints on a grid without overlapping paths. It scales in difficulty across 100+ handcrafted levels. The game is designed to be intuitive, visually clean, and mentally stimulating, targeted at users aged 18 to 40. Built as a hybrid mobile app using Flutter + Flame, it supports Android and iOS with monetization via ads and in-app purchases. The game includes analytics, localization, offline support, and polish-level UX, engineered to be viral and production-grade. This document is fully structured for AI tools like Cursor to generate complete implementation.

---

**Game Objective:**
Connect all pairs of matching colored endpoints on a grid so that:

* All grid cells are filled by paths.
* Paths do not overlap or cross.

---

**Core Mechanics:**

* Tap and drag from one endpoint to another to create a colored path.
* Paths can only move vertically or horizontally.
* Paths must not intersect each other.
* A level is complete only when all paths are correctly connected and the grid is fully filled.

---

**Game Architecture Overview:**

* **Framework**: Flutter 3.x
* **Game Engine**: Flame for touch gestures and canvas rendering.
* **Target Platforms**: iOS and Android
* **Storage**: Local storage with optional cloud sync
* **State Management**: Riverpod (preferred) or Provider
* **Monetization**: Google AdMob (interstitial + rewarded ads), IAP to remove ads or buy hints
* **Analytics**: Firebase or Amplitude for tracking player behavior, A/B testing
* **Localization**: Multi-language UI support (EN, HI, ES, FR, more via .arb files)
* **Offline Mode**: All levels available offline, with cloud sync when online
* **Error Handling**: Fallbacks for corrupted saves, network failures, and game crashes

---

**Folder Structure:**

```plaintext
lib/
  main.dart
  game/
    color_connect_game.dart
  level/
    levels.dart
  ui/
    home_page.dart
    level_select_page.dart
    game_page.dart
    onboarding_tutorial.dart
  widgets/
    path_painter.dart
  models/
    game_state.dart
  services/
    storage_service.dart
    analytics_service.dart
    localization_service.dart
```

---

**Level System:**

* Each level is a 5x5 to 9x9 grid.
* Stored as 2D lists with color labels at endpoint coordinates.
* Minimum 100 handcrafted levels, increasing in complexity.
* Extendable to support procedural generation.
* Store levels in `levels.dart` using JSON-like structures.

```dart
List<List<List<String?>>> levels = [
  [
    [null, 'red', null],
    [null, null, null],
    ['red', null, null],
  ],
  ...
];
```

---

**Game Logic Requirements:**

1. **Grid Renderer**: Render grid size and endpoints based on level.
2. **Path Drawing**: Track drag-to-connect gestures, snap to cell grid.
3. **Collision Detection**: Prevent overlapping paths; support undo.
4. **Validation Logic**:

   * All pairs are correctly connected
   * Grid is fully filled with valid paths
   * No overlaps or dead ends
5. **Level Progression**:

   * Unlock next level after success
   * Save state locally and sync if online
6. **Tutorial System**:

   * First-time onboarding with guided interaction
   * Skippable with resume capability

---

**Monetization Design:**

* **Interstitial Ads**: After every 5 levels
* **Rewarded Ads**: Optional hint per ad
* **In-App Purchases**:

  * Remove all ads (one-time)
  * Buy hints in packs (5, 10, 20)
  * Unlock custom themes or multiplayer

---

**UI/UX Guidelines:**

* Modern minimalist layout, grid-focused
* Smooth animations, adaptive color transitions
* Rounded controls with haptic feedback
* Animated path drawing and visual feedback for success/failure
* Support for light/dark mode
* Page transitions and micro-interactions for polish

---

**Scalability Suggestions:**

* Daily challenges with real-time leaderboard
* Procedural level generation
* Cross-device sync via user account
* Advanced level analytics to adjust difficulty

---

**Extended Differentiators:**

* **Multiplayer Duels**: Real-time PvP time-attack competitions
* **Puzzle Creator Mode**: Players can design/share their own puzzles
* **Colorblind-Friendly Mode**: Overlay patterns/symbols for accessibility
* **Daily Puzzle Leaderboard**: Competitive challenge reset every 24h
* **Custom Themes**: Unlockable skins, animations, and sound packs
* **Social Sharing**: Share level completion or custom challenges via link
* **Localization**: Multi-language UI and RTL support
* **Offline Play**: All levels accessible without internet
* **A/B Testing**: Remote config flags for level tuning, monetization experiments

---

**Development Notes for AI Coders (Cursor):**

* Start with `main.dart` for navigation and theme
* Use `ColorConnectGame` as `FlameGame` subclass with input and canvas logic
* Build UI with `GamePage`, `HomePage`, `LevelSelectPage`, and `TutorialPage`
* Place level data in `levels.dart`, with room for programmatic generation
* Use `analytics_service.dart` for Firebase logging of key events
* Implement localization using Flutter's .arb system
* Add `GestureDetector` if not using `PanDetector` from Flame
* Modularize all services to support future expansion (multiplayer, cloud save, etc.)

---

**Development & Testing Tools:**

> Recommended tooling to build and test this project in a production-ready environment:

| Purpose              | Toolchain / Service                                      |
| -------------------- | -------------------------------------------------------- |
| **Framework**        | Flutter 3.x SDK                                          |
| **Game Engine**      | Flame (via pub.dev)                                      |
| **IDE**              | Cursor IDE, VSCode, or Android Studio                    |
| **Mobile Testing**   | Android Emulator, iOS Simulator                          |
| **UI Testing**       | Flutter Driver / Integration Test                        |
| **Analytics**        | Firebase, Amplitude                                      |
| **Crash Monitoring** | Firebase Crashlytics                                     |
| **Monetization**     | Google AdMob, RevenueCat (IAP)                           |
| **Localization**     | Flutter Intl or `flutter_localizations`                  |
| **State Management** | Riverpod or Provider                                     |
| **Build/Deploy**     | Flutter build commands, Play Store / App Store workflows |

**How to Begin (AI/Cursor-Ready Flow):**

1. Install Flutter SDK 3.x with required Android/iOS toolchains
2. Clone or create project with folder structure as defined
3. Generate UI screens and Flame game canvas from provided structure
4. Implement logic using this spec and test via `flutter run`
5. Run `flutter test` and UI integration tests
6. Add Firebase SDK and connect to project for analytics + crashlytics
7. Configure Google AdMob and IAP products for monetization testing
8. Prepare Play Store/App Store deployment assets (icons, screenshots, metadata)

---

This document now provides a complete, end-to-end blueprint for building a scalable, viral, production-grade mobile puzzle game using Cursor IDE or any AI-assisted development platform.
