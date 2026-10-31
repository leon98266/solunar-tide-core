# Solunar Tide Core

**Offline Solunar- und Beißzeiten-Bibliothek für Angel-Apps** — rein in Dart geschrieben, **ohne Internet, ohne API-Key, ohne externe Abhängigkeiten** (MIT-Lizenz).

> Deutsche Version · Vollständige Dokumentation (English): [README.md](README.md) · عربي: [README_AR.md](README_AR.md)

---

## Warum diese Bibliothek?

Viele Angler nutzen den **Solunar-Kalender**, um die besten Beißzeiten vorherzusagen. Diese Bibliothek bringt genau das als **offene, offline laufende Bibliothek** für alle, die eine Angel-App bauen:

- ☀️ **Sonnenaufgang / Sonnenuntergang** — NOAA-vereinfachter Sonnenrechner, für jeden Breiten-/Längengrad
- 🌙 **Mondphase** — synodischer Monat + diskrete Phasenklassen
- 🎯 **Solunar-Beißzeiten-Score (0–100)** — beste Fenster um Sonnenaufgang +1h und Sonnenuntergang −2h
- 📊 **Beste Beißfenster** — zusammenhängende Hochwert-Fenster über den Tag
- 🐟 **Mehrfaktor-Beißbewertung** — Wassertemperatur, Luftdruck, Wind, Mond & Zeit, u. v. m.
- 🗓️ **Stündliche Beißkurve & Tagesprognose**
- 🐠 **9 Fischarten-Presets** — barsch, crappie, wels u. a., erweiterbar
- ⚡ **100 % offline & lokale Verarbeitung** — keine Daten verlassen das Gerät
- 🧩 **Null externe Abhängigkeiten** — funktioniert mit Flutter und in CLI-Apps

---

## Installation

Füge zu deiner `pubspec.yaml` hinzu:

```yaml
dependencies:
  solunar_tide_core:
    git:
      url: https://github.com/leon98266/solunar-tide-core.git
      ref: v1.0.0
```

---

## Schnellstart

```dart
import 'package:solunar_tide_core/solunar_tide.dart';

void main() {
  final sun = AstroUtils.sunTimes(DateTime(2026, 10, 31), 32.0, -85.0, -360);
  final moon = AstroUtils.moonPhase(DateTime(2026, 10, 31));
  if (sun == null) return;

  final score = SolunarScore.timeMoonScore(
    DateTime(2026, 10, 31, 6, 30), sun.$1, sun.$2, moon,
  );
  print('Solunar-Beißzeit: $score/100');
}
```

---

## 🌍 Verfügbarkeit

- **Flutter** (Android, iOS, Windows, macOS, Linux, Web)
- **Reine Dart-CLI-Anwendungen**

---

## Lizenz

[MIT](LICENSE) — frei für private und kommerzielle Nutzung.

---

**Keywords (deutsch):** offline beisszeiten vorhersage · solunar kalender app · gezeiten vorhersage bibliothek dart · fisch app flutter sdk · angeln beste zeit berechnung · mondphasen rechner fischen
