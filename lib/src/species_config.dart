/// Per-species tuning — ideal conditions and scoring weights.
///
/// Pure data, no dependencies. Used by [FisherRating] to weight each factor
/// and to judge water temp / wind against each species' ideal band.
class SpeciesConfig {
  final String species;
  final String displayName;
  final double idealTempStartC;
  final double idealTempEndC;
  final int tempWeight;
  final int pressureWeight;
  final int windWeight;
  final int timeMoonWeight;
  final int flowWeight;
  final int rainWeight;
  final int communityWeight;
  final int idealWindMphStart;
  final int idealWindMphEnd;
  final List<String> bestTimeOffsetsHours;
  final int idealDepthFtStart;
  final int idealDepthFtEnd;

  const SpeciesConfig({
    required this.species,
    required this.displayName,
    required this.idealTempStartC,
    required this.idealTempEndC,
    required this.tempWeight,
    required this.pressureWeight,
    required this.windWeight,
    required this.timeMoonWeight,
    required this.flowWeight,
    required this.rainWeight,
    required this.communityWeight,
    required this.idealWindMphStart,
    required this.idealWindMphEnd,
    required this.bestTimeOffsetsHours,
    required this.idealDepthFtStart,
    required this.idealDepthFtEnd,
  });

  int get totalWeight =>
      tempWeight + pressureWeight + windWeight + timeMoonWeight +
      flowWeight + rainWeight + communityWeight;

  static const largemouthBass = SpeciesConfig(
    species: 'largemouth_bass',
    displayName: 'Largemouth Bass',
    idealTempStartC: 18.0,
    idealTempEndC: 24.0,
    tempWeight: 25,
    pressureWeight: 20,
    windWeight: 15,
    timeMoonWeight: 15,
    flowWeight: 10,
    rainWeight: 10,
    communityWeight: 5,
    idealWindMphStart: 5,
    idealWindMphEnd: 12,
    bestTimeOffsetsHours: ['sunrise+1h', 'sunset-2h'],
    idealDepthFtStart: 3,
    idealDepthFtEnd: 12,
  );

  static const smallmouthBass = SpeciesConfig(
    species: 'smallmouth_bass',
    displayName: 'Smallmouth Bass',
    idealTempStartC: 15.0,
    idealTempEndC: 21.0,
    tempWeight: 25,
    pressureWeight: 20,
    windWeight: 15,
    timeMoonWeight: 15,
    flowWeight: 10,
    rainWeight: 10,
    communityWeight: 5,
    idealWindMphStart: 6,
    idealWindMphEnd: 14,
    bestTimeOffsetsHours: ['sunrise+1h', 'sunset-2h'],
    idealDepthFtStart: 8,
    idealDepthFtEnd: 20,
  );

  static const spottedBass = SpeciesConfig(
    species: 'spotted_bass',
    displayName: 'Spotted Bass',
    idealTempStartC: 17.0,
    idealTempEndC: 24.0,
    tempWeight: 25,
    pressureWeight: 20,
    windWeight: 15,
    timeMoonWeight: 15,
    flowWeight: 10,
    rainWeight: 10,
    communityWeight: 5,
    idealWindMphStart: 5,
    idealWindMphEnd: 14,
    bestTimeOffsetsHours: ['sunrise+1h', 'sunset-2h'],
    idealDepthFtStart: 10,
    idealDepthFtEnd: 25,
  );

  static const whiteBass = SpeciesConfig(
    species: 'white_bass',
    displayName: 'White Bass',
    idealTempStartC: 14.0,
    idealTempEndC: 21.0,
    tempWeight: 25,
    pressureWeight: 20,
    windWeight: 15,
    timeMoonWeight: 15,
    flowWeight: 10,
    rainWeight: 10,
    communityWeight: 5,
    idealWindMphStart: 5,
    idealWindMphEnd: 12,
    bestTimeOffsetsHours: ['sunrise+1h', 'sunset-1h'],
    idealDepthFtStart: 5,
    idealDepthFtEnd: 18,
  );

  static const stripedBass = SpeciesConfig(
    species: 'striped_bass',
    displayName: 'Striped Bass',
    idealTempStartC: 16.0,
    idealTempEndC: 22.0,
    tempWeight: 25,
    pressureWeight: 20,
    windWeight: 15,
    timeMoonWeight: 15,
    flowWeight: 10,
    rainWeight: 10,
    communityWeight: 5,
    idealWindMphStart: 8,
    idealWindMphEnd: 18,
    bestTimeOffsetsHours: ['sunrise+1h', 'sunset-2h'],
    idealDepthFtStart: 15,
    idealDepthFtEnd: 35,
  );

  static const crappie = SpeciesConfig(
    species: 'crappie',
    displayName: 'Crappie',
    idealTempStartC: 15.0,
    idealTempEndC: 22.0,
    tempWeight: 25,
    pressureWeight: 20,
    windWeight: 15,
    timeMoonWeight: 15,
    flowWeight: 10,
    rainWeight: 10,
    communityWeight: 5,
    idealWindMphStart: 3,
    idealWindMphEnd: 10,
    bestTimeOffsetsHours: ['sunrise+1h', 'sunset-2h'],
    idealDepthFtStart: 5,
    idealDepthFtEnd: 15,
  );

  static const catfish = SpeciesConfig(
    species: 'catfish',
    displayName: 'Catfish',
    idealTempStartC: 18.0,
    idealTempEndC: 26.0,
    tempWeight: 25,
    pressureWeight: 10,
    windWeight: 10,
    timeMoonWeight: 15,
    flowWeight: 10,
    rainWeight: 20,
    communityWeight: 10,
    idealWindMphStart: 0,
    idealWindMphEnd: 10,
    bestTimeOffsetsHours: ['sunset-1h', 'sunrise+2h'],
    idealDepthFtStart: 8,
    idealDepthFtEnd: 20,
  );

  static const muskie = SpeciesConfig(
    species: 'muskie',
    displayName: 'Muskellunge',
    idealTempStartC: 12.0,
    idealTempEndC: 18.0,
    tempWeight: 25,
    pressureWeight: 20,
    windWeight: 15,
    timeMoonWeight: 15,
    flowWeight: 10,
    rainWeight: 10,
    communityWeight: 5,
    idealWindMphStart: 3,
    idealWindMphEnd: 10,
    bestTimeOffsetsHours: ['sunrise+2h', 'sunset-2h'],
    idealDepthFtStart: 5,
    idealDepthFtEnd: 15,
  );

  static const bluegill = SpeciesConfig(
    species: 'bluegill',
    displayName: 'Bluegill',
    idealTempStartC: 18.0,
    idealTempEndC: 26.0,
    tempWeight: 25,
    pressureWeight: 15,
    windWeight: 10,
    timeMoonWeight: 15,
    flowWeight: 10,
    rainWeight: 15,
    communityWeight: 10,
    idealWindMphStart: 0,
    idealWindMphEnd: 8,
    bestTimeOffsetsHours: ['sunrise+2h', 'sunset-1h'],
    idealDepthFtStart: 2,
    idealDepthFtEnd: 10,
  );

  /// All supported species by id — used for the species switcher.
  static final Map<String, SpeciesConfig> all = {
    for (final c in [
      largemouthBass, smallmouthBass, spottedBass, whiteBass,
      stripedBass, crappie, catfish, muskie, bluegill,
    ])
      c.species: c,
  };

  /// Resolve by id; falls back to largemouth bass when unknown.
  static SpeciesConfig byId(String id) => all[id] ?? largemouthBass;
}
