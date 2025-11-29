import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quizzy/presentation/widgets/quizzy_logo.dart';

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
    Timer(const Duration(milliseconds: 1200), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => widget.nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEBD7),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            SizedBox(height: 32),
            QuizzyLogo(size: 180, showName: true),
            Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: _LoadingDots(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _Dot(color: Color(0xFFFF7A00)),
            SizedBox(width: 10),
            _Dot(color: Color(0xFF1DD8D2)),
            SizedBox(width: 10),
            _Dot(color: Color(0xFF2BCB5E)),
            SizedBox(width: 10),
            _Dot(color: Color(0xFFFF3B30)),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Loading...',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
