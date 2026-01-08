import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../models/team_member.dart';
import '../utils/type_chart.dart';

class TeamProvider with ChangeNotifier {
  final List<TeamMember?> _teamA = List.filled(6, null);
  final List<TeamMember?> _teamB = List.filled(6, null); // Enemy Team

  List<String> _warnings = [];
  List<String> _suggestions = [];

  List<TeamMember?> get teamA => _teamA;
  List<TeamMember?> get teamB => _teamB;

  // Backwards compatibility so I don't break UI immediately (will fix UI next)
  List<TeamMember?> get slots => _teamA;

  List<String> get warnings => _warnings;
  List<String> get suggestions => _suggestions;

  void setPokemon(int index, Pokemon pokemon, {bool isTeamB = false}) {
    String? defaultAbility =
        pokemon.abilities.isNotEmpty ? pokemon.abilities.first : null;
    var target = isTeamB ? _teamB : _teamA;
    target[index] =
        TeamMember(pokemon: pokemon, selectedAbility: defaultAbility);
    if (!isTeamB) _analyzeTeam(); // Only analyze Team A for now
    notifyListeners();
  }

  void clearSlot(int index, {bool isTeamB = false}) {
    var target = isTeamB ? _teamB : _teamA;
    target[index] = null;
    if (!isTeamB) _analyzeTeam();
    notifyListeners();
  }

  void updateAbility(int index, String? ability, {bool isTeamB = false}) {
    var target = isTeamB ? _teamB : _teamA;
    if (target[index] != null) {
      target[index]!.selectedAbility = ability;
      if (!isTeamB) _analyzeTeam();
      notifyListeners();
    }
  }

  void updateLevel(int index, int level, {bool isTeamB = false}) {
    var target = isTeamB ? _teamB : _teamA;
    if (target[index] != null) {
      target[index]!.level = level;
      // Level change affects stats which might affect simulation but not type analysis
      notifyListeners();
    }
  }

  void updateMove(int index, int moveIndex, String? move,
      {bool isTeamB = false}) {
    var target = isTeamB ? _teamB : _teamA;
    if (target[index] != null) {
      target[index]!.selectedMoves[moveIndex] = move;
      if (!isTeamB) _analyzeTeam();
      notifyListeners();
    }
  }

  void _analyzeTeam() {
    _warnings = [];
    _suggestions = [];

    List<TeamMember> active = _teamA.whereType<TeamMember>().toList();
    if (active.isEmpty) {
      _suggestions.add("Add Pokemon to start analysis.");
      return;
    }

    // 1. Weakness Coverage
    // Map of AttackerType -> List of Team Members (Names) Weak to it
    Map<String, List<String>> weakMembers = {};
    for (var t in ALL_TYPES) weakMembers[t] = [];

    for (var member in active) {
      for (var atkType in ALL_TYPES) {
        double multiplier = 1.0;
        for (var defType in member.pokemon.types) {
          String dt = defType.trim();
          if (dt.isNotEmpty)
            dt = dt[0].toUpperCase() + dt.substring(1).toLowerCase();

          if (TYPE_CHART.containsKey(atkType) &&
              TYPE_CHART[atkType]!.containsKey(dt)) {
            multiplier *= TYPE_CHART[atkType]![dt]!;
          }
        }

        if (multiplier > 1.0) {
          weakMembers[atkType]!.add(member.pokemon.name);
        }
      }
    }

    // 2. Generate Warnings
    List<String> majorWeaknesses = [];
    weakMembers.forEach((type, members) {
      if (members.length >= 2) {
        // Changed threshold to 2 as requested "say which 2 pokemon"
        String severity = members.length >= 3 ? "Major" : "Moderate";
        _warnings.add("$severity $type weakness: ${members.join(', ')}");
        if (members.length >= 3) majorWeaknesses.add(type);
      }
    });

    // 3. Generate Suggestions
    if (majorWeaknesses.isNotEmpty) {
      for (var weakType in majorWeaknesses) {
        List<String> resistors = [];
        TYPE_CHART.forEach((atk, defenders) {
          if (TYPE_CHART[weakType]!.containsKey(atk) &&
              TYPE_CHART[weakType]![atk]! < 1.0) {
            resistors.add(atk);
          }
        });

        if (resistors.isNotEmpty) {
          _suggestions
              .add("Resist $weakType with: ${resistors.take(3).join('/')}");
        }
      }
    } else if (active.length < 6) {
      _suggestions.add("Team coverage looks okay so far.");
    }

    if (active.length == 6 && _warnings.isEmpty) {
      _suggestions.add("Great Balance! No major type overlaps.");
    }
  }

  Future<void> saveTeam() async {
    // Basic JSON generation (simulated persistence)
    print("Saving Team...");
    List<Map<String, dynamic>> data = _teamA.map((s) {
      if (s == null) return <String, dynamic>{};
      return <String, dynamic>{
        "id": s.pokemon.id,
        "name": s.pokemon.name,
        "ability": s.selectedAbility,
        "moves": s.selectedMoves
      };
    }).toList();
    print("Team Data: $data");
    // In a real desktop app, we would write this to File('team.json').
  }
}
