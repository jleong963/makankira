import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_client.dart';
import '../../api/models.dart';

/// The menu-reference images attached to one meal (organizer-scoped GET). The
/// participant view gets its images inline from member-view instead.
final menuImagesProvider = FutureProvider.family<List<MenuImage>, String>((ref, mealId) async {
  final data = await ref.read(apiClientProvider).getJson('/meals/$mealId/menu-images');
  return (data['menuImages'] as List? ?? const [])
      .cast<Map<String, dynamic>>()
      .map(MenuImage.fromJson)
      .toList();
});

/// Upload / delete menu-reference images for a meal. Uploads reuse the generic
/// POST /files endpoint (fileKind=menu_image, tied to the meal); deletes use
/// DELETE /files/:id (owner-scoped). Both refresh [menuImagesProvider].
class MenuImagesRepository {
  MenuImagesRepository(this.ref);
  final Ref ref;

  Future<MenuImage> upload(
    String mealId,
    Uint8List bytes, {
    required String filename,
    required String contentType,
  }) async {
    final data = await ref.read(apiClientProvider).uploadBytes(
          '/files',
          bytes,
          contentType: contentType,
          query: {'fileKind': 'menu_image', 'mealId': mealId, 'filename': filename},
        );
    ref.invalidate(menuImagesProvider(mealId));
    return MenuImage.fromJson(data);
  }

  Future<void> delete(String mealId, String fileId) async {
    await ref.read(apiClientProvider).delete('/files/$fileId');
    ref.invalidate(menuImagesProvider(mealId));
  }
}

final menuImagesRepositoryProvider = Provider<MenuImagesRepository>(MenuImagesRepository.new);

/// image/* content type inferred from a picked file's extension, matching the
/// server's allow-list (PNG / JPG / JPEG / WebP). Defaults to JPEG.
String imageContentTypeForExtension(String? extension) {
  switch ((extension ?? '').toLowerCase()) {
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    default:
      return 'image/jpeg';
  }
}
