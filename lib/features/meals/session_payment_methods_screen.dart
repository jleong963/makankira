import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/models.dart';
import '../../l10n/app_localizations.dart';
import '../settings/method_editor.dart';
import 'session_payment_methods_controller.dart';

/// Per-meal-session receiving methods, editable by the organizer (add / edit /
/// delete). Independent of the account defaults in Settings — changes here only
/// affect this meal session. Reached from the meal-detail hub.
class SessionPaymentMethodsScreen extends ConsumerWidget {
  const SessionPaymentMethodsScreen({super.key, required this.mealId});
  final String mealId;

  Future<void> _showEditor(BuildContext context, WidgetRef ref, {PaymentMethod? method}) {
    final repo = ref.read(sessionPaymentMethodsRepositoryProvider);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: MethodEditorSheet(
          method: method,
          showDefault: false,
          onSubmit: (body, id) => id == null ? repo.add(mealId, body) : repo.update(mealId, id, body),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final methods = ref.watch(sessionPaymentMethodsProvider(mealId));
    return Scaffold(
      appBar: AppBar(title: Text(l.paymentMethods)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l.addPaymentMethod),
      ),
      body: methods.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l.errorTitle}: $e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(l.noPaymentMethods)));
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: list
                .map((m) => ListTile(
                      leading: const Icon(Icons.account_balance_wallet_outlined),
                      title: Text(methodTypeLabel(l, m.methodType)),
                      subtitle: Text(methodLine(m)),
                      onTap: () => _showEditor(context, ref, method: m),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref.read(sessionPaymentMethodsRepositoryProvider).remove(mealId, m.id),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
