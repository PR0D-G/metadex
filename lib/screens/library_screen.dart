import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../utils/type_chart.dart';
import '../models/pokemon.dart';
import '../widgets/pokemon_card.dart';
import 'detail_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Ref. Library"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.cyan,
            labelColor: Colors.cyan,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Type Analysis"),
              Tab(text: "Move Search"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TypeAnalysisTab(),
            MoveSearchTab(),
          ],
        ),
      ),
    );
  }
}

class TypeAnalysisTab extends StatefulWidget {
  const TypeAnalysisTab({super.key});

  @override
  State<TypeAnalysisTab> createState() => _TypeAnalysisTabState();
}

class _TypeAnalysisTabState extends State<TypeAnalysisTab> {
  String _selectedType = "Fire";

  @override
  Widget build(BuildContext context) {
    final dataProv = Provider.of<DataProvider>(context);

    // 1. Calculate Effectiveness
    List<String> weakTo = [];
    List<String> resists = [];
    List<String> strongAgainst = [];

    TYPE_CHART.forEach((attacker, defenders) {
      if (defenders.containsKey(_selectedType)) {
        double mod = defenders[_selectedType]!;
        if (mod > 1.0) weakTo.add(attacker);
        if (mod < 1.0 && mod > 0.0) resists.add(attacker);
        if (mod == 0.0) resists.add("$attacker (Immune)");
      }
    });

    if (TYPE_CHART.containsKey(_selectedType)) {
      TYPE_CHART[_selectedType]!.forEach((defender, mod) {
        if (mod > 1.0) strongAgainst.add(defender);
      });
    }

    // 2. Filter Pokemon
    List<Pokemon> typePokemon = dataProv.allPokemon.where((p) {
      return p.types
          .any((t) => t.trim().toLowerCase() == _selectedType.toLowerCase());
    }).toList();

    return Column(
      children: [
        // Selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: const Color(0xFF222222),
          child: Row(
            children: [
              const Text("Select Type:",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(width: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: _getTypeColor(_selectedType).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _getTypeColor(_selectedType))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedType,
                      dropdownColor: const Color(0xFF333333),
                      icon: Icon(Icons.arrow_drop_down,
                          color: _getTypeColor(_selectedType)),
                      items: ALL_TYPES
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t,
                                    style: TextStyle(
                                        color: _getTypeColor(t),
                                        fontWeight: FontWeight.bold)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedType = val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              // Analysis Card
              Card(
                color: const Color(0xFF2B2B2B),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Effectiveness",
                          style: TextStyle(
                              color: _getTypeColor(_selectedType),
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const Divider(color: Colors.grey),
                      _buildEffectivenessRow(
                          "Weak To:", weakTo, Colors.redAccent),
                      const SizedBox(height: 10),
                      _buildEffectivenessRow(
                          "Resists:", resists, Colors.blueAccent),
                      const SizedBox(height: 10),
                      _buildEffectivenessRow(
                          "Strong Against:", strongAgainst, Colors.greenAccent),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Text("Pokemon (${typePokemon.length})",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Pokemon Grid
              LayoutBuilder(builder: (context, constraints) {
                int columns = 2;
                if (constraints.maxWidth > 600) columns = 3;
                if (constraints.maxWidth > 900) columns = 5;

                return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10),
                    itemCount: typePokemon.length,
                    itemBuilder: (ctx, i) {
                      final p = typePokemon[i];
                      return PokemonCard(
                        pokemon: p,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DetailScreen(pokemon: p)),
                          );
                        },
                      );
                    });
              })
            ],
          ),
        )
      ],
    );
  }

  Widget _buildEffectivenessRow(String label, List<String> types, Color color) {
    if (types.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: types
              .map((t) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: color.withOpacity(0.5))),
                    child:
                        Text(t, style: TextStyle(color: color, fontSize: 11)),
                  ))
              .toList(),
        )
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.orange;
      case 'ice':
        return Colors.cyanAccent;
      case 'fighting':
        return Colors.redAccent;
      case 'poison':
        return Colors.purple;
      case 'ground':
        return Colors.brown;
      case 'flying':
        return Colors.indigoAccent;
      case 'psychic':
        return Colors.pink;
      case 'bug':
        return Colors.lightGreen;
      case 'rock':
        return Colors.grey;
      case 'ghost':
        return Colors.indigo;
      case 'dragon':
        return Colors.deepPurple;
      case 'steel':
        return Colors.blueGrey;
      case 'fairy':
        return Colors.pinkAccent;
      default:
        return Colors.grey.shade700;
    }
  }
}

class MoveSearchTab extends StatefulWidget {
  const MoveSearchTab({super.key});

  @override
  State<MoveSearchTab> createState() => _MoveSearchTabState();
}

class _MoveSearchTabState extends State<MoveSearchTab> {
  String _selectedMove = "";

  @override
  Widget build(BuildContext context) {
    final dataProv = Provider.of<DataProvider>(context);
    final moves = dataProv.moveData;

    // Default to first move if empty
    if (_selectedMove.isEmpty && moves.isNotEmpty) {
      _selectedMove = moves.keys.first;
    }
    // Safety check if selection is invalid
    if (!moves.containsKey(_selectedMove) && moves.isNotEmpty) {
      _selectedMove = moves.keys.first;
    }

    if (moves.isEmpty) return const Center(child: CircularProgressIndicator());

    final moveData = moves[_selectedMove] ?? {};
    String moveType = moveData['type'] ?? "Normal";
    String category = moveData['category'] ?? "Physical";
    int power = moveData['power'] ?? 0;

    // Calculate Effectiveness (Offensive only)
    List<String> superEffective = [];
    List<String> notVeryEffective = [];
    List<String> noEffect = [];

    if (TYPE_CHART.containsKey(moveType)) {
      TYPE_CHART[moveType]!.forEach((defender, mod) {
        if (mod > 1.0) superEffective.add(defender);
        if (mod < 1.0 && mod > 0.0) notVeryEffective.add(defender);
        if (mod == 0.0) noEffect.add(defender);
      });
    }

    // Sort moves alphabetically
    final sortedMoves = moves.keys.toList()..sort();

    // Filter Learners
    final learners = dataProv.allPokemon
        .where((p) => p.moves.contains(_selectedMove))
        .toList();

    return Column(
      children: [
        // Selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: const Color(0xFF222222),
          child: Row(
            children: [
              const Text("Select Move:",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(width: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: _getTypeColor(moveType).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _getTypeColor(moveType))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: moves.containsKey(_selectedMove)
                          ? _selectedMove
                          : null,
                      dropdownColor: const Color(0xFF333333),
                      icon: Icon(Icons.arrow_drop_down,
                          color: _getTypeColor(moveType)),
                      isExpanded: true,
                      items: sortedMoves
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedMove = val);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Dashboard (Lazy Loaded with Slivers)
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      // Stats Card
                      Card(
                        color: const Color(0xFF2B2B2B),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text(_selectedMove,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: _getTypeColor(moveType),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Text(moveType,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Text("Power",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12)),
                                      const SizedBox(height: 5),
                                      Text("${power > 0 ? power : '-'}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text("Category",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12)),
                                      const SizedBox(height: 5),
                                      Text(category,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Effectiveness Card
                      Card(
                        color: const Color(0xFF2B2B2B),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Effectiveness (Attacking)",
                                  style: TextStyle(
                                      color: _getTypeColor(moveType),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const Divider(color: Colors.grey),
                              const SizedBox(height: 5),
                              _buildEffectivenessRow("Super Effective Against:",
                                  superEffective, Colors.greenAccent),
                              const SizedBox(height: 10),
                              _buildEffectivenessRow(
                                  "Not Very Effective Against:",
                                  notVeryEffective,
                                  Colors.orangeAccent),
                              const SizedBox(height: 10),
                              _buildEffectivenessRow(
                                  "No Effect Against:", noEffect, Colors.grey),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Text("Learned by ${learners.length} Pokemon:",
                          style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

              // Lazy Grid
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                sliver: SliverLayoutBuilder(builder: (context, constraints) {
                  int columns = 2;
                  if (constraints.crossAxisExtent > 600) columns = 3;
                  if (constraints.crossAxisExtent > 900) columns = 5;

                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final p = learners[index];
                        return PokemonCard(
                          pokemon: p,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => DetailScreen(pokemon: p)),
                            );
                          },
                        );
                      },
                      childCount: learners.length,
                    ),
                  );
                }),
              ),

              // Bottom Padding
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildEffectivenessRow(String label, List<String> types, Color color) {
    if (types.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: types
              .map((t) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: color.withOpacity(0.5))),
                    child:
                        Text(t, style: TextStyle(color: color, fontSize: 11)),
                  ))
              .toList(),
        )
      ],
    );
  }

  Color _getTypeColor(String type) {
    // Copy color logic or make it a shared util
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.red;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.orange;
      case 'ice':
        return Colors.cyanAccent;
      case 'fighting':
        return Colors.redAccent;
      case 'poison':
        return Colors.purple;
      case 'ground':
        return Colors.brown;
      case 'flying':
        return Colors.indigoAccent;
      case 'psychic':
        return Colors.pink;
      case 'bug':
        return Colors.lightGreen;
      case 'rock':
        return Colors.grey;
      case 'ghost':
        return Colors.indigo;
      case 'dragon':
        return Colors.deepPurple;
      case 'steel':
        return Colors.blueGrey;
      case 'fairy':
        return Colors.pinkAccent;
      default:
        return Colors.grey.shade700;
    }
  }
}
// Removed _PokemonLearnersList as it's integreated now
