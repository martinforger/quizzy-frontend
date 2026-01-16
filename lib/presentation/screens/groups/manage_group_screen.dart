import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/groups/entities/group.dart';
import '../../../domain/groups/entities/group_member.dart';
import '../../bloc/groups/group_details_cubit.dart';
import '../../bloc/groups/group_details_state.dart';
import '../../theme/app_theme.dart';

/// Screen for managing group settings (admin only).
class ManageGroupScreen extends StatefulWidget {
  final Group group;

  const ManageGroupScreen({super.key, required this.group});

  @override
  State<ManageGroupScreen> createState() => _ManageGroupScreenState();
}

class _ManageGroupScreenState extends State<ManageGroupScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group.name);
    _descriptionController = TextEditingController(
      text: widget.group.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isNotEmpty) {
      context.read<GroupDetailsCubit>().updateGroup(
        widget.group.id,
        name: name != widget.group.name ? name : null,
        description: description != (widget.group.description ?? '')
            ? description
            : null,
      );
      Navigator.pop(context);
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Eliminar Grupo'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este grupo? Esta acción no se puede deshacer. Todas las pruebas, puntuaciones y miembros se eliminarán permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog

              final success = await context
                  .read<GroupDetailsCubit>()
                  .deleteGroup(widget.group.id);

              if (success && mounted) {
                Navigator.pop(
                  context,
                  true,
                ); // Return to indicate deletion needed
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showTransferAdminDialog(List<GroupMember> members) {
    final nonAdminMembers = members.where((m) => !m.isAdmin).toList();

    if (nonAdminMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay otros miembros para transferir')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Transferir Derechos de Administrador'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: nonAdminMembers.length,
            itemBuilder: (context, index) {
              final member = nonAdminMembers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[700],
                  child: Text(member.name[0].toUpperCase()),
                ),
                title: Text(member.name),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _confirmTransfer(member);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _confirmTransfer(GroupMember member) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Confirmar Transferencia'),
        content: Text(
          '¿Transferir derechos de administrador a ${member.name}? Pasarás a ser un miembro normal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GroupDetailsCubit>().transferAdmin(
                widget.group.id,
                member.id,
              );
            },
            child: const Text('Transferir'),
          ),
        ],
      ),
    );
  }

  void _removeMember(GroupMember member) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Eliminar Miembro'),
        content: Text('¿Eliminar a ${member.name} del grupo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GroupDetailsCubit>().removeMember(
                widget.group.id,
                member.id,
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupDetailsCubit, GroupDetailsState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }

        // If user is no longer admin (e.g. transferred rights), close manage screen
        if (state.group != null && !state.group!.isAdmin) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            title: const Text('Administrar Grupo'),
            actions: [
              TextButton(
                onPressed: _saveChanges,
                child: const Text(
                  'Listo',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group Avatar
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: _getGroupColor(widget.group.name),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            widget.group.name.isNotEmpty
                                ? widget.group.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surface,
                              width: 2,
                            ),
                          ),
                          child: const Icon(Icons.camera_alt, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Group Name
                const Text(
                  'NOMBRE DEL GRUPO',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                const Text(
                  'DESCRIPCIÓN',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Añade una descripción para tu grupo...',
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Settings
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.post_add,
                          color: AppColors.textMuted,
                        ),
                        title: const Text('Permitir publicaciones de miembros'),
                        subtitle: const Text(
                          'Los miembros pueden crear sus propias pruebas',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        trailing: Switch(
                          value: true,
                          onChanged: (value) {},
                          activeColor: AppColors.primary,
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.swap_horiz,
                          color: AppColors.textMuted,
                        ),
                        title: const Text('Transferir Derechos de Admin'),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textMuted,
                        ),
                        onTap: () => _showTransferAdminDialog(state.members),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Members
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Miembros (${state.members.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        context.read<GroupDetailsCubit>().createInvitation(
                          widget.group.id,
                        );
                      },
                      icon: const Icon(
                        Icons.add,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      label: const Text(
                        'Invitar',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar miembros',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textMuted,
                    ),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Members List
                ...state.members.map(
                  (member) => _MemberTile(
                    member: member,
                    onRemove: member.isAdmin
                        ? null
                        : () => _removeMember(member),
                  ),
                ),

                const SizedBox(height: 32),

                // Delete Group
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _showDeleteConfirmation,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar Grupo'),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Deleting this group will remove all quizzes, scores, and\nmembers permanently.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getGroupColor(String name) {
    final colors = [
      const Color(0xFF6C5CE7),
      const Color(0xFF00B894),
      const Color(0xFFE17055),
      const Color(0xFF0984E3),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}

class _MemberTile extends StatelessWidget {
  final GroupMember member;
  final VoidCallback? onRemove;

  const _MemberTile({required this.member, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: member.isAdmin
                ? AppColors.primary
                : Colors.grey[700],
            child: Text(
              member.name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (member.isAdmin) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'TÚ',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  member.isAdmin ? 'Administrador' : 'Miembro',
                  style: TextStyle(
                    color: member.isAdmin
                        ? AppColors.primary
                        : Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.grey[600]),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
