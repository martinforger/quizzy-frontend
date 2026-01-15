import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:quizzy/infrastructure/core/backend_config.dart';
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
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isRegistering = false;

  // For registration
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
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
            const SnackBar(
              content: Text('Registro exitoso. Por favor inicia sesión.'),
            ),
          );
          setState(() => _isRegistering = false);
        }
      } else {
        await widget.authController.login(
          _usernameController.text,
          _passwordController.text,
        );
        widget.onLoginSuccess();
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tiempo de espera agotado. Por favor verifica tu conexión.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = _getErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade900,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
            action: SnackBarAction(
              label: 'Aceptar',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
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
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.2, end: 0),
                  const SizedBox(height: 20),
                  Image.asset('assets/images/logo.png', height: 150)
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 30),
                  if (_isRegistering) ...[
                    _buildModernTextField(
                      controller: _nameController,
                      label: 'Nombre',
                      icon: Icons.person_outline_rounded,
                    ).animate().fadeIn(delay: 100.ms).slideX(),
                    const SizedBox(height: 16),
                    _buildModernTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ).animate().fadeIn(delay: 160.ms).slideX(),
                    const SizedBox(height: 16),
                  ],
                  _buildModernTextField(
                    controller: _usernameController,
                    label: 'Usuario',
                    icon: Icons.account_circle_outlined,
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
                    onPressed: () =>
                        setState(() => _isRegistering = !_isRegistering),
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
                                : '¿No tienes cuenta? ',
                          ),
                          TextSpan(
                            text: _isRegistering
                                ? 'Inicia sesión'
                                : 'Regístrate',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 40),
                  // Backend Selector
                  _buildBackendSelector().animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 20),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
    );
  }

  Widget _buildBackendSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dns_outlined, color: Colors.grey[400], size: 18),
              const SizedBox(width: 8),
              Text(
                'Servidor Backend',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<BackendEnvironment>(
              value: BackendSettings.currentEnv,
              isExpanded: true,
              dropdownColor: const Color(0xFF2A2A2A),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.orange),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              items: BackendEnvironment.values.map((env) {
                String label;
                IconData icon;
                switch (env) {
                  case BackendEnvironment.equipoA:
                    label = 'Equipo A';
                    icon = Icons.cloud;
                  case BackendEnvironment.equipoB:
                    label = 'Equipo B';
                    icon = Icons.cloud_outlined;
                  case BackendEnvironment.privado:
                    label = 'Privado';
                    icon = Icons.developer_mode;
                }
                return DropdownMenuItem(
                  value: env,
                  child: Row(
                    children: [
                      Icon(icon, color: Colors.orange, size: 20),
                      const SizedBox(width: 12),
                      Text(label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (env) {
                if (env != null) {
                  setState(() {
                    BackendSettings.setEnvironment(env);
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getErrorMessage(dynamic error) {
    var errorStr = error.toString();

    // Limpiar prefijos comunes de excepciones
    if (errorStr.startsWith('Exception: ')) {
      errorStr = errorStr.replaceFirst('Exception: ', '');
    }
    if (errorStr.contains('Failed to login: ')) {
      errorStr = errorStr.replaceAll('Failed to login: ', '');
    }

    // Intentar extraer JSON
    final jsonStartIndex = errorStr.indexOf('{');
    final jsonEndIndex = errorStr.lastIndexOf('}');

    if (jsonStartIndex != -1 &&
        jsonEndIndex != -1 &&
        jsonEndIndex > jsonStartIndex) {
      try {
        final jsonStr = errorStr.substring(jsonStartIndex, jsonEndIndex + 1);
        final jsonMap = jsonDecode(jsonStr);

        // 1. Prioridad: Buscar en 'details' -> 'message'
        if (jsonMap.containsKey('details') && jsonMap['details'] is Map) {
          final details = jsonMap['details'];
          if (details.containsKey('message')) {
            final dynamic message = details['message'];
            return _formatMessage(message);
          }
        }

        // 2. Fallback: Buscar en top-level 'message'
        if (jsonMap.containsKey('message')) {
          final dynamic message = jsonMap['message'];
          // Ignorar mensajes genéricos de orquestación si es posible
          if (message != 'Application orchestration error.') {
            return _formatMessage(message);
          }
          // Si el mensaje es el genérico y no hay detalles, mostramos un fallback
          if (message == 'Application orchestration error.') {
            return 'Credenciales inválidas o error de conexión.';
          }
        }
      } catch (_) {
        // Fallo en parsing, devolver string limpio
      }
    }

    return errorStr.trim();
  }

  String _formatMessage(dynamic message) {
    if (message is List) {
      // Unir lista de errores con saltos de línea
      return message.map((e) => e.toString()).join('\n');
    } else if (message is String) {
      // Limpiar comas extra si vienen concatenados estilo "Error 1.,Error 2."
      return message.replaceAll('.,', '.\n');
    }
    return message.toString();
  }
}
