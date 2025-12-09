import 'package:flutter/material.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot_answer.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot_question.dart';
import 'package:quizzy/presentation/screens/kahoots/question_editor_screen.dart';
import 'package:quizzy/presentation/state/kahoot_controller.dart';

class KahootEditorScreen extends StatefulWidget {
  const KahootEditorScreen({
    super.key,
    required this.kahootController,
    required this.defaultAuthorId,
    required this.defaultThemeId,
  });

  final KahootController kahootController;
  final String defaultAuthorId;
  final String defaultThemeId;

  @override
  State<KahootEditorScreen> createState() => _KahootEditorScreenState();
}

class _KahootEditorScreenState extends State<KahootEditorScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coverController = TextEditingController();
  String _visibility = 'public';
  String _status = 'draft';
  String _category = '';
  bool _saving = false;
  String? _error;
  final List<KahootQuestion> _questions = [];

  bool get _needsQuestions =>
      _questions.isEmpty ||
      _questions.any((q) => q.text == null || q.text!.trim().isEmpty);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _coverController.dispose();
    super.dispose();
  }

  void _addQuestion(String type) {
    final newQuestion = _buildDefaultQuestion(type);
    setState(() {
      _questions.add(newQuestion);
    });
    _editQuestion(_questions.length - 1);
  }

  KahootQuestion _buildDefaultQuestion(String type) {
    if (type == 'trueFalse') {
      return KahootQuestion(
        type: type,
        timeLimit: 20,
        answers: [
          KahootAnswer(text: 'Verdadero', isCorrect: true),
          KahootAnswer(text: 'Falso', isCorrect: false),
        ],
      );
    }
    return KahootQuestion(
      type: type,
      timeLimit: 20,
      answers: [
        KahootAnswer(text: 'Respuesta 1', isCorrect: true),
        KahootAnswer(text: 'Respuesta 2', isCorrect: false),
        KahootAnswer(text: 'Respuesta 3', isCorrect: false),
        KahootAnswer(text: 'Respuesta 4', isCorrect: false),
      ],
    );
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final themeId = widget.defaultThemeId.isNotEmpty
          ? widget.defaultThemeId
          : null;
      final authorId = widget.defaultAuthorId.isNotEmpty
          ? widget.defaultAuthorId
          : null;
      if (themeId == null || authorId == null) {
        setState(() {
          _error = 'Falta configurar themeId/authorId por defecto.';
          _saving = false;
        });
        return;
      }
      final kahoot = Kahoot(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        coverImageId: _coverController.text.trim().isEmpty
            ? null
            : _coverController.text.trim(),
        visibility: _visibility,
        category: _category.isEmpty ? null : _category,
        status: _status,
        themeId: themeId,
        authorId: authorId,
        questions: _questions,
      );
      final saved = await widget.kahootController.create(kahoot);
      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openTypeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1A22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final types = [
          ('quiz', 'Quiz'),
          ('trueFalse', 'Verdadero/Falso'),
          ('shortAnswer', 'Respuesta corta'),
        ];
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Añadir pregunta',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: types
                    .map(
                      (t) => GestureDetector(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          _addQuestion(t.$1);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(14),
                          width: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: t.$1 == 'quiz'
                                  ? [
                                      const Color(0xFF5F4B8B),
                                      const Color(0xFF7F5AF0),
                                    ]
                                  : t.$1 == 'trueFalse'
                                  ? [
                                      const Color(0xFF3EADCF),
                                      const Color(0xFFABE9CD),
                                    ]
                                  : [
                                      const Color(0xFFFF8C37),
                                      const Color(0xFFFF5F6D),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.$2,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Tap para seleccionar',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0B12),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leadingWidth: 115,
          leading: TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(105, 46),
              alignment: Alignment.centerLeft,
            ),
            child: const Text(
              'Cancelar',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          centerTitle: true,
          title: Column(
            children: [
              const Text(
                'Crear kahoot',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Container(
                height: 4,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade900,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: (_error != null || _needsQuestions)
                      ? Container(
                          key: const ValueKey('banner'),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.redAccent.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _error ??
                                      'Completa al menos una pregunta antes de continuar',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (_needsQuestions)
                                TextButton(
                                  onPressed: _openTypeSelector,
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.15,
                                    ),
                                  ),
                                  child: const Text('Agregar'),
                                ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                _CoverField(controller: _coverController),
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'Título',
                  child: _buildTextField(
                    _titleController,
                    hint: 'Escribir título',
                  ),
                ),
                const SizedBox(height: 12),
                _LabeledField(
                  label: 'Descripción',
                  child: _buildTextField(
                    _descriptionController,
                    hint: 'Opcional',
                  ),
                ),
                const SizedBox(height: 12),
                _LabeledField(
                  label: 'Visibilidad',
                  child: DropdownButtonFormField<String>(
                    value: _visibility,
                    dropdownColor: const Color(0xFF1E1A22),
                    decoration: _inputDecoration(),
                    items: const [
                      DropdownMenuItem(value: 'public', child: Text('Público')),
                      DropdownMenuItem(
                        value: 'private',
                        child: Text('Privado'),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _visibility = v ?? 'public'),
                  ),
                ),
                const SizedBox(height: 12),
                _LabeledField(
                  label: 'Categoría',
                  child: _buildTextField(
                    TextEditingController(text: _category),
                    hint: 'Ej: Geography',
                    onChanged: (v) => _category = v,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Preguntas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _openTypeSelector,
                      icon: const Icon(Icons.add),
                      label: const Text('Añadir'),
                    ),
                  ],
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _questions.isEmpty
                      ? Container(
                          key: const ValueKey('empty'),
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1A22),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Aún no hay preguntas. Añade una para continuar.',
                          ),
                        )
                      : Column(
                          key: const ValueKey('list'),
                          children: _questions.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final q = entry.value;
                            return _QuestionTile(
                              question: q,
                              index: idx,
                              onEdit: () => _editQuestion(idx),
                              onDelete: () =>
                                  setState(() => _questions.removeAt(idx)),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                10,
                16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC0F0B12)],
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: _openTypeSelector,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF5B8DEF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 6,
                ),
                icon: const Icon(Icons.add),
                label: const Text('Añadir pregunta'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF1E1A22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    String? hint,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: _inputDecoration().copyWith(hintText: hint),
      style: const TextStyle(color: Colors.white),
    );
  }

  Future<void> _editQuestion(int index) async {
    final question = _questions[index];
    final updated = await Navigator.of(context).push<KahootQuestion>(
      MaterialPageRoute(
        builder: (_) =>
            QuestionEditorScreen(question: question, index: index + 1),
        fullscreenDialog: true,
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        _questions[index] = updated;
      });
    }
  }
}

class _QuestionTile extends StatelessWidget {
  const _QuestionTile({
    required this.question,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  final KahootQuestion question;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white12,
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.text?.isNotEmpty == true
                      ? question.text!
                      : 'Pregunta sin título',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  question.type ?? 'quiz',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, color: Colors.white70),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatefulWidget {
  const _QuestionCard({
    required this.question,
    required this.index,
    required this.onChanged,
    required this.onDelete,
  });

  final KahootQuestion question;
  final int index;
  final ValueChanged<KahootQuestion> onChanged;
  final VoidCallback onDelete;

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  late TextEditingController _textController;
  late TextEditingController _timeController;
  late TextEditingController _pointsController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.question.text);
    _timeController = TextEditingController(
      text: widget.question.timeLimit?.toString() ?? '20',
    );
    _pointsController = TextEditingController(
      text: widget.question.points?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _timeController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _updateQuestion({
    String? text,
    int? timeLimit,
    int? points,
    List<KahootAnswer>? answers,
  }) {
    widget.onChanged(
      KahootQuestion(
        id: widget.question.id,
        text: text ?? widget.question.text,
        mediaId: widget.question.mediaId,
        type: widget.question.type,
        timeLimit: timeLimit ?? widget.question.timeLimit,
        points: points ?? widget.question.points,
        answers: answers ?? widget.question.answers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final answers = widget.question.answers;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Chip(
                label: Text(widget.question.type ?? 'quiz'),
                backgroundColor: Colors.white10,
              ),
              const Spacer(),
              IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete, color: Colors.redAccent),
              ),
            ],
          ),
          TextFormField(
            controller: _textController,
            decoration: const InputDecoration(
              hintText: 'Escribe la pregunta',
              filled: true,
              fillColor: Color(0xFF27222C),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            onChanged: (v) => _updateQuestion(text: v),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _timeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tiempo (s)',
                    filled: true,
                    fillColor: Color(0xFF27222C),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  onChanged: (v) => _updateQuestion(timeLimit: int.tryParse(v)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Puntos',
                    filled: true,
                    fillColor: Color(0xFF27222C),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  onChanged: (v) => _updateQuestion(points: int.tryParse(v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: answers.asMap().entries.map((entry) {
              final idx = entry.key;
              final answer = entry.value;
              final colors = [
                Colors.red,
                Colors.blue,
                Colors.orange,
                Colors.green,
                Colors.purple,
                Colors.teal,
              ];
              final bg = colors[idx % colors.length];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: bg.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: answer.isCorrect ? bg : bg.withOpacity(0.5),
                  ),
                ),
                child: ListTile(
                  leading: AnimatedScale(
                    scale: answer.isCorrect ? 1.0 : 0.85,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.check_circle,
                      color: answer.isCorrect ? bg : Colors.white54,
                    ),
                  ),
                  title: TextFormField(
                    initialValue: answer.text,
                    decoration: const InputDecoration(
                      hintText: 'Respuesta',
                      border: InputBorder.none,
                    ),
                    onChanged: (v) {
                      final updated = List<KahootAnswer>.from(answers);
                      updated[idx] = KahootAnswer(
                        id: answer.id,
                        text: v,
                        mediaId: answer.mediaId,
                        isCorrect: answer.isCorrect,
                      );
                      _updateQuestion(answers: updated);
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.check),
                    color: answer.isCorrect ? bg : Colors.white70,
                    onPressed: () {
                      final updated = List<KahootAnswer>.from(answers)
                          .asMap()
                          .entries
                          .map(
                            (e) => KahootAnswer(
                              id: e.value.id,
                              text: e.value.text,
                              mediaId: e.value.mediaId,
                              isCorrect: e.key == idx,
                            ),
                          )
                          .toList();
                      _updateQuestion(answers: updated);
                    },
                  ),
                ),
              );
            }).toList(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                final updated = List<KahootAnswer>.from(answers)
                  ..add(KahootAnswer(text: '', isCorrect: false));
                _updateQuestion(answers: updated);
              },
              icon: const Icon(Icons.add),
              label: const Text('Añadir respuesta'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _CoverField extends StatelessWidget {
  const _CoverField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1A22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.image_outlined, size: 36, color: Colors.white54),
                  SizedBox(height: 8),
                  Text(
                    'Añadir imagen de portada',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'URL de imagen (temporal, media upload pendiente)',
                  filled: true,
                  fillColor: Color(0xFF27222C),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
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
