import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot_answer.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot_question.dart';
import 'package:quizzy/domain/discovery/entities/category.dart';
import 'package:quizzy/domain/media/entities/media_asset.dart';
import 'package:quizzy/infrastructure/ai/openai_image_service.dart';
import 'package:quizzy/presentation/screens/kahoots/question_editor_screen.dart';
import 'package:quizzy/presentation/state/discovery_controller.dart';
import 'package:quizzy/presentation/state/kahoot_controller.dart';
import 'package:quizzy/presentation/state/media_controller.dart';

class KahootEditorScreen extends StatefulWidget {
  const KahootEditorScreen({
    super.key,
    required this.kahootController,
    required this.mediaController,
    required this.discoveryController,
    required this.defaultAuthorId,
    required this.defaultThemeId,
    this.existingKahoot,
  });

  final KahootController kahootController;
  final MediaController mediaController;
  final DiscoveryController discoveryController;
  final String defaultAuthorId;
  final String defaultThemeId;
  final Kahoot? existingKahoot;

  @override
  State<KahootEditorScreen> createState() => _KahootEditorScreenState();
}

class _KahootEditorScreenState extends State<KahootEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _coverController;
  String _visibility = 'private';
  String _status = 'draft';
  String _category = '';
  List<Category> _categories = [];
  bool _categoriesLoading = true;
  String? _categoriesError;
  String? _coverUrl;
  String? _coverAssetId;
  bool _coverUploading = false;
  bool _aiCoverLoading = false;
  final ImagePicker _imagePicker = ImagePicker();
  final OpenAiImageService _openAiImageService = OpenAiImageService();
  bool _saving = false;
  String? _error;
  final List<KahootQuestion> _questions = [];

  bool get _needsQuestions =>
      _questions.isEmpty ||
      _questions.any((q) => q.text == null || q.text!.trim().isEmpty);

  @override
  void initState() {
    super.initState();
    final k = widget.existingKahoot;
    _titleController = TextEditingController(text: k?.title ?? '');
    _descriptionController = TextEditingController(text: k?.description ?? '');
    _coverController = TextEditingController(text: k?.coverImageId ?? '');
    if (k?.coverImageId != null && k!.coverImageId!.startsWith('http')) {
      _coverUrl = k.coverImageId;
    }
    if (k != null) {
      _visibility = k.visibility ?? 'private';
      _status = k.status ?? 'draft';
      _category = k.category ?? '';
      _questions.addAll(k.questions);
    }
    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _coverController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _categoriesLoading = true;
      _categoriesError = null;
    });
    try {
      final items = await widget.discoveryController.fetchCategories();
      if (!mounted) return;
      items.sort((a, b) => a.name.compareTo(b.name));
      setState(() {
        _categories = items;
        _categoriesLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categoriesLoading = false;
        _categoriesError = 'No pudimos cargar las categorias';
      });
    }
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
        id: widget.existingKahoot?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        coverImageId:
            _coverAssetId ??
            (_coverController.text.trim().isEmpty
                ? null
                : _coverController.text.trim()),
        visibility: _visibility,
        category:
            _category, // Ensure category is sent even if empty string? Mapping handles it?
        status: _status,
        themeId: themeId,
        authorId: authorId,
        questions: _questions,
      );

      final Kahoot saved;
      if (widget.existingKahoot != null) {
        saved = await widget.kahootController.update(kahoot);
      } else {
        saved = await widget.kahootController.create(kahoot);
      }
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

  Future<void> _pickCoverImage() async {
    try {
      setState(() => _coverUploading = true);
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) {
        if (mounted) setState(() => _coverUploading = false);
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
        _coverAssetId = asset.assetId;
        _coverUrl = asset.url;
        _coverController.text = asset.assetId;
        _coverUploading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _coverUploading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al subir imagen: $e')));
    }
  }

  Future<void> _suggestCoverImage() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega un titulo para sugerir imagen')),
      );
      return;
    }
    setState(() => _aiCoverLoading = true);
    try {
      final prompt = description.isEmpty
          ? 'Crea una imagen para un kahoot titulado "$title".'
          : 'Crea una imagen para un kahoot titulado "$title". '
                'Descripcion: $description.';
      final url = await _openAiImageService.generateImageUrl(prompt: prompt);
      if (!mounted) return;
      setState(() {
        _coverUrl = url;
        _coverAssetId = null;
        _coverController.text = url;
        _aiCoverLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _aiCoverLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al sugerir imagen: $e')));
    }
  }

  Future<void> _openCoverLibrary() async {
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
                                setState(() {
                                  _coverAssetId = asset.assetId;
                                  _coverUrl = asset.url;
                                  _coverController.text = asset.assetId;
                                });
                                Navigator.of(context).pop();
                              },
                              child: AnimatedScale(
                                scale: 1,
                                duration: const Duration(milliseconds: 150),
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

  void _openTypeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1A22),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final tiles = [
          {
            'id': 'quiz',
            'label': 'Quiz',
            'icon': Icons.grid_view_rounded,
            'color': const Color(0xFF6C5CE7),
          },
          {
            'id': 'trueFalse',
            'label': 'Verdadero o falso',
            'icon': Icons.rule_rounded,
            'color': const Color(0xFF00B894),
          },
          {
            'id': 'shortAnswer',
            'label': 'Respuesta corta',
            'icon': Icons.short_text_rounded,
            'color': const Color(0xFFFF9F43),
          },
        ];
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Cambiar tipo de pregunta',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Prueba de conocimientos',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tiles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                itemBuilder: (context, index) {
                  final tile = tiles[index];
                  final color = tile['color'] as Color;
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _addQuestion(tile['id'] as String);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2D),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(tile['icon'] as IconData, color: color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tile['label'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
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
    return Scaffold(
      backgroundColor: Colors.transparent,
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
                    : Text(
                        widget.existingKahoot != null ? 'Modificar' : 'Guardar',
                      ),
              ),
            ),
          ],
        ),
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
                _CoverField(
                  controller: _coverController,
                  isUploading: _coverUploading,
                  isAiLoading: _aiCoverLoading,
                  onPick: _pickCoverImage,
                  onLibrary: _openCoverLibrary,
                  onAiSuggest: _suggestCoverImage,
                  previewUrl: _coverUrl,
                ),
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
                  label: 'Estado',
                  child: DropdownButtonFormField<String>(
                    value: _status,
                    dropdownColor: const Color(0xFF1E1A22),
                    decoration: _inputDecoration(),
                    items: const [
                      DropdownMenuItem(value: 'draft', child: Text('Borrador')),
                      DropdownMenuItem(
                        value: 'published',
                        child: Text('Publicado'),
                      ),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _status = v ?? 'draft';
                        if (_status == 'draft') {
                          _visibility = 'private'; // Enforce private draft
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _LabeledField(label: 'Categoría', child: _buildCategoryField()),
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

  Widget _buildCategoryField() {
    if (_categoriesLoading) {
      return TextFormField(
        enabled: false,
        decoration: _inputDecoration().copyWith(
          hintText: 'Cargando categorias...',
        ),
        style: const TextStyle(color: Colors.white54),
      );
    }

    if (_categoriesError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _categoriesError!,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadCategories,
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    final items = _categories
        .map(
          (c) => DropdownMenuItem<String>(value: c.name, child: Text(c.name)),
        )
        .toList();

    return DropdownButtonFormField<String>(
      value: _category.isNotEmpty ? _category : null,
      dropdownColor: const Color(0xFF1E1A22),
      decoration: _inputDecoration().copyWith(
        hintText: 'Selecciona una categoria',
      ),
      items: items,
      onChanged: (value) {
        setState(() {
          _category = value ?? '';
        });
      },
    );
  }

  Future<void> _editQuestion(int index) async {
    final question = _questions[index];
    final updated = await Navigator.of(context).push<KahootQuestion>(
      MaterialPageRoute(
        builder: (_) => QuestionEditorScreen(
          question: question,
          index: index + 1,
          mediaController: widget.mediaController,
        ),
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
  const _CoverField({
    required this.controller,
    required this.onPick,
    required this.onLibrary,
    required this.onAiSuggest,
    required this.isUploading,
    required this.isAiLoading,
    this.previewUrl,
  });

  final TextEditingController controller;
  final VoidCallback onPick;
  final VoidCallback onLibrary;
  final VoidCallback onAiSuggest;
  final bool isUploading;
  final bool isAiLoading;
  final String? previewUrl;

  @override
  Widget build(BuildContext context) {
    final coverUrl =
        previewUrl ??
        (controller.text.trim().startsWith('http')
            ? controller.text.trim()
            : '');
    return GestureDetector(
      onTap: isUploading ? null : onPick,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1A22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          image: coverUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(coverUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            if (coverUrl.isEmpty)
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
              right: 12,
              top: 12,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: onLibrary,
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
                    onPressed: isAiLoading ? null : onAiSuggest,
                    icon: isAiLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(isAiLoading ? 'IA...' : 'IA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black45,
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
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: isUploading ? null : onPick,
                    icon: isUploading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload_outlined, size: 18),
                    label: Text(isUploading ? 'Subiendo...' : 'Subir'),
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
            const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
