import 'package:flutter/material.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot_answer.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot_question.dart';

class QuestionEditorScreen extends StatefulWidget {
  const QuestionEditorScreen({
    super.key,
    required this.question,
    required this.index,
  });

  final KahootQuestion question;
  final int index;

  @override
  State<QuestionEditorScreen> createState() => _QuestionEditorScreenState();
}

class _QuestionEditorScreenState extends State<QuestionEditorScreen> {
  late TextEditingController _textController;
  int _timeLimit = 20;
  late TextEditingController _pointsController;
  late String _type;
  late List<KahootAnswer> _answers;

  final List<int> _allowedTimes = [5, 10, 20, 30, 45, 60, 90, 120, 180, 240];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.question.text);
    // Set initial time limit, defaulting to 20 if null or not in list (optional: snap to nearest?)
    final t = widget.question.timeLimit ?? 20;
    if (_allowedTimes.contains(t)) {
      _timeLimit = t;
    } else {
      _timeLimit = 20; // Default fallback
    }

    _pointsController = TextEditingController(
      text: widget.question.points?.toString() ?? '',
    );
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
      timeLimit: _timeLimit,
      points: int.tryParse(_pointsController.text),
      answers: _answers,
    );
    Navigator.of(context).pop(updated);
  }

  void _addAnswer() {
    setState(() {
      _answers = [
        ..._answers,
        KahootAnswer(
          text: 'Respuesta ${_answers.length + 1}',
          isCorrect: false,
        ),
      ];
    });
  }

  void _applyType(String value, {bool initial = false}) {
    setState(() {
      _type = value;
      if (value == 'trueFalse') {
        _answers = [
          KahootAnswer(text: 'Verdadero', isCorrect: true),
          KahootAnswer(text: 'Falso', isCorrect: false),
        ];
      } else if (value == 'shortAnswer') {
        _answers = [KahootAnswer(text: 'Respuesta correcta', isCorrect: true)];
      } else if (!initial && _answers.length < 4) {
        _answers = [
          KahootAnswer(text: 'Respuesta 1', isCorrect: true),
          KahootAnswer(text: 'Respuesta 2', isCorrect: false),
          KahootAnswer(text: 'Respuesta 3', isCorrect: false),
          KahootAnswer(text: 'Respuesta 4', isCorrect: false),
        ];
      }
    });
  }

  Future<void> _openAnswerModal(int idx, Color color) async {
    final answer = _answers[idx];
    final controller = TextEditingController(text: answer.text);
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1A22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Respuesta ${idx + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.of(ctx).maybePop();
                      if (_answers.length <= 1) return;
                      setState(() => _answers.removeAt(idx));
                    },
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Colors.redAccent,
                    ),
                    tooltip: 'Eliminar respuesta',
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(ctx).maybePop();
                      _toggleCorrect(idx);
                    },
                    icon: Icon(
                      answer.isCorrect
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: Colors.white,
                    ),
                    tooltip: 'Marcar correcta',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Texto de respuesta',
                  filled: true,
                  fillColor: Color(0xFF27222C),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                onChanged: (v) {
                  setState(() {
                    final updated = List<KahootAnswer>.from(_answers);
                    updated[idx] = KahootAnswer(
                      id: answer.id,
                      text: v,
                      mediaId: answer.mediaId,
                      isCorrect: answer.isCorrect,
                    );
                    _answers = updated;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
    ];

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
              DropdownMenuItem(
                value: 'trueFalse',
                child: Text('Verdadero/Falso'),
              ),
              DropdownMenuItem(
                value: 'shortAnswer',
                child: Text('Respuesta corta'),
              ),
            ],
            onChanged: (v) {
              if (v == null) return;
              _applyType(v);
            },
          ),
        ),
        actions: [TextButton(onPressed: _save, child: const Text('Listo'))],
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
                        Icon(
                          Icons.add_box_rounded,
                          size: 42,
                          color: Colors.white54,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Añadir multimedia',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Timer chip
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _timeLimit,
                        dropdownColor: Colors.purple.shade800,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _timeLimit = v);
                          }
                        },
                        items: _allowedTimes.map((t) {
                          return DropdownMenuItem<int>(
                            value: t,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.timer,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text('$t s'),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
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
                (answer.text?.isNotEmpty ?? false)
                    ? answer.text!
                    : 'Añadir respuesta',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
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
