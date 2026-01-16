import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot_answer.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot_question.dart';
import 'package:quizzy/domain/media/entities/media_asset.dart';
import 'package:quizzy/presentation/state/media_controller.dart';

class QuestionEditorScreen extends StatefulWidget {
  const QuestionEditorScreen({
    super.key,
    required this.question,
    required this.index,
    required this.mediaController,
  });

  final KahootQuestion question;
  final int index;
  final MediaController mediaController;

  @override
  State<QuestionEditorScreen> createState() => _QuestionEditorScreenState();
}

class _QuestionEditorScreenState extends State<QuestionEditorScreen> {
  late TextEditingController _textController;
  int _timeLimit = 20;
  late TextEditingController _pointsController;
  late String _type;
  late List<KahootAnswer> _answers;
  final ImagePicker _imagePicker = ImagePicker();
  String? _mediaUrl;
  String? _mediaAssetId;
  bool _mediaUploading = false;
  final Map<int, String> _answerMediaUrls = {};

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
    final initialMediaId = widget.question.mediaId;
    if (initialMediaId != null && initialMediaId.startsWith('http')) {
      _mediaUrl = initialMediaId;
      _mediaAssetId = null;
    } else {
      _mediaUrl = null;
      _mediaAssetId = initialMediaId;
    }
    for (var i = 0; i < _answers.length; i++) {
      final mediaId = _answers[i].mediaId;
      if (mediaId != null && mediaId.startsWith('http')) {
        _answerMediaUrls[i] = mediaId;
      }
    }
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
      mediaId: _mediaAssetId ?? _mediaUrl,
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

  Future<void> _pickQuestionMedia() async {
    try {
      setState(() => _mediaUploading = true);
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) {
        if (mounted) setState(() => _mediaUploading = false);
        return;
      }
      final bytes = await file.readAsBytes();
      final asset = await widget.mediaController.upload(
        bytes: bytes,
        filename: file.name,
        category: 'image',
      );
      if (!mounted) return;
      setState(() {
        _mediaUrl = asset.url;
        _mediaAssetId = asset.assetId;
        _mediaUploading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _mediaUploading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al subir imagen: $e')));
    }
  }

  Future<void> _pickAnswerMedia(int idx) async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final asset = await widget.mediaController.upload(
        bytes: bytes,
        filename: file.name,
        category: 'image',
      );
      if (!mounted) return;
      setState(() {
        final current = _answers[idx];
        _answers[idx] = KahootAnswer(
          id: current.id,
          text: current.text,
          mediaId: asset.assetId,
          isCorrect: current.isCorrect,
        );
        _answerMediaUrls[idx] = asset.url;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al subir imagen: $e')));
    }
  }

  Future<void> _openMediaLibrary({
    required ValueChanged<MediaAsset> onSelected,
  }) async {
    final future = widget.mediaController.listThemes();
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1A22),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Banco de imagenes',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar imagen...',
                      filled: true,
                      fillColor: Color(0xFF27222C),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setSheetState(() => query = value),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<MediaAsset>>(
                    future: future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('No pudimos cargar el banco de imagenes'),
                        );
                      }
                      final items = (snapshot.data ?? []).where((asset) {
                        final needle = query.trim().toLowerCase();
                        if (needle.isEmpty) return true;
                        final name = asset.name?.toLowerCase() ?? '';
                        final category = asset.category?.toLowerCase() ?? '';
                        return name.contains(needle) ||
                            category.contains(needle);
                      }).toList();
                      if (items.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('Sin resultados'),
                        );
                      }
                      return SizedBox(
                        height: 320,
                        child: GridView.builder(
                          itemCount: items.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.9,
                              ),
                          itemBuilder: (context, index) {
                            final asset = items[index];
                            return GestureDetector(
                              onTap: () {
                                onSelected(asset);
                                Navigator.of(context).pop();
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.network(
                                        asset.url,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const ColoredBox(
                                              color: Color(0xFF27222C),
                                              child: Icon(
                                                Icons.broken_image_outlined,
                                                color: Colors.white70,
                                              ),
                                            ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 8,
                                      right: 8,
                                      bottom: 8,
                                      child: Text(
                                        asset.name ?? 'Imagen',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black54,
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
    _syncAnswerMediaUrls();
  }

  void _syncAnswerMediaUrls() {
    final validIndexes = _answers.asMap().keys.toSet();
    _answerMediaUrls.removeWhere((key, _) => !validIndexes.contains(key));
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
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final previewUrl = _answerMediaUrls[idx];
            final hasImage = previewUrl != null && previewUrl.isNotEmpty;
            final hasText = controller.text.trim().isNotEmpty;
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
                          setState(() {
                            _answers.removeAt(idx);
                            _answerMediaUrls.remove(idx);
                          });
                        },
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.redAccent,
                        ),
                        tooltip: 'Eliminar respuesta',
                      ),
                      IconButton(
                        onPressed: () {
                          _toggleCorrect(idx);
                          setSheetState(() {});
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      color: const Color(0xFF27222C),
                      child: hasImage
                          ? Image.network(
                              previewUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.white70,
                                  size: 28,
                                ),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.photo_outlined,
                                  color: Colors.white60,
                                  size: 30,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Añadir imagen de respuesta',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          if (hasText) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No puedes usar texto e imagen al mismo tiempo.',
                                ),
                              ),
                            );
                            return;
                          }
                          await _pickAnswerMedia(idx);
                          controller.text = '';
                          setState(() {
                            final current = _answers[idx];
                            _answers[idx] = KahootAnswer(
                              id: current.id,
                              text: '',
                              mediaId: current.mediaId,
                              isCorrect: current.isCorrect,
                            );
                          });
                          setSheetState(() {});
                        },
                        icon: const Icon(Icons.image_outlined),
                        label: const Text('Subir'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () async {
                          if (hasText) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No puedes usar texto e imagen al mismo tiempo.',
                                ),
                              ),
                            );
                            return;
                          }
                          await _openMediaLibrary(
                            onSelected: (asset) {
                              setState(() {
                                final current = _answers[idx];
                                _answers[idx] = KahootAnswer(
                                  id: current.id,
                                  text: '',
                                  mediaId: asset.assetId,
                                  isCorrect: current.isCorrect,
                                );
                                _answerMediaUrls[idx] = asset.url;
                              });
                              controller.text = '';
                              setSheetState(() {});
                            },
                          );
                        },
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Banco'),
                      ),
                      const Spacer(),
                      if (hasImage)
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              final current = _answers[idx];
                              _answers[idx] = KahootAnswer(
                                id: current.id,
                                text: current.text,
                                mediaId: null,
                                isCorrect: current.isCorrect,
                              );
                              _answerMediaUrls.remove(idx);
                            });
                            setSheetState(() {});
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Quitar'),
                        ),
                    ],
                  ),
                  if (hasText && !hasImage) ...[
                    const SizedBox(height: 6),
                    const Text(
                      'Elimina el texto para poder subir una imagen.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    enabled: !hasImage,
                    decoration: InputDecoration(
                      labelText: hasImage
                          ? 'Texto deshabilitado (quita la imagen)'
                          : 'Texto de respuesta',
                      filled: true,
                      fillColor: const Color(0xFF27222C),
                      border: const OutlineInputBorder(
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
                      setSheetState(() {});
                    },
                  ),
                ],
              ),
            );
          },
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
      backgroundColor: Colors.transparent,
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
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: const Color(0xFF121014)),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            child: Column(
              children: [
                // Media
                GestureDetector(
                  onTap: _mediaUploading ? null : _pickQuestionMedia,
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1A22),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                      image: _mediaUrl != null && _mediaUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(_mediaUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: Stack(
                      children: [
                        if (_mediaUrl == null || _mediaUrl!.isEmpty)
                          Center(
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
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => _openMediaLibrary(
                                  onSelected: (asset) {
                                    setState(() {
                                      _mediaAssetId = asset.assetId;
                                      _mediaUrl = asset.url;
                                    });
                                  },
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black45,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Buscar'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _mediaUploading
                                    ? null
                                    : _pickQuestionMedia,
                                icon: _mediaUploading
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.cloud_upload_outlined,
                                        size: 18,
                                      ),
                                label: Text(
                                  _mediaUploading ? 'Subiendo...' : 'Subir',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                    final previewUrl = _answerMediaUrls[idx] ?? '';
                    return GestureDetector(
                      onTap: () => _openAnswerModal(idx, color),
                      child: _AnswerCard(
                        color: color,
                        answer: answer,
                        mediaUrl: previewUrl,
                      ),
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
  const _AnswerCard({
    required this.color,
    required this.answer,
    required this.mediaUrl,
  });

  final Color color;
  final KahootAnswer answer;
  final String mediaUrl;

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
          if (mediaUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                mediaUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white70,
                  ),
                ),
              ),
            )
          else
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
