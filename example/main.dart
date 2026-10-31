import 'package:solunar_tide_core/solunar_tide.dart';

void main() {
  // 1. Astronomical calcs for a location, e.g. Lake Eufaula, Alabama (UTC-6).
  final date = DateTime(2026, 10, 31);
  final lat = 32.0;
  final lng = -85.0;
  final utcOffsetMinutes = -6 * 60;

  final sun = AstroUtils.sunTimes(date, lat, lng, utcOffsetMinutes);
  final moon = AstroUtils.moonPhase(date);
  final moonLabel = SolunarScore.moonPhaseOf(moon).name;

  print('Sunrise/sunset: $sun (minutes from midnight)');
  print('Moon phase: ${moon.toStringAsFixed(2)} -> $moonLabel');

  if (sun == null) {
    print('Polar day/night — no sunrise/sunset.');
    return;
  }

  final (sunrise, sunset) = sun;

  // 2. Prime bite-time ("solunar") score at a given moment.
  final now = DateTime(2026, 10, 31, 6, 30);
  final solunar = SolunarScore.timeMoonScore(now, sunrise, sunset, moon);
  print('Solunar bite score at 06:30: $solunar/100');

  // 3. Weighted multi-factor rating for largemouth bass.
  final cfg = SpeciesConfig.largemouthBass;
  final result = FisherRating.score(
    obs: const ObservedConditions(
      waterTempC: 21,
      airTempC: 18,
      pressureHpaNow: 1010,
      pressureHpa24hAgo: 1013,
      windSpeedMph: 8,
      daysSinceRain: 3,
    ),
    cfg: cfg,
    now: now,
    sunriseMin: sunrise,
    sunsetMin: sunset,
    moonPhase: moon,
  );

  print('Bite rating: ${result.total}/100 -> ${result.verdict}');
  for (final f in result.factors) {
    print('  ${f.label}: ${f.score0to100}/100 (weight ${f.weightPct}%)');
  }
  print('Best window: ${result.bestWindowText}');
}
