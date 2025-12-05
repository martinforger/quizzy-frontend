import 'package:flutter/material.dart';
import 'package:quizzy/presentation/screens/discover/discover_screen.dart';
import 'package:quizzy/presentation/screens/join/join_screen.dart';
import 'package:quizzy/presentation/screens/library/library_screen.dart';
import 'package:quizzy/presentation/screens/home/home_screen.dart';
import 'package:quizzy/presentation/screens/kahoots/slides_manager_screen.dart';
import 'package:quizzy/presentation/state/discovery_controller.dart';
import 'package:quizzy/presentation/state/slide_controller.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';

import 'package:quizzy/application/solo-game/useCases/start_attempt_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/submit_answer_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/get_summary_use_case.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({
    super.key,
    required this.discoveryController,
    required this.startAttemptUseCase,
    required this.submitAnswerUseCase,
    required this.getSummaryUseCase,
    required this.slideController,
  });

  final DiscoveryController discoveryController;
  final StartAttemptUseCase startAttemptUseCase;
  final SubmitAnswerUseCase submitAnswerUseCase;
  final GetSummaryUseCase getSummaryUseCase;
  final SlideController slideController;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeScreen(),
      DiscoverScreen(
        controller: widget.discoveryController,
        startAttemptUseCase: widget.startAttemptUseCase,
        submitAnswerUseCase: widget.submitAnswerUseCase,
        getSummaryUseCase: widget.getSummaryUseCase,
      ),
      LibraryScreen(
        startAttemptUseCase: widget.startAttemptUseCase,
        submitAnswerUseCase: widget.submitAnswerUseCase,
        getSummaryUseCase: widget.getSummaryUseCase,
      ),
      const JoinScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[_currentIndex],
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BottomAppBar(
              color: Colors.transparent,
              elevation: 0,
              shape: const CircularNotchedRectangle(),
              notchMargin: 10,
              child: Container(
                height: 78,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B21), // Dark card color
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  unselectedItemColor: Colors.white70,
                  type: BottomNavigationBarType.fixed,
                  selectedFontSize: 12,
                  unselectedFontSize: 11,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_rounded),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.explore_rounded),
                      label: 'Discover',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.bookmarks_rounded),
                      label: 'Library',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.qr_code_rounded),
                      label: 'Join',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreatePressed,
        elevation: 4,
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }

  // Accion temporal para el boton central.
  void _onCreatePressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SlidesManagerScreen(
          slideController: widget.slideController,
          initialKahootId: 'q4',
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
