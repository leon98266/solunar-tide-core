import 'dart:math' as math;

/// Local astronomical calculations — no network needed.
///
/// - Sunrise/sunset: NOAA simplified solar calculator.
/// - Moon phase: synodic month approximation.
///
/// This module is a self-contained, dependency-free port of the core
/// astronomical utilities used by the BiteCall fishing app.
class AstroUtils {
  /// Compute sunrise and sunset for a given date/lat/lng.
  ///
  /// Returns `(sunriseMinutesFromMidnight, sunsetMinutesFromMidnight)` in local
  /// time, or `null` if the sun never rises/sets (polar day or night).
  ///
  /// - [date]: the calendar date.
  /// - [lat]: latitude in degrees (positive = north).
  /// - [lng]: longitude in degrees (positive = east).
  /// - [utcOffsetMinutes]: the location's UTC offset in minutes (e.g. UTC+8 = 480).
  static (int, int)? sunTimes(
    DateTime date,
    double lat,
    double lng,
    int utcOffsetMinutes,
  ) {
    final dayOfYear = _dayOfYear(date);

    // NOAA simplified solar calculator
    final b = _radians(360.0 / 365.0 * (dayOfYear - 81));
    final eqOfTime =
        9.87 * math.sin(2 * b) - 7.53 * math.cos(b) - 1.5 * math.sin(b); // minutes
    // NOTE: In the NOAA formula `23.44 * sin(b)` is already in DEGREES.
    // Do NOT wrap it in radians-to-degrees conversion — that breaks the result.
    final declination = 23.44 * math.sin(b); // degrees

    // Solar noon in UTC minutes, then to local
    final solarNoonUtc = 720.0 - 4.0 * lng - eqOfTime;
    final solarNoonLocal = solarNoonUtc + utcOffsetMinutes;

    final latRad = _radians(lat);
    final declRad = _radians(declination);

    final cosH = (math.sin(_radians(-0.83)) - math.sin(latRad) * math.sin(declRad)) /
        (math.cos(latRad) * math.cos(declRad));
    if (cosH >= 1 || cosH <= -1) return null; // polar day or night

    final hourAngle = _degrees(math.acos(cosH));
    final sunrise = solarNoonLocal - 4.0 * hourAngle;
    final sunset = solarNoonLocal + 4.0 * hourAngle;

    return (_normalize1440(sunrise).round(), _normalize1440(sunset).round());
  }

  /// Moon phase as a fraction of the synodic month:
  /// `0.0` = new moon, `0.25` = first quarter, `0.5` = full moon,
  /// `0.75` = last quarter.
  static double moonPhase(DateTime date) {
    final knownNewMoon = DateTime(2000, 1, 6); // a known new moon
    const synodic = 29.53058867; // synodic month in days
    final days = date.difference(knownNewMoon).inDays.toDouble();
    return ((days % synodic) / synodic) % 1.0;
  }

  static int _dayOfYear(DateTime d) {
    final start = DateTime(d.year, 1, 1);
    return d.difference(start).inDays + 1;
  }

  static double _radians(double deg) => deg * math.pi / 180.0;

  static double _degrees(double rad) => rad * 180.0 / math.pi;

  static double _normalize1440(double min) => ((min % 1440) + 1440) % 1440;
}
