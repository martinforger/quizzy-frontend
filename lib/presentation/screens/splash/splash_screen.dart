import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.nextScreen});

  final Widget nextScreen;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Peque?o retardo para mostrar el splash antes de navegar.
    Timer(const Duration(milliseconds: 2000), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => widget.nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEBD7),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Logo Central
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo.png', width: 180, height: 180),
                const SizedBox(height: 16),
                const Text(
                  'QUIZZY',
                  style: TextStyle(
                    color: Color(0xFFFF7A00),
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/images/naranja.svg',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'NARANJA',
                    style: TextStyle(
                      color: Color(0xFFFF7A00),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Text(
                    'STUDIOS',
                    style: TextStyle(
                      color: Color(0xFF2B3630),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
