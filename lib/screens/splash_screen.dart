import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pokemon/main.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 3 Second animation
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Animate from 1.0 (right) to -1.0 (left)
    _animation = Tween<double>(begin: 1.2, end: -1.2).animate(_controller);

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222224), // Dark Background
      body: Stack(
        children: [
          // Background pattern or branding (optional)
          Center(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/images/Pikachu.png',
                  width: 300, color: Colors.white),
            ),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Horizontal movement
                double xPos =
                    MediaQuery.of(context).size.width * _animation.value / 2;

                // Bobbing vertically to simulate running steps
                double yPos =
                    (math.sin(_controller.value * 20 * math.pi) * 10).abs() -
                        50;
                // * 20 * pi -> 10 bounces in 3 seconds.

                return Transform.translate(
                  offset: Offset(xPos, yPos),
                  child: child,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/Pikachu.png',
                    height: 120,
                  ),
                  const SizedBox(height: 10),
                  // Shadow
                  Container(
                    width: 60,
                    height: 10,
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10)),
                  )
                ],
              ),
            ),
          ),

          // Loading Text
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Loading World...",
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    fontStyle: FontStyle.italic),
              ),
            ),
          )
        ],
      ),
    );
  }
}
