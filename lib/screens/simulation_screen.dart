import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../models/team_member.dart';
import '../widgets/team_slot_card.dart';
import '../widgets/pokemon_selector.dart';
import 'dart:math';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  int teamSize = 6;
  List<String> logs = [];
  bool isSimulating = false;
  int _battleSize = 1;
  bool _isSimulating = false;
  String _resultText = "Ready to Simulate";
  List<String> _logs = [];

  bool _pokemonBattle(TeamMember myPoke, TeamMember enemyPoke, Random rng) {
    double myPower = myPoke.pokemon
        .getStatsAtLevel(myPoke.level)
        .values
        .fold(0, (a, b) => a + b)
        .toDouble();

    double enemyPower = enemyPoke.pokemon
        .getStatsAtLevel(enemyPoke.level)
        .values
        .fold(0, (a, b) => a + b)
        .toDouble();

    double myRoll = myPower * (0.8 + rng.nextDouble() * 0.4);
    double enemyRoll = enemyPower * (0.8 + rng.nextDouble() * 0.4);

    return myRoll > enemyRoll;
  }

  void _runProbabilitySimulation(BuildContext context) async {
    final teamProv = Provider.of<TeamProvider>(context, listen: false);
    final myTeam = teamProv.teamA.whereType<TeamMember>().toList();
    final enemyTeam = teamProv.teamB.whereType<TeamMember>().toList();

    if (myTeam.isEmpty || enemyTeam.isEmpty) {
      setState(() =>
          _resultText = "Error: Both teams must have at least 1 Pokemon.");
      return;
    }

    setState(() {
      _isSimulating = true;
      _resultText = "Simulating 100 Battles...";
      _logs = [];
    });

    // Monte Carlo Simulation
    int totalBattles = 100;
    int myWins = 0;
    final rng = Random();

    await Future.delayed(const Duration(milliseconds: 100)); // UI Refresh

    for (int i = 0; i < totalBattles; i++) {
      // Sequential team battle
      List<TeamMember> myQueue = List.from(myTeam)..shuffle(rng);
      List<TeamMember> enemyQueue = List.from(enemyTeam)..shuffle(rng);

      int myIndex = 0;
      int enemyIndex = 0;

      int activeMy = min(_battleSize, myQueue.length);
      int activeEnemy = min(_battleSize, enemyQueue.length);

      List<TeamMember> myActive = myQueue.take(activeMy).toList();
      List<TeamMember> enemyActive = enemyQueue.take(activeEnemy).toList();

      myIndex = activeMy;
      enemyIndex = activeEnemy;

      while (myActive.isNotEmpty && enemyActive.isNotEmpty) {
        TeamMember myPoke = myActive.first;
        TeamMember enemyPoke = enemyActive.first;

        bool myWin = _pokemonBattle(myPoke, enemyPoke, rng);

        if (myWin) {
          enemyActive.removeAt(0);

          if (enemyIndex < enemyQueue.length) {
            enemyActive.add(enemyQueue[enemyIndex]);
            enemyIndex++;
          }
        } else {
          myActive.removeAt(0);

          if (myIndex < myQueue.length) {
            myActive.add(myQueue[myIndex]);
            myIndex++;
          }
        }
      }

      if (myActive.isNotEmpty) myWins++;
    }

    double winRate = (myWins / totalBattles) * 100;

    setState(() {
      _isSimulating = false;
      _resultText =
          "Your Win Probability: ${winRate.toStringAsFixed(1)}% ($myWins / $totalBattles)";
      _logs.add(
          "Simulated $totalBattles ${_battleSize}v$_battleSize battles. Win Rate: ${winRate.toStringAsFixed(1)}%");
    });
  }

  @override
  Widget build(BuildContext context) {
    final teamProv = Provider.of<TeamProvider>(context);

    // Filtered 'valid' lists for quick logic, but UI uses full 6 slots

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
          title: const Text("Battle Simulator"),
          backgroundColor: Colors.transparent,
          elevation: 0),
      body: Column(
        children: [
          // My Team Preview (ReadOnly)
          Container(
            height: 80,
            color: const Color(0xFF222222),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Text("YOU:",
                    style: TextStyle(
                        color: Colors.cyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: teamProv.teamA.map((m) {
                      return Container(
                        width: 60,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: Colors.cyan.withOpacity(0.3))),
                        child: m == null
                            ? const Icon(Icons.add, color: Colors.grey)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset("assets/${m.pokemon.imagePath}",
                                      height: 40,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.error)),
                                  Text(m.pokemon.name,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          overflow: TextOverflow.ellipsis,
                                          color: Colors.white))
                                ],
                              ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),

          // Enemy Team Editor
          Container(
            color: const Color(0xFF2B2B2B),
            padding: const EdgeInsets.all(10),
            child: const Center(
                child: Text("ENEMY TEAM (Configure Below)",
                    style: TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.bold))),
          ),

          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isMobile = constraints.maxWidth < 850;
                  if (isMobile) {
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: 6,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        return SizedBox(
                          height: teamProv.teamB[i] == null ? 200 : 500,
                          child: TeamSlotCard(
                            index: i,
                            member: teamProv.teamB[i],
                            onSelect: () => _openEnemySelection(context, i),
                            onRemove: () =>
                                teamProv.clearSlot(i, isTeamB: true),
                            onAbilityChanged: (val) =>
                                teamProv.updateAbility(i, val, isTeamB: true),
                            onMoveChanged: (mIdx, val) => teamProv
                                .updateMove(i, mIdx, val, isTeamB: true),
                            onLevelChanged: (lvl) =>
                                teamProv.updateLevel(i, lvl, isTeamB: true),
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
                            member: teamProv.teamB[i],
                            onSelect: () => _openEnemySelection(context, i),
                            onRemove: () =>
                                teamProv.clearSlot(i, isTeamB: true),
                            onAbilityChanged: (val) =>
                                teamProv.updateAbility(i, val, isTeamB: true),
                            onMoveChanged: (mIdx, val) => teamProv
                                .updateMove(i, mIdx, val, isTeamB: true),
                            onLevelChanged: (lvl) =>
                                teamProv.updateLevel(i, lvl, isTeamB: true),
                          ),
                        );
                      }),
                    );
                  }
                },
              ),
            ),
          ),

          // Simulation Controls
          Expanded(
            flex: 1,
            child: Container(
              color: const Color(0xFF111111),
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Battle Size:",
                          style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 20),
                      _modeBtn(1),
                      _modeBtn(2),
                      _modeBtn(3),
                    ],
                  ),
                  Text(_resultText,
                      style: TextStyle(
                          color: _resultText.contains("Probability")
                              ? (double.parse(_resultText
                                          .split(": ")[1]
                                          .split("%")[0]) >
                                      80
                                  ? Colors.green
                                  : (double.parse(_resultText
                                              .split(": ")[1]
                                              .split("%")[0]) <
                                          35
                                      ? Colors.red
                                      : Colors.orange))
                              : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  // PokeBall Button
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: _isSimulating
                            ? null
                            : () => _runProbabilitySimulation(context),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: _isSimulating ||
                                          _resultText.contains("Probability")
                                      ? Colors.cyanAccent.withOpacity(0.8)
                                      : Colors.transparent,
                                  blurRadius: 20,
                                  spreadRadius: 5)
                            ],
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.red, Colors.white],
                              stops: [0.5, 0.5],
                            ),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Black Line
                              Container(
                                  width: 80, height: 8, color: Colors.black),
                              // Center Button
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.black, width: 2),
                                ),
                                child: _isSimulating
                                    ? const Padding(
                                        padding: EdgeInsets.all(4),
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : null,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _modeBtn(int size) {
    bool active = _battleSize == size;
    return GestureDetector(
      onTap: () => setState(() => _battleSize = size),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
            color: active ? Colors.cyan : Colors.transparent,
            border: Border.all(color: Colors.cyan),
            borderRadius: BorderRadius.circular(5)),
        child: Text("${size}v$size",
            style: TextStyle(
                color: active ? Colors.black : Colors.cyan,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _openEnemySelection(BuildContext context, int index) {
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
            .setPokemon(index, selectedPokemon, isTeamB: true);
      }
    });
  }
}
