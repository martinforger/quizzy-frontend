import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onAnimationComplete});

  final VoidCallback onAnimationComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for animation + some delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onAnimationComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            )
                .animate()
                .scale(duration: 800.ms, curve: Curves.elasticOut)
                .then(delay: 200.ms)
                .shimmer(duration: 1200.ms, color: Colors.orange.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
