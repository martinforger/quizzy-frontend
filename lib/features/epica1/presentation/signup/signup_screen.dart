import 'package:flutter/material.dart';
import '../login/login_screen.dart';
import '../user_type/user_type_screen.dart'; 
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String email = '';
  String password = '';
  bool showPassword = false;

  /// --------------------------------------------------------------
  /// Método que simula el registro
  /// --------------------------------------------------------------
  void handleSignUp() {
    // Navegar al UserTypeScreen simulando registro exitoso
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => UserTypeScreen(
          onSelectUserType: (userType) {
            // Aquí puedes manejar qué hacer con el tipo de usuario
            // Por ejemplo: guardar en estado global, base de datos, etc.
            print('Usuario seleccionado: $userType');
          },
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
            const SizedBox(height: 50),
            Image.asset('assets/logo.png', width: 150),
            const SizedBox(height: 30),

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
                      const Text(
                        '¡Únete a Quizzy!',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),

                      TextField(
                        onChanged: (value) => setState(() => email = value),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.mail, color: Colors.grey),
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

                      TextField(
                        onChanged: (value) => setState(() => password = value),
                        obscureText: !showPassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () =>
                                setState(() => showPassword = !showPassword),
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

                      ElevatedButton(
                        onPressed: handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFB923C),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Crear cuenta'),
                      ),
                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LoginScreen(onLogin: () {}),
                            ),
                          );
                        },
                        child: const Text(
                          '¿Ya tienes cuenta? Inicia sesión',
                          style: TextStyle(color: Color(0xFFFB923C)),
                        ),
                      ),
                    ],
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
