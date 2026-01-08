import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/pokemon.dart';
import '../widgets/pokemon_card.dart';

class PokemonSelector extends StatefulWidget {
  const PokemonSelector({super.key});

  @override
  State<PokemonSelector> createState() => _PokemonSelectorState();
}

class _PokemonSelectorState extends State<PokemonSelector> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DataProvider>(context, listen: false);

    // Efficient local filtering
    List<Pokemon> all = provider.allPokemon;
    List<Pokemon> filtered = query.isEmpty
        ? all
        : all.where((p) => p.name.toLowerCase().contains(query)).toList();

    // Limit to 50 for rendering performance if query is empty
    // so we don't render 1000 cards on init
    if (query.isEmpty && filtered.length > 50) {
      filtered = filtered.sublist(0, 50);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Text("Select Pokemon",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search...",
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF2B2B2B),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (val) {
              setState(() => query = val.toLowerCase());
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              itemCount: filtered.length,
              itemBuilder: (c, i) {
                final p = filtered[i];
                return PokemonCard(
                  pokemon: p,
                  onTap: () => Navigator.pop(context, p),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
