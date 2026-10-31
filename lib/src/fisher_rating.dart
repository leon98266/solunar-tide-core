import 'dart:math' as math;

import 'astro_utils.dart';
import 'solunar_score.dart';
import 'species_config.dart';

/// Overall bite-quality verdict.
enum Verdict { excellent, veryGood, good, fair, poor }

/// One scored factor (e.g. water temp, wind) with its weight.
class FactorScore {
  final String label;
  final String detail;
  final int score0to100;
  final int weightPct;

  const FactorScore({
    required this.label,
    required this.detail,
    required this.score0to100,
    required this.weightPct,
  });
}

/// The full result of a weighted scoring run.
class ScoreResult {
  final int total;
  final Verdict verdict;
  final String headline;
  final List<FactorScore> factors;
  final String bestWindowText;
  final String recommendedLure;

  const ScoreResult({
    required this.total,
    required this.verdict,
    required this.headline,
    required this.factors,
    required this.bestWindowText,
    required this.recommendedLure,
  });
}

/// Observed conditions feeding the score. Missing fields score a neutral 50.
class ObservedConditions {
  final double? waterTempC;
  final bool waterTempIsAngler;
  final double? airTempC;
  final double? pressureHpaNow;
  final double? pressureHpa24hAgo;
  final double? windSpeedMph;
  final double? flowCfsNow;
  final double? flowCfs7daysAgo;
  final double? daysSinceRain;
  final double? communityGoodBiteRatio;

  const ObservedConditions({
    this.waterTempC,
    this.waterTempIsAngler = false,
    this.airTempC,
    this.pressureHpaNow,
    this.pressureHpa24hAgo,
    this.windSpeedMph,
    this.flowCfsNow,
    this.flowCfs7daysAgo,
    this.daysSinceRain,
    this.communityGoodBiteRatio,
  });

  ObservedConditions copyWith({double? waterTempC}) => ObservedConditions(
        waterTempC: waterTempC ?? this.waterTempC,
        waterTempIsAngler: waterTempC != null ? true : waterTempIsAngler,
        airTempC: airTempC,
        pressureHpaNow: pressureHpaNow,
        pressureHpa24hAgo: pressureHpa24hAgo,
        windSpeedMph: windSpeedMph,
        flowCfsNow: flowCfsNow,
        flowCfs7daysAgo: flowCfs7daysAgo,
        daysSinceRain: daysSinceRain,
        communityGoodBiteRatio: communityGoodBiteRatio,
      );
}

/// Raw hourly weather used for the hourly bite curve.
class HourlyWeatherPoint {
  final DateTime time;
  final double? airTempC;
  final double? windMph;
  final double? cloudCoverPct;

  const HourlyWeatherPoint({
    required this.time,
    this.airTempC,
    this.windMph,
    this.cloudCoverPct,
  });
}

/// Raw daily forecast used for the multi-day outlook.
class DailyWeatherPoint {
  final DateTime date;
  final double? tempMaxC;
  final double? tempMinC;
  final double? rainMm;
  final double? windMphMax;

  const DailyWeatherPoint({
    required this.date,
    this.tempMaxC,
    this.tempMinC,
    this.rainMm,
    this.windMphMax,
  });
}

class HourlyBitePoint {
  final String hourLabel;
  final int score;

  const HourlyBitePoint({required this.hourLabel, required this.score});
}

class DailyBiteForecast {
  final DateTime date;
  final int score;
  final Verdict verdict;
  final String detail;

  const DailyBiteForecast({
    required this.date,
    required this.score,
    required this.verdict,
    required this.detail,
  });
}

/// Weighted fishing-condition rating engine.
///
/// Combines water temp, air temp, pressure trend, wind, time+moon, flow trend,
/// days since rain and community signal into a single 0..100 score.
/// Missing data scores a neutral 50. Dependency-free and offline.
class FisherRating {
  /// Compute the total score from observations. Each factor is normalized to
  /// 0..100 then weighted per [SpeciesConfig]. Missing data gets a neutral 50.
  static ScoreResult score({
    required ObservedConditions obs,
    required SpeciesConfig cfg,
    required DateTime now,
    required int sunriseMin,
    required int sunsetMin,
    required double moonPhase,
  }) {
    final factors = <FactorScore>[];

    // 1. Water temp (weight from config)
    final tempScore =
        obs.waterTempC != null ? _waterTempScore(obs.waterTempC!, cfg) : 50;
    final tempF =
        obs.waterTempC != null ? (obs.waterTempC! * 9.0 / 5.0 + 32).round() : null;
    factors.add(FactorScore(
      label: 'Water Temp',
      detail: tempF != null
          ? '$tempF°F (${obs.waterTempC!.round()}°C) · '
              '${obs.waterTempIsAngler ? 'Angler report' : 'Gauge'} · '
              '${_qualityLabel(tempScore)}'
          : 'No gauge',
      score0to100: tempScore,
      weightPct: cfg.tempWeight,
    ));

    final airC = obs.airTempC;
    if (airC != null) {
      final airF = (airC * 9.0 / 5.0 + 32).round();
      factors.add(FactorScore(
        label: 'Air Temp',
        detail: '$airF°F (${airC.round()}°C)',
        score0to100: 100,
        weightPct: 0,
      ));
    }

    // 2. Pressure trend: best = falling 2-5 hPa in 24h
    final pressScore =
        (obs.pressureHpaNow != null && obs.pressureHpa24hAgo != null)
            ? _pressureScore(obs.pressureHpaNow!, obs.pressureHpa24hAgo!)
            : 50;
    factors.add(FactorScore(
      label: 'Pressure Trend',
      detail: (obs.pressureHpaNow != null && obs.pressureHpa24hAgo != null)
          ? '${obs.pressureHpaNow!.round()} hPa · '
              '${(obs.pressureHpaNow! - obs.pressureHpa24hAgo!).toStringAsFixed(1)}/24h · '
              '${_qualityLabel(pressScore)}'
          : 'Unavailable',
      score0to100: pressScore,
      weightPct: cfg.pressureWeight,
    ));

    // 3. Wind: ideal 5-12 mph
    final windScore =
        obs.windSpeedMph != null ? _windScore(obs.windSpeedMph!, cfg) : 50;
    factors.add(FactorScore(
      label: 'Wind',
      detail: obs.windSpeedMph != null
          ? '${obs.windSpeedMph!.round()} mph · ${_qualityLabel(windScore)}'
          : 'Unavailable',
      score0to100: windScore,
      weightPct: cfg.windWeight,
    ));

    // 4. Time / moon (solunar signal)
    final tmScore = SolunarScore.timeMoonScore(now, sunriseMin, sunsetMin, moonPhase);
    factors.add(FactorScore(
      label: 'Time & Moon',
      detail: '${SolunarScore.moonPhaseOf(moonPhase).name} · '
          '${_qualityLabel(tmScore)}',
      score0to100: tmScore,
      weightPct: cfg.timeMoonWeight,
    ));

    // 5. Flow trend: best 2-4 days post-rain falling
    final flowScore = (obs.flowCfsNow != null && obs.flowCfs7daysAgo != null)
        ? _flowScore(obs.flowCfsNow!, obs.flowCfs7daysAgo!)
        : 50;
    factors.add(FactorScore(
      label: 'Flow Trend',
      detail: obs.flowCfsNow != null
          ? '${obs.flowCfsNow!.round()} cfs · ${_qualityLabel(flowScore)}'
          : 'Unavailable',
      score0to100: flowScore,
      weightPct: cfg.flowWeight,
    ));

    // 6. Days since rain: best 2-4 days
    final rainScore = obs.daysSinceRain != null ? _rainScore(obs.daysSinceRain!) : 50;
    factors.add(FactorScore(
      label: 'Days Since Rain',
      detail: obs.daysSinceRain != null
          ? '${obs.daysSinceRain!.round()} d · ${_qualityLabel(rainScore)}'
          : 'No data',
      score0to100: rainScore,
      weightPct: cfg.rainWeight,
    ));

    // 7. Community signal
    final commScore = obs.communityGoodBiteRatio != null
        ? (obs.communityGoodBiteRatio! * 100).round()
        : 50;
    factors.add(FactorScore(
      label: 'Community',
      detail: obs.communityGoodBiteRatio != null
          ? '${(obs.communityGoodBiteRatio! * 100).round()}% good bite · recent'
          : 'No reports yet',
      score0to100: commScore,
      weightPct: cfg.communityWeight,
    ));

    // Weighted total
    final total = factors
        .map((f) => f.score0to100 * f.weightPct)
        .fold(0, (a, b) => a + b) ~/ cfg.totalWeight;
    final verdict = _verdictFor(total);
    final headline = switch (verdict) {
      Verdict.excellent => 'Excellent — the bite is on',
      Verdict.veryGood => 'Very good — prime windows are strong',
      Verdict.good => 'Good — work the best window',
      Verdict.fair => 'Fair — stick to the prime window',
      Verdict.poor => 'Poor — pick a better day',
    };

    return ScoreResult(
      total: total,
      verdict: verdict,
      headline: headline,
      factors: factors,
      bestWindowText:
          '${_formatWindow(sunriseMin + 60, sunriseMin + 180)} (Sunrise + 1h)',
      recommendedLure: 'Match the hatch',
    );
  }

  /// Hourly bite curve for the day: time of day (40%) + air temp (20%) +
  /// wind (20%) + cloud (20%).
  static List<HourlyBitePoint> hourlyScores({
    required List<HourlyWeatherPoint> hourly,
    required SpeciesConfig cfg,
    required int sunriseMin,
    required int sunsetMin,
  }) =>
      hourly.map((hp) {
        final m = hp.time.hour * 60 + hp.time.minute;

        final timeScore = switch (m) {
          _ when m >= sunriseMin && m <= (sunriseMin + 120) => 100, // golden: sunrise + 2h
          _ when m >= (sunriseMin - 60) && m < sunriseMin => 85, // pre-dawn
          _ when m >= (sunsetMin - 120) && m <= (sunsetMin + 60) => 80, // dusk
          _ when m >= (sunriseMin + 120) && m < (sunsetMin - 120) => 60, // mid-day
          _ => 45, // night
        };

        final tempScore = hp.airTempC != null
            ? switch (hp.airTempC!) {
                _ when hp.airTempC! >= 18.0 && hp.airTempC! <= 24.0 => 100,
                _ when hp.airTempC! < 8.0 || hp.airTempC! > 33.0 => 30,
                _ => 60,
              }
            : 50;

        final windScore = hp.windMph != null ? _windScore(hp.windMph!, cfg) : 50;

        final cloudScore = hp.cloudCoverPct != null
            ? switch (hp.cloudCoverPct!) {
                _ when hp.cloudCoverPct! >= 70 => 90, // overcast
                _ when hp.cloudCoverPct! >= 40 && hp.cloudCoverPct! < 70 => 75,
                _ when hp.cloudCoverPct! >= 10 && hp.cloudCoverPct! < 40 => 55,
                _ => 40, // bluebird skies
              }
            : 50;

        final score = (timeScore * 0.4 +
                tempScore * 0.2 +
                windScore * 0.2 +
                cloudScore * 0.2)
            .round();
        return HourlyBitePoint(hourLabel: _hourLabel(hp.time), score: score);
      }).toList();

  /// Scores each of the next few days from a daily forecast:
  /// temp band (50%) + rain (30%) + wind (20%). Missing fields score 50.
  static List<DailyBiteForecast> dailyForecastScores({
    required List<DailyWeatherPoint> forecasts,
  }) =>
      forecasts.map((f) {
        final tempScore = (f.tempMaxC != null && f.tempMinC != null)
            ? _dailyTempScore(f.tempMaxC!, f.tempMinC!)
            : 50;

        final rainScore = f.rainMm != null
            ? switch (f.rainMm!) {
                _ when f.rainMm! <= 2.0 => 100, // dry
                _ when f.rainMm! > 2.0 && f.rainMm! <= 8.0 => 70,
                _ when f.rainMm! > 8.0 && f.rainMm! <= 15.0 => 45,
                _ => 30, // heavy rain day
              }
            : 50;

        final windScore = f.windMphMax != null
            ? switch (f.windMphMax!) {
                _ when f.windMphMax! >= 5.0 && f.windMphMax! <= 12.0 => 100,
                _ when f.windMphMax! < 3.0 => 55,
                _ when f.windMphMax! >= 12.0 && f.windMphMax! <= 18.0 => 65,
                _ when f.windMphMax! > 22.0 => 25,
                _ => 70,
              }
            : 50;

        final total = (tempScore * 0.5 + rainScore * 0.3 + windScore * 0.2).round();
        final verdict = _verdictFor(total);
        final detail = StringBuffer();
        if (f.tempMaxC != null && f.tempMinC != null) {
          final maxF = (f.tempMaxC! * 9.0 / 5.0 + 32).round();
          final minF = (f.tempMinC! * 9.0 / 5.0 + 32).round();
          detail.write('$maxF°F / $minF°F');
        }
        final rain = f.rainMm;
        if (rain != null) {
          detail.write(rain >= 1.0 ? ' · ${rain.round()} mm rain' : ' · dry');
        }
        return DailyBiteForecast(
          date: f.date,
          score: total,
          verdict: verdict,
          detail: detail.toString(),
        );
      }).toList();

  /// "Bad weather" turned into actionable angles. When the total score is low,
  /// these tell the angler which conditions actually work in their favor.
  static List<String> buildTips({required ObservedConditions obs}) {
    final tips = <String>[];
    final w = obs.windSpeedMph;
    if (w != null) {
      if (w >= 15) {
        tips.add('Windy — fish wind-blown points & shallow banks');
      } else if (w <= 3) {
        tips.add('Dead calm — go at first light or dusk, work deeper structure');
      }
    }
    if (obs.pressureHpaNow != null && obs.pressureHpa24hAgo != null) {
      final delta = obs.pressureHpaNow! - obs.pressureHpa24hAgo!;
      if (delta >= -5.0 && delta <= -2.0) {
        tips.add('Pressure falling — fish feed hard before the front; stay mobile');
      } else if (delta > 5.0) {
        tips.add('Pressure rising — slow down, fish tight to cover');
      }
    }
    final d = obs.daysSinceRain;
    if (d != null && d >= 2.0 && d <= 4.0) {
      tips.add('2–4 days post-rain — stained water; dark baits & louder profiles');
    }
    if (obs.waterTempC == null) {
      tips.add('No water temp gauge here — report your reading after the trip');
    }
    final a = obs.airTempC;
    if (a != null && a >= 30.0) {
      tips.add('Hot — target early morning & shaded banks, or go deep with finesse');
    }
    if (tips.isEmpty) tips.add('Conditions are steady — work the bait slowly');
    return tips;
  }

  // ---- factor helpers ----

  static int _waterTempScore(double t, SpeciesConfig cfg) {
    if (t >= cfg.idealTempStartC && t <= cfg.idealTempEndC) return 100;
    final dist =
        math.min((t - cfg.idealTempStartC).abs(), (t - cfg.idealTempEndC).abs());
    return (100 - dist * 25).clamp(0, 100).round();
  }

  static int _pressureScore(double now, double ago) {
    final delta = now - ago;
    if (delta >= -5.0 && delta <= -2.0) return 100;
    if (delta >= -2.0 && delta < 0.0) return 75;
    if (delta >= -8.0 && delta < -5.0) return 70;
    if (delta >= 0.0 && delta <= 3.0) return 50;
    if (delta > 5.0) return 25; // rising pressure = tough bite
    return 40;
  }

  static int _windScore(double w, SpeciesConfig cfg) {
    if (w >= cfg.idealWindMphStart.toDouble() &&
        w <= cfg.idealWindMphEnd.toDouble()) {
      return 100;
    }
    if (w < 3) return 55;
    if (w >= 12.0 && w <= 18.0) return 65;
    if (w > 20) return 25;
    return 70;
  }

  static int _flowScore(double now, double ago) {
    final ratio = ago > 0 ? now / ago : 1.0;
    if (ratio >= 0.5 && ratio <= 0.95) return 100; // receding
    if (ratio > 0.95 && ratio <= 1.05) return 60; // stable
    if (ratio < 0.5) return 70; // falling fast
    return 35; // rising
  }

  static int _rainScore(double d) {
    if (d >= 2.0 && d <= 4.0) return 100;
    if (d < 1.0) return 30;
    if (d < 2.0) return 70;
    if (d < 7.0) return 65;
    return 50;
  }

  static int _dailyTempScore(double max, double min) {
    if (max >= 18.0 && max <= 27.0 && min >= 8.0) return 100;
    if (max > 33.0 || min < 2.0) return 30;
    if (max > 27.0 || min < 8.0) return 60;
    return 70;
  }

  static Verdict _verdictFor(int total) {
    if (total >= 90) return Verdict.excellent;
    if (total >= 75) return Verdict.veryGood;
    if (total >= 60) return Verdict.good;
    if (total >= 40) return Verdict.fair;
    return Verdict.poor;
  }

  static String _hourLabel(DateTime t) {
    final h = t.hour;
    if (h == 0) return '12 AM';
    if (h < 12) return '$h AM';
    if (h == 12) return '12 PM';
    return '${h - 12} PM';
  }

  static String _qualityLabel(int s) {
    if (s >= 85) return 'Ideal';
    if (s >= 65) return 'Good';
    if (s >= 45) return 'Fair';
    return 'Poor';
  }

  static String _formatWindow(int startMin, int endMin) {
    String fmt(int m) {
      final h = (m ~/ 60);
      final hh = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      final mm = (m % 60).toString().padLeft(2, '0');
      final ap = m < 12 * 60 ? 'AM' : 'PM';
      return '$hh:$mm $ap';
    }

    return '${fmt(startMin)} – ${fmt(endMin)}';
  }
}
