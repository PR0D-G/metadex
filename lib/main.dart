import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/data_provider.dart';
import 'providers/team_provider.dart';
import 'screens/pokedex_screen.dart';
import 'screens/team_builder_screen.dart';
import 'screens/simulation_screen.dart';
import 'screens/library_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/game_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        // Add Simulator provider later
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MetaDéx',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor:
            Colors.transparent, // Allow gradient to show through
        primaryColor: const Color(0xFFE3350D),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFE3350D),
          secondary: Colors.amber,
          surface: const Color(0xFF2B2B2B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // Transparent AppBars
          elevation: 0,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _idx = 0;

  final List<Widget> _pages = [
    const PokedexScreen(),
    const TeamBuilderScreen(),
    const SimulationScreen(),
    const LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: GameTheme.appBackgroundDecoration,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _pages[_idx],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF141028),
          selectedItemColor: GameTheme.gold,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          currentIndex: _idx,
          onTap: (i) => setState(() => _idx = i),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.grid_view), label: "Pokedex"),
            BottomNavigationBarItem(
                icon: Icon(Icons.group_work), label: "Team Builder"),
            BottomNavigationBarItem(
                icon: Icon(Icons.flash_on), label: "Simulator"),
            BottomNavigationBarItem(
                icon: Icon(Icons.menu_book), label: "Library"),
          ],
        ),
      ),
    );
  }
}
