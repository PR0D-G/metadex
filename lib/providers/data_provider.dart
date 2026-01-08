import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/pokemon.dart';

class DataProvider with ChangeNotifier {
  List<Pokemon> _allPokemon = [];
  List<Pokemon> _filteredPokemon = [];
  Map<String, dynamic> _moveData = {};
  Map<String, dynamic> _abilityData = {};

  bool _isLoading = true;
  String _searchQuery = "";

  bool get isLoading => _isLoading;
  List<Pokemon> get pokemonList => _filteredPokemon;
  List<Pokemon> get allPokemon => _allPokemon;
  Map<String, dynamic> get moveData => _moveData;
  Map<String, dynamic> get abilityData => _abilityData;

  DataProvider() {
    loadData();
  }

  Future<void> loadData() async {
    try {
      // Load Pokedata
      final String pokeString = await rootBundle.loadString(
        'assets/data/pokedata.json',
      );
      final List<dynamic> pokeJson = json.decode(pokeString);
      _allPokemon = pokeJson.map((e) => Pokemon.fromJson(e)).toList();
      _filteredPokemon = List.from(_allPokemon);

      // Load Moves
      final String moveString = await rootBundle.loadString(
        'assets/data/movedata.json',
      );
      _moveData = json.decode(moveString);

      // Load Abilities
      final String abString = await rootBundle.loadString(
        'assets/data/abilitydata.json',
      );
      _abilityData = json.decode(abString);
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query.toLowerCase();
    if (_searchQuery.isEmpty) {
      _filteredPokemon = List.from(_allPokemon);
    } else {
      _filteredPokemon = _allPokemon
          .where((p) => p.name.toLowerCase().contains(_searchQuery))
          .toList();
    }
    notifyListeners();
  }

  // Helper to fetch images
  // Since images are in assets/images/Name.png
  // But json says "images/Name.png". We need to adjust.
  String getAssetPath(String relativePath) {
    // Relative path from json is roughly "images/Bulbasaur.png"
    // Our assets are mapped to assets/images/...
    // If we just use 'assets/' + relativePath implies assets/images/Bulbasaur.png
    return 'assets/$relativePath';
  }
}
