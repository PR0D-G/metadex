import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../providers/data_provider.dart';
import '../widgets/team_slot_card.dart';
import '../widgets/pokemon_selector.dart';
import '../models/team_member.dart';

class TeamBuilderScreen extends StatelessWidget {
  const TeamBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teamProv = Provider.of<TeamProvider>(context);
    final currentSlots = teamProv.teamA;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Analysis Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF222222),
            height: 140, // Analysis Height
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("TEAM ANALYSIS",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    TextButton.icon(
                        onPressed: () => teamProv.saveTeam(),
                        icon: const Icon(Icons.save, color: Colors.cyan),
                        label: const Text("Save Team",
                            style: TextStyle(color: Colors.cyan)))
                  ],
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: ListView(
                    children: [
                      if (teamProv.warnings.isEmpty &&
                          teamProv.suggestions.isEmpty)
                        const Text("Add Pokemon to see analysis.",
                            style: TextStyle(color: Colors.grey)),
                      ...teamProv.warnings.map((w) => Text(w,
                          style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold))),
                      ...teamProv.suggestions.map((s) => Text(s,
                          style: const TextStyle(color: Colors.greenAccent))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isMobile = constraints.maxWidth < 850;
                  if (isMobile) {
                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: 6,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        return SizedBox(
                          height: currentSlots[i] == null ? 200 : 660,
                          child: TeamSlotCard(
                            index: i,
                            member: currentSlots[i],
                            onSelect: () => _openSelection(context, i),
                            onRemove: () => teamProv.clearSlot(i),
                            onAbilityChanged: (val) =>
                                teamProv.updateAbility(i, val),
                            onMoveChanged: (mIdx, val) =>
                                teamProv.updateMove(i, mIdx, val),
                            onLevelChanged: (lvl) =>
                                teamProv.updateLevel(i, lvl),
                          ),
                        );
                      },
                    );
                  } else {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(6, (i) {
                        return Expanded(
                          child: TeamSlotCard(
                            index: i,
                            member: currentSlots[i],
                            onSelect: () => _openSelection(context, i),
                            onRemove: () => teamProv.clearSlot(i),
                            onAbilityChanged: (val) =>
                                teamProv.updateAbility(i, val),
                            onMoveChanged: (mIdx, val) =>
                                teamProv.updateMove(i, mIdx, val),
                            onLevelChanged: (lvl) =>
                                teamProv.updateLevel(i, lvl),
                          ),
                        );
                      }),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSelection(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => FractionallySizedBox(
              heightFactor: 0.9,
              child: const PokemonSelector(),
            )).then((selectedPokemon) {
      if (selectedPokemon != null) {
        Provider.of<TeamProvider>(context, listen: false)
            .setPokemon(index, selectedPokemon);
      }
    });
  }
}
