import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback? onBack;

  const ProfilePage({
    super.key,
    required this.onLogout,
    this.onBack,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool showPasswordSection = false;

  final nameController = TextEditingController(text: "Juan Pérez");
  final emailController = TextEditingController(text: "juan.perez@email.com");

  final currentPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

  void handleSave() {
    setState(() {
      isEditing = false;
      showPasswordSection = false;
      currentPassController.clear();
      newPassController.clear();
      confirmPassController.clear();
    });
  }

  void handleCancel() {
    setState(() {
      isEditing = false;
      showPasswordSection = false;
      nameController.text = "Juan Pérez";
      emailController.text = "juan.perez@email.com";
      currentPassController.clear();
      newPassController.clear();
      confirmPassController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFfb923c);
    const bgDark = Color(0xFF1a1a1a);
    const cardDark = Color(0xFF2a2a2a);

    return Scaffold(
      backgroundColor: bgDark,
      body: Column(
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (widget.onBack != null)
                      GestureDetector(
                        onTap: widget.onBack,
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                    const SizedBox(width: 10),
                    Image.asset("assets/logo.png", width: 120),
                  ],
                ),
                GestureDetector(
                  onTap: widget.onLogout,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: cardDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.logout, color: Colors.grey, size: 20),
                        SizedBox(width: 6),
                        Text("Cerrar sesión", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // CONTENIDO PRINCIPAL
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Center(
                child: Container(
                  width: 600,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER DEL CARD
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Mi Perfil",
                              style: TextStyle(color: Colors.white, fontSize: 28)),
                          if (!isEditing)
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() => isEditing = true);
                              },
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text("Editar perfil"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )
                          else
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: handleCancel,
                                  icon: const Icon(Icons.close, color: Colors.grey),
                                  label: const Text("Cancelar",
                                      style: TextStyle(color: Colors.grey)),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: handleSave,
                                  icon: const Icon(Icons.save, size: 16),
                                  label: const Text("Guardar"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: orange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // AVATAR
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: orange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person,
                                  color: Colors.white, size: 60),
                            ),
                            if (isEditing)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: cardDark,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: orange, width: 2),
                                  ),
                                  child: const Icon(Icons.edit, color: orange, size: 20),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // INPUTS
                      _inputField(
                        label: "Nombre completo",
                        controller: nameController,
                        icon: Icons.person,
                        enabled: isEditing,
                      ),
                      const SizedBox(height: 20),

                      _inputField(
                        label: "Correo electrónico",
                        controller: emailController,
                        icon: Icons.email,
                        enabled: isEditing,
                      ),

                      // CAMBIAR CONTRASEÑA
                      if (isEditing) ...[
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showPasswordSection = !showPasswordSection;
                            });
                          },
                          child: Text(
                            showPasswordSection
                                ? "Ocultar"
                                : "Cambiar contraseña",
                            style: const TextStyle(
                                color: orange, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],

                      if (showPasswordSection && isEditing) ...[
                        const Divider(color: Colors.white24, height: 30),

                        _inputField(
                          label: "Contraseña actual",
                          controller: currentPassController,
                          icon: Icons.lock,
                          enabled: true,
                          obscure: true,
                        ),
                        const SizedBox(height: 20),

                        _inputField(
                          label: "Nueva contraseña",
                          controller: newPassController,
                          icon: Icons.lock,
                          enabled: true,
                          obscure: true,
                        ),
                        const SizedBox(height: 20),

                        _inputField(
                          label: "Confirmar nueva contraseña",
                          controller: confirmPassController,
                          icon: Icons.lock,
                          enabled: true,
                          obscure: true,
                        ),
                      ],

                      // ESTADISTICAS
                      if (!isEditing) ...[
                        const SizedBox(height: 30),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 20),
                        const Text("Estadísticas",
                            style: TextStyle(color: Colors.white, fontSize: 20)),
                        const SizedBox(height: 15),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statCard("12", "Quizzes creados", orange),
                            _statCard("45", "Partidas jugadas", orange),
                            _statCard("87%", "Precisión", orange),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // FOOTER
          Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 10),
            child: Column(
              children: [
                Image.asset("assets/naranja_logo.png", width: 120),
                const SizedBox(height: 5),
                const Text(
                  "© 2025 Quizzy. Todos los derechos reservados.",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF1a1a1a),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFfb923c)),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 26)),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
