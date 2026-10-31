/// solunar_tide_core
///
/// Lightweight offline solunar & fishing-time calculation library for fishing
/// apps. Pure Dart, no network, no external dependencies.
///
/// - [AstroUtils]: sunrise/sunset + moon phase (NOAA simplified solar calculator).
/// - [SolunarScore]: prime bite-time ("solunar") scoring + best bite windows.
/// - [FisherRating]: weighted multi-factor bite-quality rating engine.
/// - [SpeciesConfig]: per-species ideal conditions and scoring weights.
library;

export 'src/astro_utils.dart';
export 'src/solunar_score.dart';
export 'src/fisher_rating.dart';
export 'src/species_config.dart';
