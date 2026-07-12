import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_client.dart';
import '../../api/models.dart';
import '../meals/meals_controller.dart';

/// Participant (invite-link) access: join a meal, view it, and manage own order.

/// The member view for a joined meal (meal + menu + live orders + my order).
final memberViewProvider = FutureProvider.family<MemberMealView, String>((ref, mealId) async {
  final data = await ref.read(apiClientProvider).getJson('/meals/$mealId/member-view');
  return MemberMealView.fromJson(data);
});

/// A participant's own bill: their result (null until the organizer calculates)
/// and how to pay the organizer. Never includes other participants' amounts.
class MyPayment {
  final PaymentResult? result;
  final List<PaymentMethod> paymentMethods;
  MyPayment({this.result, required this.paymentMethods});
}

final myPaymentProvider = FutureProvider.family<MyPayment, String>((ref, mealId) async {
  final data = await ref.read(apiClientProvider).getJson('/meals/$mealId/my-payment');
  final r = data['result'];
  return MyPayment(
    result: r == null ? null : PaymentResult.fromJson(r as Map<String, dynamic>),
    paymentMethods: (data['paymentMethods'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(PaymentMethod.fromJson)
        .toList(),
  );
});

class ParticipantRepository {
  ParticipantRepository(this.ref);
  final Ref ref;
  ApiClient get _api => ref.read(apiClientProvider);

  /// Join a meal by its invite token; returns the meal id to open.
  Future<String> join(String token) async {
    final data = await _api.postJson('/join/$token');
    return data['mealId'] as String;
  }

  /// Create or update the caller's own order.
  Future<void> saveMyOrder(String mealId, Map<String, dynamic> body) async {
    await _api.putJson('/meals/$mealId/my-order', body: body);
    ref.invalidate(memberViewProvider(mealId));
  }

  /// Withdraw the caller's own order.
  Future<void> deleteMyOrder(String mealId) async {
    await _api.delete('/meals/$mealId/my-order');
    ref.invalidate(memberViewProvider(mealId));
  }

  /// Leave the meal (removes it from the dashboard; the order is kept).
  Future<void> leave(String mealId) async {
    await _api.delete('/meals/$mealId/membership');
    ref.invalidate(mealsProvider);
  }
}

final participantRepositoryProvider = Provider((ref) => ParticipantRepository(ref));
