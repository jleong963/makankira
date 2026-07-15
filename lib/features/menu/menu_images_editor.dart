import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/models.dart';
import '../../l10n/app_localizations.dart';
import 'menu_images_controller.dart';

const double _thumbSize = 92;

/// Open a full-screen, zoomable viewer over [urls], starting at [initialIndex].
void openMenuImageViewer(BuildContext context, List<String> urls, int initialIndex) {
  if (urls.isEmpty) return;
  showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => _MenuImageViewer(urls: urls, initialIndex: initialIndex),
  );
}

class _MenuImageViewer extends StatefulWidget {
  const _MenuImageViewer({required this.urls, required this.initialIndex});
  final List<String> urls;
  final int initialIndex;

  @override
  State<_MenuImageViewer> createState() => _MenuImageViewerState();
}

class _MenuImageViewerState extends State<_MenuImageViewer> {
  late final PageController _controller = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Center(
                child: Image.network(
                  widget.urls[i],
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: IconButton.filledTonal(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          if (widget.urls.length > 1)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_index + 1} / ${widget.urls.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One rounded image thumbnail. Tapping it opens the full-screen viewer; when
/// [onRemove] is given, a small delete badge is shown (editor mode).
class MenuImageThumb extends StatelessWidget {
  const MenuImageThumb({super.key, required this.url, this.onTap, this.onRemove});
  final String url;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget placeholder(Widget child) => Container(
          color: scheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: child,
        );
    return SizedBox(
      width: _thumbSize,
      height: _thumbSize,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onTap: onTap,
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : placeholder(const SizedBox(
                          height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))),
                  errorBuilder: (_, _, _) =>
                      placeholder(Icon(Icons.broken_image_outlined, color: scheme.onSurfaceVariant)),
                ),
              ),
            ),
          ),
          // A subtle border so light images stay visible on a light surface.
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outlineVariant),
                ),
              ),
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: 2,
              right: 2,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onRemove,
                  child: const Padding(
                    padding: EdgeInsets.all(3),
                    child: Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Read-only horizontal-wrapping gallery of menu photos (meal detail hub +
/// participant view). Tapping any thumb opens the zoomable viewer.
class MenuImageGallery extends StatelessWidget {
  const MenuImageGallery({super.key, required this.urls});
  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < urls.length; i++)
          MenuImageThumb(url: urls[i], onTap: () => openMenuImageViewer(context, urls, i)),
      ],
    );
  }
}

/// Editable menu-photo strip for an existing meal: shows current photos (tap to
/// view, badge to remove) and an "Add photos" button that multi-picks images and
/// uploads them immediately (the meal already exists, so each upload is tied to
/// it). Used in the meal setup screen's Edit mode and reusable elsewhere.
class MenuImagesEditor extends ConsumerStatefulWidget {
  const MenuImagesEditor({super.key, required this.mealId});
  final String mealId;

  @override
  ConsumerState<MenuImagesEditor> createState() => _MenuImagesEditorState();
}

class _MenuImagesEditorState extends ConsumerState<MenuImagesEditor> {
  bool _busy = false;

  Future<void> _add() async {
    final l = AppLocalizations.of(context);
    final res = await FilePicker.pickFiles(type: FileType.image, allowMultiple: true, withData: true);
    if (res == null || res.files.isEmpty) return;
    setState(() => _busy = true);
    final repo = ref.read(menuImagesRepositoryProvider);
    var failures = 0;
    for (final f in res.files) {
      final bytes = f.bytes;
      if (bytes == null) {
        failures++;
        continue;
      }
      try {
        await repo.upload(
          widget.mealId,
          bytes,
          filename: f.name,
          contentType: imageContentTypeForExtension(f.extension),
        );
      } catch (_) {
        failures++;
      }
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (failures > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.photosUploadFailed), duration: const Duration(seconds: 6)),
      );
    }
  }

  Future<void> _remove(MenuImage img) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l.removePhotoConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.delete)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(menuImagesRepositoryProvider).delete(widget.mealId, img.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(menuImagesProvider(widget.mealId));
    final urls = async.asData?.value.map((e) => e.url).toList() ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...async.asData?.value.asMap().entries.map(
                      (e) => MenuImageThumb(
                        url: e.value.url,
                        onTap: () => openMenuImageViewer(context, urls, e.key),
                        onRemove: _busy ? null : () => _remove(e.value),
                      ),
                    ) ??
                const [],
            OutlinedButton.icon(
              onPressed: _busy ? null : _add,
              icon: _busy
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add_photo_alternate_outlined),
              label: Text(l.addPhotos),
            ),
          ],
        ),
        if (async.hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('${async.error}', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
      ],
    );
  }
}
