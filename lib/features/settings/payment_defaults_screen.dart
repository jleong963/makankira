import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/models.dart';
import '../../l10n/app_localizations.dart';
import 'method_editor.dart';
import 'payment_defaults_controller.dart';
import '../../shared/language_menu.dart';

/// Screen 2B — account-level saved receiving methods.
class PaymentDefaultsScreen extends ConsumerWidget {
  const PaymentDefaultsScreen({super.key});

  Future<void> _showEditor(BuildContext context, WidgetRef ref, {PaymentMethod? method}) {
    final repo = ref.read(paymentDefaultsRepositoryProvider);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: MethodEditorSheet(
          method: method,
          onSubmit: (body, id) => id == null ? repo.add(body) : repo.update(id, body),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final methods = ref.watch(paymentDefaultsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.paymentDefaults), actions: const [LanguageMenu()]),
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
            return Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(l.noSavedMethods)));
          }
          return ListView(
            children: list
                .map((m) => ListTile(
                      leading: const Icon(Icons.account_balance_wallet_outlined),
                      title: Text(methodTypeLabel(l, m.methodType)),
                      subtitle: Text(methodLine(m)),
                      onTap: () => _showEditor(context, ref, method: m),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (m.isDefault) Chip(label: Text(l.defaultLabel), visualDensity: VisualDensity.compact),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => ref.read(paymentDefaultsRepositoryProvider).remove(m.id),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
