import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizzy/application/groups/usecases/assign_quiz_use_case.dart';
import 'package:quizzy/domain/groups/entities/group.dart';
import 'package:quizzy/injection_container.dart';
import 'package:quizzy/presentation/bloc/groups/groups_cubit.dart';
import 'package:quizzy/presentation/bloc/groups/groups_state.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';

class AssignGroupDialog extends StatefulWidget {
  final String quizId;

  const AssignGroupDialog({super.key, required this.quizId});

  @override
  State<AssignGroupDialog> createState() => _AssignGroupDialogState();
}

class _AssignGroupDialogState extends State<AssignGroupDialog> {
  Group? _selectedGroup;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('Añadir a Grupo'),
      content: SizedBox(
        width: double.maxFinite,
        child: BlocBuilder<GroupsCubit, GroupsState>(
          builder: (context, state) {
            if (state is GroupsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is GroupsError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is GroupsLoaded) {
              if (state.groups.isEmpty) {
                return const Text('No perteneces a ningún grupo.');
              }

              // Pre-select first group if none selected
              if (_selectedGroup == null && state.groups.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _selectedGroup == null) {
                    setState(() {
                      _selectedGroup = state.groups.first;
                    });
                  }
                });
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selecciona un grupo:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Group>(
                      value: _selectedGroup ?? state.groups.first,
                      dropdownColor: AppColors.surface,
                      items: state.groups.map((group) {
                        return DropdownMenuItem(
                          value: group,
                          child: Text(
                            group.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGroup = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black12,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Disponible desde:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${_startDate.year}-${_startDate.month}-${_startDate.day} ${_startDate.hour}:${_startDate.minute}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _pickDateTime(true),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Disponible hasta:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${_endDate.year}-${_endDate.month}-${_endDate.day} ${_endDate.hour}:${_endDate.minute}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _pickDateTime(false),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text('Cargando grupos...'));
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: _isLoading || _selectedGroup == null ? null : _assignQuiz,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Añadir'),
        ),
      ],
    );
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStart ? _startDate : _endDate),
      );

      if (time != null && mounted) {
        setState(() {
          final newDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          if (isStart) {
            _startDate = newDateTime;
          } else {
            _endDate = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _assignQuiz() async {
    if (_selectedGroup == null) return;

    setState(() => _isLoading = true);

    try {
      final assignQuizUseCase = getIt<AssignQuizUseCase>();

      // Access token is needed. Assuming AuthRepository or passed down.
      // But UseCase usually gets token if not provided, OR we need to get it.
      // The AssignQuizUseCase wrapper I saw earlier takes accessToken as argument!
      // So I need to get it. I can use AuthRepository.

      // Wait, let's check AssignQuizUseCase again.
      // It takes accessToken.

      final authRepo = context.read<GroupsCubit>().authRepository;
      // GroupsCubit has authRepository.

      final token = await authRepo.getToken();
      if (token == null) {
        throw Exception("Not authenticated");
      }

      await assignQuizUseCase(
        groupId: _selectedGroup!.id,
        quizId: widget.quizId,
        availableFrom: _startDate,
        availableUntil: _endDate,
        accessToken: token,
      );

      if (mounted) {
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }
}
