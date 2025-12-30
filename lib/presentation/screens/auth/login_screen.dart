import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quizzy/presentation/state/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authController,
    required this.onLoginSuccess,
  });

  final AuthController authController;
  final VoidCallback onLoginSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isRegistering = false;
  
  // For registration
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isRegistering) {
        await widget.authController.register(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
          'student', // Default user type
        );
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro exitoso. Por favor inicia sesión.')),
          );
          setState(() => _isRegistering = false);
        }
      } else {
        await widget.authController.login(
          _emailController.text,
          _passwordController.text,
        );
        widget.onLoginSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isRegistering ? 'Crear Cuenta' : 'Iniciar Sesión',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 30),
                  if (_isRegistering) ...[
                    _buildModernTextField(
                      controller: _nameController,
                      label: 'Nombre',
                      icon: Icons.person_outline_rounded,
                    ).animate().fadeIn(delay: 100.ms).slideX(),
                    const SizedBox(height: 16),
                  ],
                  _buildModernTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ).animate().fadeIn(delay: 200.ms).slideX(),
                  const SizedBox(height: 16),
                  _buildModernTextField(
                    controller: _passwordController,
                    label: 'Contraseña',
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                  ).animate().fadeIn(delay: 300.ms).slideX(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.orange.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isRegistering ? 'Registrarse' : 'Entrar',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => setState(() => _isRegistering = !_isRegistering),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[400],
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        children: [
                          TextSpan(
                              text: _isRegistering
                                  ? '¿Ya tienes cuenta? '
                                  : '¿No tienes cuenta? '),
                          TextSpan(
                            text: _isRegistering ? 'Inicia sesión' : 'Regístrate',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.orange),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.orange, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
    );
  }
}
