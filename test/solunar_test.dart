import 'package:solunar_tide_core/solunar_tide.dart';
import 'package:test/test.dart';

void main() {
  group('AstroUtils', () {
    test('sunTimes returns sane sunrise/sunset for a known location', () {
      // Lake Eufaula, Alabama, Oct 31, UTC-6
      final sun = AstroUtils.sunTimes(
        DateTime(2026, 10, 31),
        32.0,
        -85.0,
        -6 * 60,
      );
      expect(sun, isNotNull);
      final (sunrise, sunset) = sun!;
      expect(sunrise, greaterThan(0));
      expect(sunrise, lessThan(720)); // before noon
      expect(sunset, greaterThan(720));
      expect(sunset, lessThan(1440));
      expect(sunset, greaterThan(sunrise));
    });

    test('moonPhase is always within [0,1)', () {
      for (final d in [DateTime(2000, 1, 6), DateTime(2026, 1, 1), DateTime(2030, 6, 15)]) {
        final p = AstroUtils.moonPhase(d);
        expect(p, greaterThanOrEqualTo(0));
        expect(p, lessThan(1));
      }
    });

    test('sunTimes matches real Beijing data within NOAA tolerance', () {
      // Real values (2026): Oct 31 sunrise 06:42 / sunset 17:14;
      // Nov 17 sunrise 07:01 / sunset 16:59. NOAA simplified calc has ~±5 min error.
      final oct = AstroUtils.sunTimes(DateTime(2026, 10, 31), 39.9, 116.4, 480)!;
      expect((oct.$1 - (6 * 60 + 42)).abs(), lessThanOrEqualTo(6));
      expect((oct.$2 - (17 * 60 + 14)).abs(), lessThanOrEqualTo(6));

      final nov = AstroUtils.sunTimes(DateTime(2026, 11, 17), 39.9, 116.4, 480)!;
      expect((nov.$1 - (7 * 60 + 1)).abs(), lessThanOrEqualTo(6));
      expect((nov.$2 - (16 * 60 + 59)).abs(), lessThanOrEqualTo(6));
    });
  });

  group('SolunarScore', () {
    test('prime time scores high, dead night scores low', () {
      final moon = 0.5; // full moon
      const sunrise = 360; // 6:00
      const sunset = 1080; // 18:00
      final prime = SolunarScore.timeMoonScore(
        DateTime(2026, 10, 31, 7, 0), // sunrise + 1h
        sunrise,
        sunset,
        moon,
      );
      final night = SolunarScore.timeMoonScore(
        DateTime(2026, 10, 31, 2, 0), // middle of night
        sunrise,
        sunset,
        moon,
      );
      expect(prime, greaterThan(50));
      expect(night, lessThan(40));
    });
  });

  group('FisherRating', () {
    test('ideal conditions yield a good verdict', () {
      final sun = AstroUtils.sunTimes(DateTime(2026, 10, 31), 32.0, -85.0, -360)!;
      final result = FisherRating.score(
        obs: const ObservedConditions(
          waterTempC: 21,
          airTempC: 18,
          pressureHpaNow: 1010,
          pressureHpa24hAgo: 1013,
          windSpeedMph: 8,
          daysSinceRain: 3,
        ),
        cfg: SpeciesConfig.largemouthBass,
        now: DateTime(2026, 10, 31, 7, 0),
        sunriseMin: sun.$1,
        sunsetMin: sun.$2,
        moonPhase: AstroUtils.moonPhase(DateTime(2026, 10, 31)),
      );
      expect(result.total, greaterThanOrEqualTo(60));
      expect(result.factors, isNotEmpty);
    });
  });
}
