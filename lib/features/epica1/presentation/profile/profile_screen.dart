import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback? onBack;

  const ProfileScreen({super.key, required this.onLogout, this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  bool showPasswordSection = false;

  String name = 'Juan Pérez';
  String email = 'juan.perez@email.com';
  String description = 'Educador apasionado por la tecnología';
  String userType = 'teacher'; // student o teacher
  String currentPassword = '';
  String newPassword = '';
  String confirmPassword = '';

  void handleSave() {
    setState(() {
      isEditing = false;
      showPasswordSection = false;
      currentPassword = '';
      newPassword = '';
      confirmPassword = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cambios guardados (simulado)')),
    );
  }

  void handleCancel() {
    setState(() {
      isEditing = false;
      showPasswordSection = false;
      name = 'Juan Pérez';
      email = 'juan.perez@email.com';
      description = 'Educador apasionado por la tecnología';
      userType = 'teacher';
      currentPassword = '';
      newPassword = '';
      confirmPassword = '';
    });
  }

  Widget buildInput({
    required String label,
    required IconData icon,
    required String value,
    required ValueChanged<String> onChanged,
    bool enabled = false,
    String? placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: TextEditingController(text: value),
          enabled: enabled,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            hintText: placeholder,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white10),
            ),
          ),
          style: TextStyle(color: enabled ? Colors.white : Colors.grey[400]),
        ),
      ],
    );
  }

  Widget buildPasswordField(String label, String value, ValueChanged<String> onChanged) {
    return buildInput(
      label: label,
      icon: Icons.lock,
      value: value,
      onChanged: onChanged,
      enabled: true,
      placeholder: '••••••••',
    );
  }

  Widget statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Color(0xFFFB923C), fontSize: 22)),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (widget.onBack != null)
                        GestureDetector(
                          onTap: widget.onBack,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: const Text(
                          'Configuración',
                          style: TextStyle(color: Colors.white, fontSize: 26),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

            // Main Card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title + Edit button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Mi Perfil',
                                style: TextStyle(color: Colors.white, fontSize: 26),
                              ),
                              if (!isEditing)
                                ElevatedButton.icon(
                                  onPressed: () => setState(() => isEditing = true),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Editar perfil'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFB923C),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Avatar
                          Center(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 110,
                                  height: 110,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFFB923C),
                                  ),
                                  child: const Icon(Icons.person, size: 56, color: Colors.white),
                                ),
                                if (isEditing)
                                  Positioned(
                                    bottom: 6,
                                    right: 6,
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2A2A2A),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: const Color(0xFFFB923C), width: 2),
                                        ),
                                        child: const Icon(Icons.edit, size: 16, color: Color(0xFFFB923C)),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Inputs
                          buildInput(
                            label: 'Nombre completo',
                            icon: Icons.person,
                            value: name,
                            onChanged: (v) => setState(() => name = v),
                            enabled: isEditing,
                          ),
                          const SizedBox(height: 16),

                          buildInput(
                            label: 'Correo electrónico',
                            icon: Icons.email,
                            value: email,
                            onChanged: (v) => setState(() => email = v),
                            enabled: isEditing,
                          ),
                          const SizedBox(height: 16),

                          // User Type
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tipo de usuario', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              const SizedBox(height: 6),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      userType == 'student' ? Icons.school : Icons.menu_book,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: userType,
                                          isExpanded: true,
                                          dropdownColor: const Color(0xFF2A2A2A),
                                          items: const [
                                            DropdownMenuItem(
                                                value: 'student',
                                                child: Text('Estudiante', style: TextStyle(color: Colors.white))),
                                            DropdownMenuItem(
                                                value: 'teacher',
                                                child: Text('Docente', style: TextStyle(color: Colors.white))),
                                          ],
                                          onChanged: isEditing
                                              ? (v) {
                                                  if (v != null) setState(() => userType = v);
                                                }
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          buildInput(
                            label: 'Descripción',
                            icon: Icons.description,
                            value: description,
                            onChanged: (v) => setState(() => description = v),
                            enabled: isEditing,
                          ),

                          const SizedBox(height: 18),

                          // Change Password Section
                          if (isEditing) ...[
                            TextButton(
                              onPressed: () => setState(() => showPasswordSection = !showPasswordSection),
                              child: Text(
                                showPasswordSection ? 'Ocultar' : 'Cambiar contraseña',
                                style: const TextStyle(color: Color(0xFFFB923C)),
                              ),
                            ),
                            if (showPasswordSection) ...[
                              const SizedBox(height: 8),
                              buildPasswordField('Contraseña actual', currentPassword, (v) => setState(() => currentPassword = v)),
                              const SizedBox(height: 12),
                              buildPasswordField('Nueva contraseña', newPassword, (v) => setState(() => newPassword = v)),
                              const SizedBox(height: 12),
                              buildPasswordField('Confirmar nueva contraseña', confirmPassword, (v) => setState(() => confirmPassword = v)),
                            ]
                          ],

                          // Action Buttons
                          if (isEditing)
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: handleCancel,
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    label: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: handleSave,
                                    icon: const Icon(Icons.save, size: 18),
                                    label: const Text('Guardar cambios'),
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFB923C)),
                                  ),
                                ),
                              ],
                            ),

                          // Stats
                          if (!isEditing) ...[
                            const SizedBox(height: 20),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 16),
                            const Text('Estadísticas', style: TextStyle(color: Colors.white, fontSize: 18)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                statCard('12', 'Quizzes creados'),
                                const SizedBox(width: 12),
                                statCard('45', 'Partidas jugadas'),
                                const SizedBox(width: 12),
                                statCard('87%', 'Precisión'),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Cerrar sesión'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    elevation: 2,
                    foregroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
