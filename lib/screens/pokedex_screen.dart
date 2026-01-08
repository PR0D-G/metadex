import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/pokemon.dart';
import '../widgets/pokemon_card.dart';
import '../utils/game_theme.dart';
import 'detail_screen.dart';

class PokedexScreen extends StatelessWidget {
  const PokedexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DataProvider>(context);

    // Limit display for performance in GridView just in case, but Flutter is good with huge lists.
    // However, loading 1000 images might stutter. `GridView.builder` is efficient.

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: GameTheme.parchmentDecoration,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                style: const TextStyle(
                    color: GameTheme.parchmentText,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif'),
                decoration: const InputDecoration(
                  hintText: "Search Pokemon...",
                  hintStyle: TextStyle(color: Colors.black45),
                  prefixIcon:
                      Icon(Icons.search, color: GameTheme.parchmentText),
                  border: InputBorder.none,
                ),
                onChanged: (val) => provider.search(val),
              ),
            ),
          ),

          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(builder: (context, constraints) {
                    // Responsive Grid: 5 columns on wide screens (Chrome), 2 on mobile
                    int columns = 2;
                    if (constraints.maxWidth > 600) columns = 3;
                    if (constraints.maxWidth > 900) columns = 5;

                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: provider.pokemonList.length,
                      itemBuilder: (context, index) {
                        final poke = provider.pokemonList[index];
                        return PokemonCard(
                          pokemon: poke,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        DetailScreen(pokemon: poke)));
                          },
                        );
                      },
                    );
                  }),
          ),
        ],
      ),
    );
  }
}
