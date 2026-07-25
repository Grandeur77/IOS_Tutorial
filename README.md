# Game Arcadia 🎮

Welcome to **Game Arcadia**, a premium, feature-rich iOS application built using SwiftUI. Designed with a sleek dark-yellow and blue neon arcade aesthetic, the app contains three distinct gaming experiences, high-fidelity statistics tracking, and interactive location-based gaming metrics.

---

## 🚀 Key Features

### 1. ⚡ Tap Frenzy
A rapid-reaction tapping game designed to test physical dexterity and speed across six gameplay sub-modes:
- **Default**: Standard clicking challenge against the clock.
- **Combo System**: Tap rapidly within 0.5 seconds to build point multipliers.
- **Trap Colour**: Dodge gray trap buttons while tapping green ones for bonus points.
- **Moving Target**: Buttons teleport across the layout grid, requiring visual tracking.
- **Shrinking Button**: Buttons shrink progressively as the timer counts down.
- **Bonus Burst**: Score double points when the golden indicator ring flashes.

### 2. 💡 Light It Up
A grid-based pattern and speed puzzle consisting of four unique challenge types:
- **Classic**: Tap the safe lit indicators before the round window expires.
- **Color Trap**: Identify blue safe targets while avoiding orange trap buttons that trigger immediate game overs.
- **Memory Flash**: A Simon-says memory sequence test. Memorize the flashing pattern and repeat the sequence correctly.
- **Double Trouble**: Simulates double-threat scenarios, lighting up multiple indicators simultaneously that must all be cleared.

### 3. ❓ Quiz Rush
A trivia challenge integrated with the **Open Trivia Database (OpenTDB) API**:
- Select from **Easy, Intermediate, or Hard** difficulties.
- Answer multiple-choice questions within a 10-second countdown timer.
- Build answer streaks to multiply score output.
- Features a unified static grid picker layout for selection.

### 4. 🗺️ Location History Map
An interactive location tracker (similar to Apple Maps) that pins where you played your games:
- Built with **MapKit** and **CoreLocation** support.
- Fully compatible with iOS simulators (uses randomized Cupertino/SF coordinates if GPS returns nil).
- **Segmented Picker Filter**: Sort pins instantly by game mode (All, Light It Up, Quiz Rush, Tap Frenzy).
- **Interactive Location Drawer**: Pull up the bottom history drawer and tap a session row to smoothly pan and zoom onto its map pin.

### 5. 📊 Stats & Settings
- **Leaderboards**: High scores tracked and ranked per game category.
- **Dynamic Charting**: Score trend bar charts plotting your latest game sessions.
- **Normalizer Profile**: Local login and signup configurations storing display credentials case-insensitively.
- **Sound Engine**: Custom synthesized PCM beeps (`success.wav` / `failure.wav`) generated programmatically inside the application sandbox Documents directory.

---

## 🛠️ Architecture & Stack

- **Framework**: SwiftUI (Interface Layouts, Combines, and Bindings)
- **Frameworks**: MapKit & CoreLocation (Map View and GPS Updates)
- **Data Store**: UserDefaults & JSON Coders (Persistent logs)
- **Audio Engine**: AVFoundation & AVAudioPlayer (PCM WAV Synthesizers)
- **Network**: URLSession & JSONDecoder (OpenTDB API Fetching)

---

## 📦 How to Build and Run

1. Open the project root folder in Xcode:
   ```bash
   open "Light It Up.xcodeproj"
   ```
2. Set target to any modern iOS Simulator (e.g. iPhone 15 Pro) or iOS Device running **iOS 17+**.
3. Press `Cmd + R` to compile and launch.
4. Accept location permissions on launch to enable location map tracking.
