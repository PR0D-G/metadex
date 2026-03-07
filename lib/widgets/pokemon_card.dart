import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../utils/game_theme.dart';
// import '../utils/type_chart.dart'; // Removed unused import

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback onTap;

  const PokemonCard({super.key, required this.pokemon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: GameTheme.goldBorderDecoration,
        child: Stack(
          children: [
            // Background Glow (Optional)
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white.withOpacity(0.2), Colors.transparent],
                  ),
                ),
              ),
            ),

            // Image
            Positioned.fill(
              bottom: 30, // Leave room for name
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: pokemon.imagePath.isNotEmpty
                    ? Image.network(
                        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon.id}.png",
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.broken_image, color: Colors.grey))
                    : const Icon(Icons.image_not_supported,
                        size: 50, color: Colors.grey),
              ),
            ),

            // Type Icons (Top Corners)
            if (pokemon.types.isNotEmpty)
              Positioned(
                top: 8,
                right: 8,
                child: _buildTypeIcon(pokemon.types.first),
              ),
            if (pokemon.types.length > 1)
              Positioned(
                top: 8,
                left: 8,
                child: _buildTypeIcon(pokemon.types[1]),
              ),

            // Name Banner
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 30,
                decoration: const BoxDecoration(
                  gradient: GameTheme.goldGradient,
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(
                          9)), // Match border radius minus border width roughly
                ),
                alignment: Alignment.center,
                child: Text(
                  pokemon.name,
                  style: const TextStyle(
                      color: Color(0xFF3E362A),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'serif'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon(String type) {
    // Simple circle with type letter or icon
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
        border: Border.all(color: GameTheme.gold, width: 1),
      ),
      child: Center(
        child: Text(
          type.substring(0, 1).toUpperCase(),
          style: TextStyle(
              color: _getTypeColor(type),
              fontSize: 12,
              fontWeight: FontWeight.bold),
        ),
      ),
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
        return Colors.grey;
    }
  }
}
