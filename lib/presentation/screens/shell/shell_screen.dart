import 'package:flutter/material.dart';
import 'package:quizzy/presentation/screens/discover/discover_screen.dart';
import 'package:quizzy/presentation/screens/join/join_screen.dart';
import 'package:quizzy/presentation/screens/library/library_screen.dart';
import 'package:quizzy/presentation/state/discovery_controller.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, required this.discoveryController});

  final DiscoveryController discoveryController;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _PlaceholderScreen(title: 'Inicio (Proximamente)'),
      DiscoverScreen(controller: widget.discoveryController),
      const LibraryScreen(),
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
            borderRadius: BorderRadius.circular(AppRadii.card),
            child: BottomAppBar(
              color: Colors.transparent,
              elevation: 0,
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 18,
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
                    BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
                    BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: 'Discover'),
                    BottomNavigationBarItem(icon: Icon(Icons.bookmarks_rounded), label: 'Library'),
                    BottomNavigationBarItem(icon: Icon(Icons.qr_code_rounded), label: 'Join'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.small(
        onPressed: _onCreatePressed,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  // Accion temporal para el boton central.
  void _onCreatePressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Crear Quiz - proximamente')),
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
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
