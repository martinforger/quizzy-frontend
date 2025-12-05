import 'package:flutter/material.dart';
import 'package:quizzy/domain/kahoots/entities/slide.dart';
import 'package:quizzy/domain/kahoots/entities/slide_option.dart';
import 'package:quizzy/presentation/state/slide_controller.dart';

class SlideEditorScreen extends StatefulWidget {
  const SlideEditorScreen({
    super.key,
    required this.slideController,
    required this.kahootId,
    this.slide,
  });

  final SlideController slideController;
  final String kahootId;
  final Slide? slide;

  @override
  State<SlideEditorScreen> createState() => _SlideEditorScreenState();
}

class _SlideEditorScreenState extends State<SlideEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late SlideType _type;
  late TextEditingController _textController;
  late TextEditingController _timeController;
  late TextEditingController _pointsController;
  late TextEditingController _mediaController;
  final List<_OptionField> _options = [];
  final TextEditingController _shortAnswersController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final slide = widget.slide;
    _type = slide?.type ?? SlideType.quizSingle;
    _textController = TextEditingController(text: slide?.text ?? '');
    _timeController = TextEditingController(text: slide?.timeLimitSeconds?.toString() ?? '');
    _pointsController = TextEditingController(text: slide?.points?.toString() ?? '');
    _mediaController = TextEditingController(text: slide?.mediaUrlQuestion ?? '');
    if (slide != null && slide.options.isNotEmpty) {
      for (final opt in slide.options) {
        _options.add(_OptionField(text: TextEditingController(text: opt.text), isCorrect: opt.isCorrect));
      }
    } else if (_type == SlideType.trueFalse) {
      _options
        ..add(_OptionField(text: TextEditingController(text: 'True'), isCorrect: true))
        ..add(_OptionField(text: TextEditingController(text: 'False'), isCorrect: false));
    } else {
      _options.add(_OptionField(text: TextEditingController(), isCorrect: false));
    }
    if (slide != null && slide.shortAnswerCorrectText.isNotEmpty) {
      _shortAnswersController.text = slide.shortAnswerCorrectText.join(', ');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _timeController.dispose();
    _pointsController.dispose();
    _mediaController.dispose();
    _shortAnswersController.dispose();
    for (final opt in _options) {
      opt.text.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final options = (_usesOptions(_type) ? _options : <_OptionField>[])
        .where((o) => o.text.text.trim().isNotEmpty)
        .map((o) => SlideOption(text: o.text.text.trim(), isCorrect: o.isCorrect))
        .toList();

    final shortAnswers = _type == SlideType.shortAnswer
        ? _shortAnswersController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList()
        : <String>[];

    final slide = Slide(
      id: widget.slide?.id ?? '',
      kahootId: widget.kahootId,
      position: widget.slide?.position ?? 0,
      type: _type,
      text: _textController.text.trim(),
      timeLimitSeconds: int.tryParse(_timeController.text),
      points: int.tryParse(_pointsController.text),
      mediaUrlQuestion: _mediaController.text.trim().isEmpty ? null : _mediaController.text.trim(),
      options: options,
      shortAnswerCorrectText: shortAnswers,
    );

    try {
      final saved = widget.slide == null
          ? await widget.slideController.createSlide(widget.kahootId, slide)
          : await widget.slideController.updateSlide(widget.kahootId, slide);
      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addOption() {
    setState(() {
      _options.add(_OptionField(text: TextEditingController(), isCorrect: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.slide == null ? 'Nueva pregunta' : 'Editar pregunta'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<SlideType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Tipo de pregunta'),
                items: SlideType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(_typeLabel(t)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _type = value;
                    if (_type == SlideType.trueFalse && _options.length < 2) {
                      _options
                        ..clear()
                        ..add(_OptionField(text: TextEditingController(text: 'True'), isCorrect: true))
                        ..add(_OptionField(text: TextEditingController(text: 'False'), isCorrect: false));
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(labelText: 'Pregunta'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el texto de la pregunta' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Tiempo límite (segundos)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pointsController,
                decoration: const InputDecoration(labelText: 'Puntos'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mediaController,
                decoration: const InputDecoration(labelText: 'Media URL (opcional)'),
              ),
              const SizedBox(height: 16),
              if (_usesOptions(_type)) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Opciones'),
                    TextButton.icon(
                      onPressed: _addOption,
                      icon: const Icon(Icons.add),
                      label: const Text('Añadir'),
                    ),
                  ],
                ),
                ..._options.asMap().entries.map(
                  (entry) {
                    final idx = entry.key;
                    final opt = entry.value;
                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: opt.isCorrect,
                          onChanged: (v) => setState(() => opt.isCorrect = v ?? false),
                        ),
                        title: TextFormField(
                          controller: opt.text,
                          decoration: InputDecoration(labelText: 'Opción ${idx + 1}'),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _options.removeAt(idx);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ] else if (_type == SlideType.shortAnswer) ...[
                TextFormField(
                  controller: _shortAnswersController,
                  decoration: const InputDecoration(
                    labelText: 'Respuestas correctas (separadas por coma)',
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _usesOptions(SlideType type) {
    return type == SlideType.quizSingle || type == SlideType.quizMultiple || type == SlideType.trueFalse;
  }

  String _typeLabel(SlideType type) {
    switch (type) {
      case SlideType.quizSingle:
        return 'Quiz opción única';
      case SlideType.quizMultiple:
        return 'Quiz múltiple';
      case SlideType.trueFalse:
        return 'Verdadero/Falso';
      case SlideType.shortAnswer:
        return 'Respuesta corta';
      case SlideType.poll:
        return 'Encuesta';
      case SlideType.slide:
        return 'Slide';
    }
  }
}

class _OptionField {
  _OptionField({required this.text, required this.isCorrect});

  final TextEditingController text;
  bool isCorrect;
}
