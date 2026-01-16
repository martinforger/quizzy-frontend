import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quizzy/domain/auth/entities/user_profile.dart';
import 'package:quizzy/presentation/state/auth_controller.dart';
import 'package:quizzy/presentation/state/profile_controller.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';
import 'package:quizzy/presentation/widgets/user_avatar.dart';

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
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  String? _selectedLanguage;
  String? _selectedUserType;

  bool _isEditing = false;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

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
    _emailController.dispose();
    _descriptionController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  void _populateFields(UserProfile profile) {
    if (_nameController.text.isEmpty) {
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _descriptionController.text = profile.description;
      _avatarUrlController.text = profile.avatarUrl;
      _selectedLanguage = profile.language;
      // Normalize user type to match dropdown values (uppercase)
      final type = profile.userType.toUpperCase();
      const validTypes = ['STUDENT', 'TEACHER'];
      _selectedUserType = validTypes.contains(type) ? type : 'STUDENT';
    }
  }

  void _updateAvatar(String url) {
    setState(() {
      _avatarUrlController.text = url;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _updateAvatar(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.profileController.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        description: _descriptionController.text,
        avatarUrl: _avatarUrlController.text,
        language: _selectedLanguage,
        userType: _selectedUserType,
      );
      
      if (mounted) {
        setState(() {
          _isEditing = false;
          _loadProfile(); // Reload to get updated data
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.manage_accounts_rounded,
                      color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '¡Perfil Actualizado!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tus datos personales han sido guardados.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E88E5), // Blue 600
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.blue.shade300, width: 1),
            ),
            margin: const EdgeInsets.all(20),
            elevation: 8,
            duration: const Duration(seconds: 4),
          ),
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
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Cambiar Contraseña'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña Actual',
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCurrent ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureCurrent = !obscureCurrent;
                          });
                        },
                      ),
                    ),
                    obscureText: obscureCurrent,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Ingresa tu contraseña actual' : null,
                  ),
                  TextFormField(
                    controller: newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Nueva Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureNew = !obscureNew;
                          });
                        },
                      ),
                    ),
                    obscureText: obscureNew,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Requerida';
                      if (value.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Contraseña',
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureConfirm = !obscureConfirm;
                          });
                        },
                      ),
                    ),
                    obscureText: obscureConfirm,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor confirma la contraseña';
                      if (value != newPasswordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
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
                        confirmPasswordController.text,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white24,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.verified_user_rounded,
                                      color: Colors.white),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '¡Contraseña Actualizada!',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Tu seguridad ha sido renovada con éxito.',
                                        style: TextStyle(
                                            color: Colors.white70, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF43A047), // Green 600
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                  color: Colors.green.shade300, width: 1),
                            ),
                            margin: const EdgeInsets.all(20),
                            elevation: 8,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    } on TimeoutException {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Tiempo de espera agotado. Verifica tu conexión.'),
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
          );
        },
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
               color: color.withOpacity(0.1),
               shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fade().scale(duration: 400.ms, curve: Curves.easeOutBack);
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
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                         // Glow effect
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 40,
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                        ).animate().fade(duration: 800.ms),

                        UserAvatar(
                          avatarUrl: _isEditing && _avatarUrlController.text.isNotEmpty
                              ? _avatarUrlController.text
                              : profile.avatarUrl,
                          radius: 60,
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: CircleAvatar(
                              backgroundColor: AppColors.primary,
                              radius: 18,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                onPressed: _pickImage,
                              ),
                            ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
                          ),
                      ],
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 32),

                  
                  // Stats
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildStatCard('Racha Actual', '${profile.gameStreak}',
                          Icons.local_fire_department_rounded, const Color(0xFFFF5722)),
                      _buildStatCard(
                        'Membresía',
                        profile.isPremium ? 'Premium' : profile.userType,
                        profile.isPremium
                            ? Icons.star_rounded
                            : Icons.workspace_premium_rounded,
                        const Color(0xFFFFD700),
                      ),
                      if (profile.state.toUpperCase() != 'ACTIVE') ...[
                        _buildStatCard(
                          'Estado',
                          profile.state,
                          Icons.info_outline,
                          Colors.redAccent,
                        ),
                      ],
                    ],
                  ).animate().slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOut),
                  const SizedBox(height: 24),

                  // Fields
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      prefixIcon: const Icon(Icons.person, color: Colors.white70),
                    ),
                    enabled: _isEditing,
                    validator: (v) => v?.isEmpty ?? true ? 'El nombre es requerido' : null,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), 
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      prefixIcon: const Icon(Icons.description, color: Colors.white70),
                      alignLabelWithHint: true,
                    ),
                    enabled: _isEditing,
                    maxLines: 3,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.white70),
                       filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      prefixIcon: const Icon(Icons.email, color: Colors.white70),
                    ),
                    enabled: _isEditing,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'El email es requerido';
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(v)) {
                         return 'Ingresa un correo electrónico válido';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),

                  if (_isEditing) ...[
                    SizedBox(
                      height: 60,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _AvatarPreset(url: 'https://i.pravatar.cc/150?u=1', onTap: _updateAvatar),
                          _AvatarPreset(url: 'https://i.pravatar.cc/150?u=2', onTap: _updateAvatar),
                          _AvatarPreset(url: 'https://i.pravatar.cc/150?u=3', onTap: _updateAvatar),
                          _AvatarPreset(url: 'https://i.pravatar.cc/150?u=4', onTap: _updateAvatar),
                          _AvatarPreset(url: 'https://i.pravatar.cc/150?u=5', onTap: _updateAvatar),
                          _AvatarPreset(url: 'https://img.freepik.com/free-psd/3d-illustration-person-with-sunglasses_23-2149436188.jpg', onTap: _updateAvatar),
                        ],
                  ),
                ),
                const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: AppColors.card,
                      decoration: InputDecoration(
                        labelText: 'Idioma',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: AppColors.card,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white12)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary)),
                        prefixIcon: const Icon(Icons.language, color: Colors.white70),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'es', child: Text('Español')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                      onChanged: (v) => setState(() => _selectedLanguage = v),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedUserType,
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: AppColors.card,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Usuario',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: AppColors.card,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white12)),
                        focusedBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(12),
                             borderSide: const BorderSide(color: AppColors.primary)),
                        prefixIcon: const Icon(Icons.badge, color: Colors.white70),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'STUDENT', child: Text('Estudiante')),
                        DropdownMenuItem(value: 'TEACHER', child: Text('Profesor')),
                      ],
                      onChanged: (v) => setState(() => _selectedUserType = v),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
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

class _AvatarPreset extends StatelessWidget {
  const _AvatarPreset({required this.url, required this.onTap});
  final String url;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: UserAvatar(
        avatarUrl: url,
        radius: 25,
        onTap: () => onTap(url),
      ),
    );
  }
}


