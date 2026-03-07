import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/pokemon.dart';
import '../widgets/type_badge.dart';

class DetailScreen extends StatelessWidget {
  final Pokemon pokemon;

  const DetailScreen({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DataProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(pokemon.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image
            Center(
              child: SizedBox(
                height: 250,
                width: 250,
                child: pokemon.imagePath.isNotEmpty
                    ? Image.network(
                        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon.id}.png",
                        fit: BoxFit.contain)
                    : const Icon(Icons.image_not_supported,
                        size: 100, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // Name ID
            Text(
              "#${pokemon.id} ${pokemon.name.toUpperCase()}",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Types
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: pokemon.types.map((t) => TypeBadge(type: t)).toList(),
            ),
            const SizedBox(height: 20),

            // Stats Section
            _buildStatsSection(),

            const SizedBox(height: 20),

            // Abilities
            _buildBox("Abilities", pokemon.abilities.join(", ")),

            const SizedBox(height: 20),

            // Evolution Chain
            if (pokemon.evolution.isNotEmpty)
              _buildEvolutionSection(provider, pokemon.evolution),

            if (pokemon.evolution.isNotEmpty) const SizedBox(height: 20),

            // Moves List
            _buildMovesSection(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    // Define exact order and labels for Cobblemon/Resepected Format
    final statOrder = [
      {'key': 'hp', 'label': 'HP'},
      {'key': 'attack', 'label': 'Atk'},
      {'key': 'defense', 'label': 'Def'},
      {'key': 'special-attack', 'label': 'SpA'},
      {'key': 'special-defense', 'label': 'SpD'},
      {'key': 'speed', 'label': 'Spe'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Base Stats",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...statOrder.map((s) {
            int value = pokemon.stats[s['key']] ?? 0;
            return _buildStatRow(s['label']!, value);
          }).toList(),
          const Divider(color: Colors.grey),
          _buildStatRow("Total", pokemon.stats.values.fold(0, (a, b) => a + b),
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value, {bool isTotal = false}) {
    Color color = Colors.orange;
    if (value >= 100) color = Colors.green;
    if (value >= 130) color = Colors.cyan;
    if (isTotal) color = Colors.purple;

    // Normalize for bar (max 255 usually)
    double percent = value / 255.0;
    if (isTotal) percent = value / 780.0; // Max BST approx

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label.toUpperCase(),
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            width: 40,
            child: Text("$value",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey.shade800,
                color: color,
                minHeight: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBox(String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(content,
              style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEvolutionSection(DataProvider provider, String evolutionChain) {
    List<String> stages =
        evolutionChain.split('->').map((e) => e.trim()).toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Evolution Chain",
              style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: stages.asMap().entries.map((entry) {
                int index = entry.key;
                String name = entry.value;
                bool isLast = index == stages.length - 1;

                // Find pokemon data for image
                final member = provider.allPokemon.firstWhere(
                  (p) => p.name.toLowerCase() == name.toLowerCase(),
                  orElse: () => Pokemon(
                      id: -1,
                      name: name,
                      types: [],
                      stats: {},
                      abilities: [],
                      moves: [],
                      evolution: '',
                      imagePath: ''),
                );

                bool isCurrent =
                    name.toLowerCase() == pokemon.name.toLowerCase();

                return Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          decoration: isCurrent
                              ? BoxDecoration(
                                  border: Border.all(
                                      color: Colors.cyanAccent, width: 2),
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                      BoxShadow(
                                          color: Colors.cyan.withOpacity(0.4),
                                          blurRadius: 10)
                                    ])
                              : null,
                          child: SizedBox(
                            height: 80,
                            width: 80,
                            child:
                                member.id != -1 && member.imagePath.isNotEmpty
                                    ? Image.network(
                                        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${member.id}.png",
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.help_outline,
                                                color: Colors.grey),
                                      )
                                    : const Icon(Icons.help_outline,
                                        color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(name,
                            style: TextStyle(
                                color: isCurrent
                                    ? Colors.cyanAccent
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ],
                    ),
                    if (!isLast)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(Icons.arrow_forward, color: Colors.grey),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovesSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Move Pool",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          pokemon.moves.isEmpty
              ? const Text("No moves data available.",
                  style: TextStyle(color: Colors.grey))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: pokemon.moves.map((move) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(move,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
