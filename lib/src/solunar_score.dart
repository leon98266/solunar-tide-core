import 'dart:math' as math;

import 'astro_utils.dart';

/// A discrete moon-phase bucket, useful for showing a moon icon or localized
/// label without coupling this library to any UI strings.
enum MoonPhase {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
}

/// A contiguous high-score bite window on the hourly curve.
/// Indices point into the hourly score list passed to [SolunarScore.bestWindows].
class BiteWindow {
  final int startIdx;
  final int endIdx;

  const BiteWindow(this.startIdx, this.endIdx);
}

/// Solunar fishing-time scoring — the core "best bite time" logic.
///
/// Based on time of day relative to sunrise/sunset plus moon phase.
/// Self-contained, no network, no UI dependencies.
class SolunarScore {
  /// Classify a raw moon-phase fraction into a discrete [MoonPhase] bucket.
  static MoonPhase moonPhaseOf(double phase) {
    if (phase < 0.06 || phase > 0.94) return MoonPhase.newMoon;
    if (phase < 0.30) return MoonPhase.waxingCrescent;
    if (phase < 0.44) return MoonPhase.firstQuarter;
    if (phase < 0.56) return MoonPhase.waxingGibbous;
    if (phase < 0.65) return MoonPhase.fullMoon;
    if (phase < 0.80) return MoonPhase.waningGibbous;
    return MoonPhase.lastQuarter;
  }

  /// Best bite window score `0..100` based on time of day + moon phase.
  ///
  /// Sunrise + 1h and sunset - 2h are prime windows; full/new moon adds a small
  /// boost. This is the classic solunar-style "prime bite time" signal.
  ///
  /// - [now]: current time.
  /// - [sunriseMin]: sunrise in minutes from midnight (from [AstroUtils.sunTimes]).
  /// - [sunsetMin]: sunset in minutes from midnight.
  /// - [moonPhase]: raw moon-phase fraction (from [AstroUtils.moonPhase]).
  static int timeMoonScore(
    DateTime now,
    int sunriseMin,
    int sunsetMin,
    double moonPhase,
  ) {
    final nowMin = now.hour * 60 + now.minute;
    var best = 0;

    // Prime windows: sunrise + 1h (±60 min) and sunset - 2h (±60 min)
    final morningPrime = sunriseMin + 60;
    final eveningPrime = sunsetMin - 120;
    for (final center in [morningPrime, eveningPrime]) {
      final dist = (nowMin - center).abs();
      final s = dist <= 60 ? 100 - (dist * 100 ~/ 60) : 0;
      if (s > best) best = s;
    }

    // Dawn/dusk general bonus
    if (nowMin >= (sunriseMin - 30) && nowMin <= (sunriseMin + 120) ||
        nowMin >= (sunsetMin - 150) && nowMin <= (sunsetMin + 30)) {
      best = math.max(best, 60);
    }

    // Low-light midday penalty
    if (nowMin >= (sunriseMin + 180) && nowMin <= (sunsetMin - 240)) {
      best = math.max(best, 25);
    }

    // Moon bonus: near new or full moon, plus
    final moonBoost = (moonPhase < 0.15 ||
            moonPhase > 0.85 ||
            (moonPhase - 0.5).abs() < 0.10)
        ? 15
        : 5;

    return (best + moonBoost).clamp(0, 100);
  }

  /// Find the best bite windows: contiguous runs of hourly scores >= [threshold],
  /// merged across a 1-hour gap, sorted by peak score, limited to [maxWindows].
  ///
  /// [hourly] is a list of 0..100 scores per hour (e.g. from
  /// `FisherRating.hourlyScores`). Returns up to [maxWindows] windows sorted by
  /// start index.
  static List<BiteWindow> bestWindows(
    List<int> hourly, {
    int threshold = 70,
    int maxWindows = 2,
  }) {
    if (hourly.isEmpty) return const [];

    final runs = <List<int>>[];
    for (var i = 0; i < hourly.length; i++) {
      if (hourly[i] >= threshold) {
        if (runs.isEmpty || runs.last.last != i - 1) {
          runs.add([i]);
        } else {
          runs.last.add(i);
        }
      }
    }

    final merged = <BiteWindow>[];
    for (final run in runs) {
      if (merged.isNotEmpty && run.first - merged.last.endIdx <= 2) {
        merged[merged.length - 1] = BiteWindow(merged.last.startIdx, run.last);
      } else {
        merged.add(BiteWindow(run.first, run.last));
      }
    }

    final sorted = [...merged]
      ..sort((a, b) {
        final pa = hourly.sublist(a.startIdx, a.endIdx + 1).reduce(math.max);
        final pb = hourly.sublist(b.startIdx, b.endIdx + 1).reduce(math.max);
        return pb.compareTo(pa);
      });
    final top = sorted.take(maxWindows).toList()
      ..sort((a, b) => a.startIdx.compareTo(b.startIdx));
    return top;
  }
}
