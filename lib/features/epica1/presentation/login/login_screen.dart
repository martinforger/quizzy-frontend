import 'package:flutter/material.dart';
import '../signup/signup_screen.dart';
import '../profile/profile_screen.dart';


class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Campos del login
  String email = '';
  String password = '';
  bool showPassword = false;
  bool isSignUp = false;

  // Control del modal
  bool showForgotPassword = false;
  String recoveryEmail = '';
  bool emailSent = false;

  /// --------------------------------------------------------------
  /// Método que simula el login
  /// --------------------------------------------------------------
  void handleLogin() {
    // Call the provided onLogin hook (if any) and navigate to ProfileScreen
    widget.onLogin();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          initialUserType: 'student',
        ),
      ),
    );
  }

  /// --------------------------------------------------------------
  /// Enviar correo de recuperación (simulado)
  /// Muestra mensaje por 3 segundos y luego cierra el modal.
  /// --------------------------------------------------------------
  void handleForgotPassword() {
    setState(() {
      emailSent = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        showForgotPassword = false;
        emailSent = false;
        recoveryEmail = '';
      });
    });
  }

  /// --------------------------------------------------------------
  /// WIDGET del modal de recuperar contraseña
  /// (Tu modal original, pero reparado y documentado)
  /// --------------------------------------------------------------
  Widget buildForgotPasswordModal() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54, // Fondo oscuro
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white10),
            ),

            // Si ya enviaste el correo → aparece mensaje verde
            child: emailSent
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 60),
                      const SizedBox(height: 16),
                      const Text(
                        '¡Correo enviado!',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Revisa tu bandeja de entrada.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )

                // Si NO se ha enviado → formulario normal
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Recuperar contraseña',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                      const SizedBox(height: 16),

                      // Campo de email
                      TextField(
                        onChanged: (value) =>
                            setState(() => recoveryEmail = value),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.mail, color: Colors.grey),
                          hintText: 'tu@email.com',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF1A1A1A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Botones
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => setState(
                                  () => showForgotPassword = false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: handleForgotPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFB923C),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text('Enviar'),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  /// --------------------------------------------------------------
  /// UI principal del login
  /// --------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Stack(
          children: [
            // Contenido principal
            Column(
              children: [
                const SizedBox(height: 50),

                // Logo
                Image.asset('assets/logo.png', width: 150),
                const SizedBox(height: 30),

                // Contenedor principal
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            isSignUp
                                ? '¡Únete a Quizzy!'
                                : '¡Bienvenido de nuevo!',
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Campo Email
                          TextField(
                            onChanged: (value) =>
                                setState(() => email = value),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon:
                                  const Icon(Icons.mail, color: Colors.grey),
                              hintText: 'tu@email.com',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: const Color(0xFF1A1A1A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Campo Password
                          TextField(
                            onChanged: (value) =>
                                setState(() => password = value),
                            obscureText: !showPassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon:
                                  const Icon(Icons.lock, color: Colors.grey),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  showPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(
                                    () => showPassword = !showPassword),
                              ),
                              hintText: '••••••••',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: const Color(0xFF1A1A1A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Enlace "¿Olvidaste tu contraseña?"
                          if (!isSignUp)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => setState(
                                    () => showForgotPassword = true),
                                child: const Text(
                                  '¿Olvidaste tu contraseña?',
                                  style:
                                      TextStyle(color: Color(0xFFFB923C)),
                                ),
                              ),
                            ),

                          const SizedBox(height: 10),

                          // Botón principal
                          ElevatedButton(
                            onPressed: handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFB923C),
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              isSignUp
                                  ? 'Crear cuenta'
                                  : 'Iniciar sesión',
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Toggle entre Sign In / Sign Up
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              '¿No tienes cuenta? Crear cuenta',
                              style: const TextStyle(color: Color(0xFFFB923C)),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Modal (solo aparece si showForgotPassword = true)
            if (showForgotPassword) buildForgotPasswordModal(),
          ],
        ),
      ),
    );
  }
}
