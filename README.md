<p align="center">
  <h1 align="center">Solunar Tide Core</h1>
  <p align="center">
    Lightweight <b>offline solunar fishing time calculator</b> & bite-time library for fishing apps.<br>
    Pure Dart · No network · No API key · Zero dependencies · MIT
  </p>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/dart-3.x-blue" alt="Dart 3.x"/>
  <img src="https://img.shields.io/badge/platform-flutter%20%7C%20pure%20dart-blueviolet" alt="Flutter / pure Dart"/>
  <img src="https://img.shields.io/badge/license-MIT-green" alt="MIT"/>
  <img src="https://img.shields.io/badge/deps-0-brightgreen" alt="Zero dependencies"/>
</p>

---

**Solunar Tide Core** is an open source, dependency-free Dart library that computes **prime bite windows (solunar fishing time)**, **sunrise/sunset**, **moon phase**, and a **multi-factor bite-quality rating** — everything a fishing app needs to predict when the fish are biting, **fully offline, no API calls, no keys, no external services**.

It is the extracted, cleaned-up engine behind the **BiteCall** fishing app, published so the fishing-app developer community can reuse it freely under MIT.

> 👉 **Looking for a full-featured fishing app with maps, water bodies and live conditions? Check out [BiteCall](#built-with-bitecall).**

---

## ✨ Features

- ☀️ **Sunrise / sunset calculation** — NOAA simplified solar calculator, works for any latitude/longitude.
- 🌙 **Moon phase** — synodic-month approximation + discrete phase bucket (`newMoon`, `fullMoon`, …).
- 🎯 **Solunar fishing time score (0–100)** — prime bite windows around sunrise +1h and sunset −2h, with new/full-moon boost. This is the classic **solunar score algorithm** anglers rely on.
- 📊 **Best bite windows** — find the contiguous high-score windows across the day.
- 🐟 **Multi-factor bite rating** — water temp, air temp, pressure trend, wind, time & moon, flow, days since rain, and community signal, weighted per species.
- 🗓️ **Hourly bite curve & multi-day forecast scoring** — ideal for hourly and 3-day outlooks.
- 🐠 **9 species presets** — largemouth bass, smallmouth bass, spotted bass, white bass, striped bass, crappie, catfish, muskie, bluegill. Extensible.
- ⚡ **100% offline & local-first** — nothing leaves the device. Privacy by default.
- 🧩 **Zero external dependencies** — pure Dart, works on Flutter **and** command-line apps.

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  solunar_tide_core:
    git:
      url: https://github.com/leon98266/solunar-tide-core.git
      ref: v1.0.0
```

> Works with pure Dart apps and Flutter apps on Android, iOS, Windows, macOS, Linux and web.

---

## 🚀 Quick start

```dart
import 'package:solunar_tide_core/solunar_tide.dart';

void main() {
  // 1. Astronomical calcs for a location (e.g. Lake Eufaula, Alabama, UTC-6)
  final date = DateTime(2026, 10, 31);
  final sun = AstroUtils.sunTimes(date, 32.0, -85.0, -6 * 60);
  final moon = AstroUtils.moonPhase(date);

  if (sun == null) return; // polar day/night
  final (sunrise, sunset) = sun;

  // 2. Solunar bite score at a given moment
  final now = DateTime(2026, 10, 31, 6, 30);
  final score = SolunarScore.timeMoonScore(now, sunrise, sunset, moon);
  print('Solunar bite score: $score/100');

  // 3. Multi-factor rating for largemouth bass
  final result = FisherRating.score(
    obs: const ObservedConditions(
      waterTempC: 21, airTempC: 18,
      pressureHpaNow: 1010, pressureHpa24hAgo: 1013,
      windSpeedMph: 8, daysSinceRain: 3,
    ),
    cfg: SpeciesConfig.largemouthBass,
    now: now,
    sunriseMin: sunrise,
    sunsetMin: sunset,
    moonPhase: moon,
  );
  print('Bite rating: ${result.total}/100 -> ${result.verdict}');
}
```

Run the example:

```bash
dart run example/main.dart
```

---

## 📖 API

### `AstroUtils` — astronomy
| Method | Description |
| --- | --- |
| `sunTimes(date, lat, lng, utcOffsetMinutes)` | Returns `(sunrise, sunset)` in minutes from midnight, or `null` for polar day/night. |
| `moonPhase(date)` | Moon phase as `0.0` (new) … `0.5` (full) … `1.0`. |

### `SolunarScore` — solunar fishing time
| Method | Description |
| --- | --- |
| `moonPhaseOf(phase)` | Classify a phase fraction into a `MoonPhase` bucket. |
| `timeMoonScore(now, sunriseMin, sunsetMin, moonPhase)` | Prime bite-time score `0..100` (**solunar score algorithm**). |
| `bestWindows(hourly, threshold: 70, maxWindows: 2)` | Best contiguous high-score bite windows. |

### `FisherRating` — bite-quality rating
| Method | Description |
| --- | --- |
| `score(obs, cfg, now, sunriseMin, sunsetMin, moonPhase)` | Weighted total `0..100` + `ScoreResult`. |
| `hourlyScores(hourly, cfg, sunriseMin, sunsetMin)` | Hourly bite curve (40% time + 20% temp + 20% wind + 20% cloud). |
| `dailyForecastScores(forecasts)` | Multi-day outlook scores. |
| `buildTips(obs)` | Actionable tips when conditions are poor. |

### `SpeciesConfig` — species presets
`SpeciesConfig.largemouthBass`, `.smallmouthBass`, `.spottedBass`, `.whiteBass`, `.stripedBass`, `.crappie`, `.catfish`, `.muskie`, `.bluegill`, plus `SpeciesConfig.all` and `SpeciesConfig.byId(id)`.

---

## 🗺️ Roadmap

- [x] Sunrise / sunset, moon phase
- [x] Solunar fishing time scoring & best bite windows
- [x] Multi-factor bite rating engine
- [ ] **Tide prediction** (harmonic approximation) for coastal/saltwater apps — planned
- [ ] Timezone auto-detection helper
- [ ] Unit conversion (metric/imperial) convenience methods

Contributions welcome — PRs and issues are encouraged.

---

## 🐟 Built with BiteCall

This library is the **open-source engine** of **BiteCall** — a global fishing forecast app (launching soon on the App Store & Google Play) that layers live weather, USGS gauges and community reports on top of this solunar core.

- 🌍 Live conditions (weather, water temp, flow)
- 🗺️ Water-body maps & lake data
- 🤝 Community bite reports
- 🐟 Multi-species forecasts

> If you build an app on top of this library, we'd love to hear about it!

---

## 📄 License

Released under the [MIT License](LICENSE). Free for personal and commercial use — you may use, modify, and redistribute it, as long as you keep the copyright notice.

---

**Keywords:** solunar fishing time calculator · open source tide prediction library · offline fishing forecast algorithm · flutter tide calendar · solunar score algorithm open source · no api tide calculation dart · offline fishing time predictor · best solunar algorithm for app development · cross platform fishing weather core · flutter fishing app sdk
