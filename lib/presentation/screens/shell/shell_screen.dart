import 'package:flutter/material.dart';
import 'package:quizzy/application/solo-game/useCases/get_attempt_state_use_case.dart';
import 'package:quizzy/presentation/screens/discover/discover_screen.dart';
import 'package:quizzy/presentation/screens/join/join_screen.dart';
import 'package:quizzy/presentation/screens/library/library_screen.dart';
import 'package:quizzy/presentation/screens/home/home_screen.dart';
import 'package:quizzy/presentation/state/auth_controller.dart';
import 'package:quizzy/presentation/state/discovery_controller.dart';
import 'package:quizzy/presentation/state/kahoot_controller.dart';
import 'package:quizzy/presentation/bloc/library/library_cubit.dart';
import 'package:quizzy/presentation/state/profile_controller.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';
import 'package:quizzy/presentation/screens/kahoots/kahoot_editor_screen.dart';
import 'package:quizzy/presentation/screens/profile/profile_screen.dart';

import 'package:quizzy/application/solo-game/useCases/start_attempt_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/submit_answer_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/get_summary_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/manage_local_attempt_use_case.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({
    super.key,
    required this.discoveryController,
    required this.startAttemptUseCase,
    required this.submitAnswerUseCase,
    required this.getSummaryUseCase,
    required this.manageLocalAttemptUseCase,
    required this.getAttemptStateUseCase,
    required this.kahootController,
    required this.libraryCubit,
    required this.profileController,
    required this.authController,
    required this.defaultKahootAuthorId,
    required this.defaultKahootThemeId,
    required this.onLogout,
  });

  final DiscoveryController discoveryController;
  final StartAttemptUseCase startAttemptUseCase;
  final SubmitAnswerUseCase submitAnswerUseCase;
  final GetSummaryUseCase getSummaryUseCase;
  final ManageLocalAttemptUseCase manageLocalAttemptUseCase;
  final GetAttemptStateUseCase getAttemptStateUseCase;
  final KahootController kahootController;
  final LibraryCubit libraryCubit;
  final ProfileController profileController;
  final AuthController authController;
  final String defaultKahootAuthorId;
  final String defaultKahootThemeId;
  final VoidCallback onLogout;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        profileController: widget.profileController,
        authController: widget.authController,
        onLogout: widget.onLogout,
      ),
      DiscoverScreen(
        controller: widget.discoveryController,
        startAttemptUseCase: widget.startAttemptUseCase,
        submitAnswerUseCase: widget.submitAnswerUseCase,
        getSummaryUseCase: widget.getSummaryUseCase,
        manageLocalAttemptUseCase: widget.manageLocalAttemptUseCase,
        getAttemptStateUseCase: widget.getAttemptStateUseCase,
      ),
      LibraryScreen(
        startAttemptUseCase: widget.startAttemptUseCase,
        submitAnswerUseCase: widget.submitAnswerUseCase,
        getSummaryUseCase: widget.getSummaryUseCase,
        manageLocalAttemptUseCase: widget.manageLocalAttemptUseCase,
        getAttemptStateUseCase: widget.getAttemptStateUseCase,
        libraryCubit: widget.libraryCubit,
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
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(14, 63, 126, 0.04),
                      blurRadius: 0,
                      spreadRadius: 1,
                      offset: Offset(0, 0),
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(42, 51, 69, 0.04),
                      blurRadius: 1,
                      spreadRadius: -0.5,
                      offset: Offset(0, 1),
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(42, 51, 70, 0.04),
                      blurRadius: 3,
                      spreadRadius: -1.5,
                      offset: Offset(0, 3),
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(42, 51, 70, 0.04),
                      blurRadius: 6,
                      spreadRadius: -3,
                      offset: Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(14, 63, 126, 0.04),
                      blurRadius: 12,
                      spreadRadius: -6,
                      offset: Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(14, 63, 126, 0.04),
                      blurRadius: 24,
                      spreadRadius: -12,
                      offset: Offset(0, 24),
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
                      label: 'Inicio',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.explore_rounded),
                      label: 'Descubrir',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.bookmarks_rounded),
                      label: 'Catálogo',
                    ),

                    BottomNavigationBarItem(
                      icon: Icon(Icons.qr_code_rounded),
                      label: 'Unirse',
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
        builder: (_) => KahootEditorScreen(
          kahootController: widget.kahootController,
          defaultAuthorId: widget.defaultKahootAuthorId,
          defaultThemeId: widget.defaultKahootThemeId,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}
