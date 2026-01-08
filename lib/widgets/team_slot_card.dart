import 'package:flutter/material.dart';

import '../models/team_member.dart';
import '../widgets/type_badge.dart';
import '../utils/game_theme.dart';

class TeamSlotCard extends StatelessWidget {
  final int index;
  final TeamMember? member;
  final VoidCallback onSelect;
  final VoidCallback onRemove;
  final Function(String?) onAbilityChanged;
  final Function(int, String?) onMoveChanged;
  final Function(int) onLevelChanged;

  const TeamSlotCard({
    super.key,
    required this.index,
    required this.member,
    required this.onSelect,
    required this.onRemove,
    required this.onAbilityChanged,
    required this.onMoveChanged,
    required this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Width handled by parent (Grid)
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(12),
      decoration: GameTheme.goldBorderDecoration,
      child: member == null ? _buildEmpty(context) : _buildActive(context),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: GameTheme.gold, width: 2),
          ),
          child: const Icon(Icons.add, size: 40, color: GameTheme.gold),
        ),
        const SizedBox(height: 10),
        const Text("Empty Slot",
            style: TextStyle(
                color: GameTheme.gold, fontSize: 16, fontFamily: 'serif')),
        const SizedBox(height: 20),
        _buildGoldButton("Select Pokemon", onSelect),
      ],
    );
  }

  Widget _buildActive(BuildContext context) {
    final p = member!.pokemon;
    final stats = p.getStatsAtLevel(member!.level);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Centered layout like image
        children: [
          // Header (Remove button)
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: onRemove,
              child: const Icon(Icons.close, color: Colors.redAccent, size: 20),
            ),
          ),

          // Image
          SizedBox(
            height: 100,
            width: 100,
            child: p.imagePath.isNotEmpty
                ? Image.asset("assets/${p.imagePath}",
                    errorBuilder: (c, e, s) => const Icon(Icons.broken_image))
                : const Icon(Icons.image),
          ),

          Text(p.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'serif')),

          const SizedBox(height: 5),

          // Types
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                p.types.map((t) => TypeBadge(type: t, small: true)).toList(),
          ),

          const SizedBox(height: 10),

          // Level Control
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Lv.",
                  style: const TextStyle(
                      color: GameTheme.gold, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Container(
                height: 30,
                decoration: BoxDecoration(
                  border: Border.all(color: GameTheme.gold),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [25, 50, 75, 100].map((lvl) {
                    bool isActive = member!.level == lvl;
                    return GestureDetector(
                      onTap: () => onLevelChanged(lvl),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        color: isActive ? GameTheme.gold : Colors.transparent,
                        alignment: Alignment.center,
                        child: Text(
                          "$lvl",
                          style: TextStyle(
                              color: isActive ? Colors.black : GameTheme.gold,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Stats Display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                'hp',
                'attack',
                'defense',
                'special-attack',
                'special-defense',
                'speed'
              ].map((key) {
                int value = stats[key] ?? 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          _formatStatName(key),
                          style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "$value",
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // Selection
          _buildGoldButton("Change Pokemon", onSelect),

          const SizedBox(height: 15),

          // Ability
          Align(
            alignment: Alignment.centerLeft,
            child: const Text("Ability:",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const SizedBox(height: 4),
          _buildParchmentDropdown(
              value: member!.selectedAbility,
              items: p.abilities,
              onChanged: (val) => onAbilityChanged(val),
              hint: "Ability"),

          const SizedBox(height: 10),

          // Moves
          Align(
            alignment: Alignment.centerLeft,
            child: const Text("Moves:",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const SizedBox(height: 4),

          for (int i = 0; i < 4; i++) ...[
            _buildParchmentDropdown(
              value: member!.selectedMoves[i],
              items: p.moves.take(200).toList(), // Limit for perf
              onChanged: (val) => onMoveChanged(i, val),
              hint: "-",
            ),
            const SizedBox(height: 5),
          ]
        ],
      ),
    );
  }

  String _formatStatName(String raw) {
    switch (raw.toLowerCase()) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'Atk';
      case 'defense':
        return 'Def';
      case 'special-attack':
        return 'SpA';
      case 'special-defense':
        return 'SpD';
      case 'speed':
        return 'Spe';
      default:
        return raw.substring(0, 3).toUpperCase();
    }
  }

  Widget _buildGoldButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
            gradient: GameTheme.goldGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: GameTheme.goldLight),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  offset: const Offset(0, 2),
                  blurRadius: 4)
            ]),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
              color: Color(0xFF3E362A),
              fontWeight: FontWeight.bold,
              fontFamily: 'serif'),
        ),
      ),
    );
  }

  Widget _buildParchmentDropdown({
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: GameTheme.parchmentDecoration,
      height: 35,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null, // Safety check
          isExpanded: true,
          dropdownColor: GameTheme.parchment,
          icon:
              const Icon(Icons.arrow_drop_down, color: GameTheme.parchmentText),
          style: const TextStyle(
              color: GameTheme.parchmentText,
              fontFamily: 'serif',
              fontSize: 13,
              fontWeight: FontWeight.bold),
          hint: Text(hint,
              style:
                  TextStyle(color: GameTheme.parchmentText.withOpacity(0.6))),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
