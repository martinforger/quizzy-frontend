import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quizzy/domain/auth/entities/user_profile.dart';
import 'package:quizzy/presentation/state/auth_controller.dart';
import 'package:quizzy/presentation/state/profile_controller.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.profileController,
    required this.authController,
    required this.onLogout,
  });

  final ProfileController profileController;
  final AuthController authController;
  final VoidCallback onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile> _profileFuture;
  final _formKey = GlobalKey<FormState>();

  // Controllers for editing
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  String? _selectedLanguage;
  String? _selectedUserType;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _profileFuture = widget.profileController.getProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  void _populateFields(UserProfile profile) {
    _nameController.text = profile.name;
    _descriptionController.text = profile.description;
    _avatarUrlController.text = profile.avatarUrl;
    _selectedLanguage = profile.language;
    _selectedUserType = profile.userType;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.profileController.updateProfile(
        name: _nameController.text,
        description: _descriptionController.text,
        avatarUrl: _avatarUrlController.text,
        language: _selectedLanguage,
        userType: _selectedUserType,
      );
      
      setState(() {
        _isEditing = false;
        _loadProfile(); // Reload to get updated data
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar perfil: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _changePassword() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                decoration: const InputDecoration(labelText: 'Contraseña Actual'),
                obscureText: true,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Requerido' : null,
              ),
              TextFormField(
                controller: newPasswordController,
                decoration: const InputDecoration(labelText: 'Nueva Contraseña'),
                obscureText: true,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Requerido' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await widget.profileController.updatePassword(
                    currentPasswordController.text,
                    newPasswordController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Contraseña actualizada correctamente')),
                    );
                  }
                } on TimeoutException {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tiempo de espera agotado. Verifica tu conexión.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await widget.authController.logout();
      if (mounted) {
         Navigator.of(context).pop(); // Close profile screen
         widget.onLogout(); // Notify app to change state
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tiempo de espera agotado al cerrar sesión.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _loadProfile(); // Reset fields
                });
              },
            ),
        ],
      ),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No se encontró el perfil'));
          }

          final profile = snapshot.data!;
          if (!_isEditing && _nameController.text.isEmpty) {
             _populateFields(profile);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profile.avatarUrl.isNotEmpty
                        ? NetworkImage(profile.avatarUrl)
                        : null,
                    child: profile.avatarUrl.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatCard('Racha', '${profile.gameStreak} 🔥'),
                      const SizedBox(width: 16),
                      _buildStatCard('Tipo', profile.userType),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Fields
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    enabled: _isEditing,
                    validator: (v) => v?.isEmpty ?? true ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    enabled: _isEditing,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    initialValue: profile.email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    enabled: false, // Email usually not editable directly
                  ),
                  const SizedBox(height: 16),

                  if (_isEditing) ...[
                    TextFormField(
                      controller: _avatarUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL del Avatar',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      decoration: const InputDecoration(
                        labelText: 'Idioma',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.language),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'es', child: Text('Español')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                      onChanged: (v) => setState(() => _selectedLanguage = v),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedUserType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Usuario',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Estudiante', child: Text('Estudiante')),
                        DropdownMenuItem(value: 'Profesor', child: Text('Profesor')),
                        DropdownMenuItem(value: 'Profesional', child: Text('Profesional')),
                        DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                      ],
                      onChanged: (v) => setState(() => _selectedUserType = v),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Guardar Cambios'),
                      ),
                    ),
                  ] else ...[
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Cambiar Contraseña'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _changePassword,
                      tileColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Cerrar Sesión', 
                        style: TextStyle(color: Colors.red)),
                      onTap: _logout,
                      tileColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


