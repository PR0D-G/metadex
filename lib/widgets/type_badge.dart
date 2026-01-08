import 'package:flutter/material.dart';
import '../models/pokemon.dart';

class TypeBadge extends StatelessWidget {
  final String type;
  final bool small;

  const TypeBadge({super.key, required this.type, this.small = false});

  Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return const Color(0xFFA8A77A);
      case 'fire':
        return const Color(0xFFEE8130);
      case 'water':
        return const Color(0xFF6390F0);
      case 'electric':
        return const Color(0xFFF7D02C);
      case 'grass':
        return const Color(0xFF7AC74C);
      case 'ice':
        return const Color(0xFF96D9D6);
      case 'fighting':
        return const Color(0xFFC22E28);
      case 'poison':
        return const Color(0xFFA33EA1);
      case 'ground':
        return const Color(0xFFE2BF65);
      case 'flying':
        return const Color(0xFFA98FF3);
      case 'psychic':
        return const Color(0xFFF95587);
      case 'bug':
        return const Color(0xFFA6B91A);
      case 'rock':
        return const Color(0xFFB6A136);
      case 'ghost':
        return const Color(0xFF735797);
      case 'dragon':
        return const Color(0xFF6F35FC);
      case 'steel':
        return const Color(0xFFB7B7CE);
      case 'dark':
        return const Color(0xFF705746);
      case 'fairy':
        return const Color(0xFFD685AD);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.0),
      padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 10, vertical: small ? 2 : 4),
      decoration: BoxDecoration(
        color: getTypeColor(type),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: small ? 10 : 12,
        ),
      ),
    );
  }
}
