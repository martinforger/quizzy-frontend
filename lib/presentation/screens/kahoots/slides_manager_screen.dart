import 'package:flutter/material.dart';
import 'package:quizzy/domain/kahoots/entities/slide.dart';
import 'package:quizzy/presentation/screens/kahoots/slide_editor_screen.dart';
import 'package:quizzy/presentation/state/slide_controller.dart';

class SlidesManagerScreen extends StatefulWidget {
  const SlidesManagerScreen({
    super.key,
    required this.slideController,
    this.initialKahootId = 'q4',
  });

  final SlideController slideController;
  final String initialKahootId;

  @override
  State<SlidesManagerScreen> createState() => _SlidesManagerScreenState();
}

class _SlidesManagerScreenState extends State<SlidesManagerScreen> {
  late TextEditingController _kahootController;
  Future<List<Slide>>? _slidesFuture;
  String? _error;

  @override
  void initState() {
    super.initState();
    _kahootController = TextEditingController(text: widget.initialKahootId);
    _loadSlides();
  }

  @override
  void dispose() {
    _kahootController.dispose();
    super.dispose();
  }

  void _loadSlides() {
    final kahootId = _kahootController.text.trim();
    if (kahootId.isEmpty) return;
    setState(() {
      _error = null;
      _slidesFuture = widget.slideController.listSlides(kahootId);
    });
  }

  Future<void> _onEdit(Slide? slide) async {
    final kahootId = _kahootController.text.trim();
    final result = await Navigator.of(context).push<Slide?>(
      MaterialPageRoute(
        builder: (_) => SlideEditorScreen(
          slideController: widget.slideController,
          kahootId: kahootId,
          slide: slide,
        ),
      ),
    );
    if (result != null) {
      _loadSlides();
    }
  }

  Future<void> _onDuplicate(Slide slide) async {
    final kahootId = _kahootController.text.trim();
    try {
      await widget.slideController.duplicateSlide(kahootId, slide.id);
      _loadSlides();
    } catch (e) {
      setState(() => _error = 'No se pudo duplicar: $e');
    }
  }

  Future<void> _onDelete(Slide slide) async {
    final kahootId = _kahootController.text.trim();
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Eliminar pregunta'),
            content: const Text('¿Seguro que quieres eliminar esta pregunta?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    try {
      await widget.slideController.deleteSlide(kahootId, slide.id);
      _loadSlides();
    } catch (e) {
      setState(() => _error = 'No se pudo eliminar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Slides'),
        actions: [
          IconButton(
            onPressed: _loadSlides,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onEdit(null),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _kahootController,
                    decoration: const InputDecoration(
                      labelText: 'Kahoot ID',
                      hintText: 'p.e. q4',
                    ),
                    onSubmitted: (_) => _loadSlides(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _loadSlides,
                  child: const Text('Cargar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            Expanded(
              child: _slidesFuture == null
                  ? const Center(child: Text('Ingresa un Kahoot ID para cargar preguntas'))
                  : FutureBuilder<List<Slide>>(
                      future: _slidesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        final slides = snapshot.data ?? [];
                        if (slides.isEmpty) {
                          return const Center(child: Text('Sin preguntas aún'));
                        }
                        return ListView.separated(
                          itemCount: slides.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final slide = slides[index];
                            return _SlideTile(
                              slide: slide,
                              onEdit: () => _onEdit(slide),
                              onDuplicate: () => _onDuplicate(slide),
                              onDelete: () => _onDelete(slide),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideTile extends StatelessWidget {
  const _SlideTile({
    required this.slide,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  final Slide slide;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(slide.text),
        subtitle: Text('${slide.type.name} · ${slide.options.length} opciones'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: onDuplicate, icon: const Icon(Icons.copy)),
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_forever)),
          ],
        ),
      ),
    );
  }
}
