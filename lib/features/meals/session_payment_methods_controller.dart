import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_client.dart';
import '../../api/models.dart';
import 'meals_controller.dart';

/// Receiving methods attached to a specific meal session (organizer-only,
/// `requireOwnedMeal` on the backend). These are a copy independent of the
/// account defaults in Settings — editing them here never touches the saved
/// defaults (`/me/payment-methods`).
final sessionPaymentMethodsProvider = FutureProvider.family<List<PaymentMethod>, String>((ref, mealId) async {
  final data = await ref.read(apiClientProvider).getJson('/meals/$mealId/payment-methods');
  return (data['paymentMethods'] as List).cast<Map<String, dynamic>>().map(PaymentMethod.fromJson).toList();
});

class SessionPaymentMethodsRepository {
  SessionPaymentMethodsRepository(this.ref);
  final Ref ref;
  ApiClient get _api => ref.read(apiClientProvider);

  void _refresh(String mealId) {
    ref.invalidate(sessionPaymentMethodsProvider(mealId));
    ref.invalidate(mealDetailProvider(mealId)); // the meal-detail hub shows the same list
  }

  Future<void> add(String mealId, Map<String, dynamic> body) async {
    await _api.postJson('/meals/$mealId/payment-methods', body: body);
    _refresh(mealId);
  }

  Future<void> update(String mealId, String id, Map<String, dynamic> body) async {
    await _api.patchJson('/meals/$mealId/payment-methods/$id', body: body);
    _refresh(mealId);
  }

  Future<void> remove(String mealId, String id) async {
    await _api.delete('/meals/$mealId/payment-methods/$id');
    _refresh(mealId);
  }
}

final sessionPaymentMethodsRepositoryProvider = Provider((ref) => SessionPaymentMethodsRepository(ref));
