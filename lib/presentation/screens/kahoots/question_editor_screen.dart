import 'package:flutter/material.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot_answer.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot_question.dart';

class QuestionEditorScreen extends StatefulWidget {
  const QuestionEditorScreen({super.key, required this.question, required this.index});

  final KahootQuestion question;
  final int index;

  @override
  State<QuestionEditorScreen> createState() => _QuestionEditorScreenState();
}

class _QuestionEditorScreenState extends State<QuestionEditorScreen> {
  late TextEditingController _textController;
  late TextEditingController _timeController;
  late TextEditingController _pointsController;
  late String _type;
  late List<KahootAnswer> _answers;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.question.text);
    _timeController = TextEditingController(text: widget.question.timeLimit?.toString() ?? '20');
    _pointsController = TextEditingController(text: widget.question.points?.toString() ?? '');
    _type = widget.question.type ?? 'quiz';
    _answers = widget.question.answers.isNotEmpty
        ? List<KahootAnswer>.from(widget.question.answers)
        : [
            KahootAnswer(text: 'Respuesta 1', isCorrect: true),
            KahootAnswer(text: 'Respuesta 2', isCorrect: false),
            KahootAnswer(text: 'Respuesta 3', isCorrect: false),
            KahootAnswer(text: 'Respuesta 4', isCorrect: false),
          ];
    _applyType(_type, initial: true);
  }

  @override
  void dispose() {
    _textController.dispose();
    _timeController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _toggleCorrect(int idx) {
    setState(() {
      _answers = _answers.asMap().entries.map((e) {
        final a = e.value;
        return KahootAnswer(
          id: a.id,
          text: a.text,
          mediaId: a.mediaId,
          isCorrect: e.key == idx,
        );
      }).toList();
    });
  }

  void _save() {
    final updated = KahootQuestion(
      id: widget.question.id,
      text: _textController.text.trim(),
      mediaId: widget.question.mediaId,
      type: _type,
      timeLimit: int.tryParse(_timeController.text),
      points: int.tryParse(_pointsController.text),
      answers: _answers,
    );
    Navigator.of(context).pop(updated);
  }

  void _addAnswer() {
    setState(() {
      _answers.add(KahootAnswer(text: '', isCorrect: false));
    });
  }

  void _applyType(String type, {bool initial = false}) {
    // Always rebuild the answers set when the question type changes so UI reflects it instantly.
    List<KahootAnswer> updated = List.from(_answers);
    if (type == 'trueFalse') {
      updated = [
        KahootAnswer(text: 'Verdadero', isCorrect: true),
        KahootAnswer(text: 'Falso', isCorrect: false),
      ];
    } else if (type == 'shortAnswer') {
      updated = [];
    } else {
      // quiz default: ensure at least 4 answers
      while (updated.length < 4) {
        updated.add(KahootAnswer(text: 'Respuesta ${updated.length + 1}', isCorrect: false));
      }
      updated = updated.take(4).toList();
    }
    if (initial) {
      _type = type;
      _answers = updated;
      return;
    }
    if (!mounted) return;
    setState(() {
      _type = type;
      _answers = updated;
    });
  }

  void _openAnswerModal(int idx, Color color) {
    final answer = _answers[idx];
    final controller = TextEditingController(text: answer.text);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return GestureDetector(
          onTap: () => FocusScope.of(ctx).unfocus(),
          child: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 16,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1A22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Añadir respuesta',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Añadir respuesta',
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Respuesta correcta', style: TextStyle(color: Colors.white)),
                  trailing: Switch(
                    value: answer.isCorrect,
                    activeColor: color,
                    onChanged: (_) {
                      Navigator.of(ctx).pop();
                      _toggleCorrect(idx);
                    },
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                  title: const Text('Eliminar respuesta', style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    setState(() {
                      _answers.removeAt(idx);
                    });
                    Navigator.of(ctx).pop();
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _answers[idx] = KahootAnswer(
                        id: answer.id,
                        text: controller.text,
                        mediaId: answer.mediaId,
                        isCorrect: answer.isCorrect,
                      );
                    });
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: const Text('Listo'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.red, Colors.blue, Colors.orange, Colors.green, Colors.purple, Colors.teal];
    return Scaffold(
      backgroundColor: const Color(0xFF0F0B12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _type,
            dropdownColor: const Color(0xFF1E1A22),
            items: const [
              DropdownMenuItem(value: 'quiz', child: Text('Quiz')),
              DropdownMenuItem(value: 'trueFalse', child: Text('Verdadero/Falso')),
              DropdownMenuItem(value: 'shortAnswer', child: Text('Respuesta corta')),
            ],
            onChanged: (v) {
              if (v == null) return;
              _applyType(v);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Listo'),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            child: Column(
              children: [
                // Media
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1A22),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add_box_rounded, size: 42, color: Colors.white54),
                        SizedBox(height: 8),
                        Text('Añadir multimedia', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Timer chip
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 40,
                          child: TextField(
                            controller: _timeController,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const Text('s', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1A22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Pulsa para añadir una pregunta',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Answers grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _answers.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.4,
                  ),
                  itemBuilder: (context, idx) {
                    final answer = _answers[idx];
                    final color = colors[idx % colors.length];
                    return GestureDetector(
                      onTap: () => _openAnswerModal(idx, color),
                      child: _AnswerCard(color: color, answer: answer),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _addAnswer,
                  icon: const Icon(Icons.star, color: Colors.white70),
                  label: const Text('Añadir más respuestas'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white10,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 24 + MediaQuery.of(context).padding.bottom,
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.color, required this.answer});

  final Color color;
  final KahootAnswer answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Stack(
        children: [
          if (answer.isCorrect)
            const Positioned(
              right: 8,
              top: 8,
              child: Icon(Icons.check_circle, color: Colors.white, size: 20),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                (answer.text?.isNotEmpty ?? false) ? answer.text! : 'Añadir respuesta',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
