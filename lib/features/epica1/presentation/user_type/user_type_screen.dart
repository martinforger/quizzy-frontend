import 'package:flutter/material.dart';

class UserTypeScreen extends StatelessWidget {
  final void Function(String userType) onSelectUserType;

  const UserTypeScreen({super.key, required this.onSelectUserType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 900),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        // Header
                        const SizedBox(height: 16),
                        const Text(
                          '¡Bienvenido a Quizzy!',
                          style: TextStyle(color: Colors.white, fontSize: 32),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '¿Cómo te gustaría usar Quizzy?',
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // User Type Cards
                        LayoutBuilder(
                          builder: (context, constraints) {
                            bool isWide = constraints.maxWidth > 600;
                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildUserTypeCard(
                                  context,
                                  title: 'Estudiante',
                                  description: 'Participa en quizzes, aprende y compite con tus amigos',
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  icon: Icons.school,
                                  onTap: () => onSelectUserType('student'),
                                  width: isWide ? (constraints.maxWidth - 32) / 2 : constraints.maxWidth,
                                ),
                                _buildUserTypeCard(
                                  context,
                                  title: 'Profesor',
                                  description: 'Crea quizzes, gestiona clases y evalúa el progreso',
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFB923C), Color(0xFFF59E0B)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  icon: Icons.menu_book,
                                  onTap: () => onSelectUserType('teacher'),
                                  width: isWide ? (constraints.maxWidth - 32) / 2 : constraints.maxWidth,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(
    BuildContext context, {
    required String title,
    required String description,
    required LinearGradient gradient,
    required IconData icon,
    required VoidCallback onTap,
    required double width,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with gradient background
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Seleccionar',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
