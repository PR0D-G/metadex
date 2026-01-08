class Pokemon {
  final int id;
  final String name;
  final List<String> types;
  final Map<String, int> stats;
  final List<String> abilities;
  final List<String> moves;
  final String evolution;
  final String imagePath;

  Pokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.stats,
    required this.abilities,
    required this.moves,
    required this.evolution,
    required this.imagePath,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    // Handle types which might be string "Fire/Flying" or list ["Fire", "Flying"]
    List<String> typeList = [];
    if (json['types'] is List) {
      typeList = List<String>.from(json['types']);
    } else if (json['types'] is String) {
      typeList =
          (json['types'] as String).split('/').map((e) => e.trim()).toList();
    }

    // Previous python generator might have used "types" or "type"
    // Check both for robustness
    if (typeList.isEmpty && json['type'] != null) {
      if (json['type'] is String) {
        typeList =
            (json['type'] as String).split('/').map((e) => e.trim()).toList();
      }
    }

    // Stats might have keys like "special-attack". We keep them as is for map lookup.
    Map<String, int> statMap = {};
    if (json['stats'] != null) {
      (json['stats'] as Map<String, dynamic>).forEach((k, v) {
        statMap[k] = v as int;
      });
    }

    return Pokemon(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      types: typeList,
      stats: statMap,
      abilities:
          json['abilities'] != null ? List<String>.from(json['abilities']) : [],
      moves: json['moves'] != null ? List<String>.from(json['moves']) : [],
      evolution: json['evolution'] ?? '',
      imagePath: json['image_path'] ?? '',
    );
  }

  Map<String, int> getStatsAtLevel(int level) {
    Map<String, int> newStats = {};
    if (level < 1) level = 1;
    if (level > 100) level = 100;

    stats.forEach((key, baseValue) {
      if (key.toLowerCase() == 'hp') {
        // HP Formula: floor((2 * Base * Level) / 100 + Level + 10)
        newStats[key] = ((2 * baseValue * level) / 100 + level + 10).floor();
      } else {
        // Other Stats Formula: floor((2 * Base * Level) / 100 + 5)
        newStats[key] = ((2 * baseValue * level) / 100 + 5).floor();
      }
    });
    return newStats;
  }
}
