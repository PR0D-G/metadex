import 'pokemon.dart';

class TeamMember {
  final Pokemon pokemon;
  String? selectedAbility;
  List<String?> selectedMoves; // 4 moves
  int level;

  TeamMember({
    required this.pokemon,
    this.selectedAbility,
    List<String?>? moves,
    this.level = 50,
  }) : selectedMoves = moves ?? List.filled(4, null);
}
