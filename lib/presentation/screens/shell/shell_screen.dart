import 'package:flutter/material.dart';
import 'package:quizzy/presentation/screens/discover/discover_screen.dart';
import 'package:quizzy/presentation/screens/join/join_screen.dart';
import 'package:quizzy/presentation/screens/library/library_screen.dart';
import 'package:quizzy/presentation/state/discovery_controller.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, required this.discoveryController});

  final DiscoveryController discoveryController;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _PlaceholderScreen(title: 'Home (Pr?ximamente)'),
      DiscoverScreen(controller: widget.discoveryController),
      const LibraryScreen(),
      const JoinScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1E1B21),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.white70,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Library'),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_2), label: 'Join'),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreatePressed,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  // Acci?n temporal para el bot?n central.
  void _onCreatePressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Crear Quiz - pr?ximamente')),
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
