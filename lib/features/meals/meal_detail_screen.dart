import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/models.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/browser.dart';
import '../../shared/formatters.dart';
import 'meals_controller.dart';

/// Screen 3/6 hub — meal info + payment methods + links to the sub-screens.
class MealDetailScreen extends ConsumerWidget {
  const MealDetailScreen({super.key, required this.mealId});
  final String mealId;

  String _methodLine(PaymentMethod m) {
    switch (m.methodType) {
      case 'bank_account':
        return [m.bankName, m.accountNumber, m.accountName].where((s) => s != null && s.isNotEmpty).join(' · ');
      case 'duitnow_id':
        return 'DuitNow ID: ${m.duitNowId ?? ''}';
      case 'duitnow_qr':
        return 'DuitNow QR';
      case 'custom':
        return m.instructions ?? '';
      default:
        return m.methodType;
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l.deleteMealConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.delete)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ref.read(mealsProvider.notifier).deleteMeal(mealId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.mealDeleted)));
    context.go('/');
  }

  void _showShare(BuildContext context, String mealId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _ShareSheet(mealId: mealId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final detail = ref.watch(mealDetailProvider(mealId));
    final meal = detail.asData?.value.meal;

    return Scaffold(
      appBar: AppBar(
        // Detail can be reached via context.go (after create/edit) or a direct
        // link, where there's nothing to pop — fall back to the meal listing so
        // there's always a way back.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(switch (detail) {
          AsyncData(:final value) => value.meal.title,
          _ => l.mealSetup,
        }),
        actions: [
          if (meal != null)
            IconButton(
              tooltip: l.shareLink,
              icon: const Icon(Icons.share_outlined),
              onPressed: () => _showShare(context, mealId),
            ),
          if (meal != null)
            IconButton(
              tooltip: l.edit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/meals/$mealId/edit', extra: meal),
            ),
          IconButton(
            tooltip: l.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l.errorTitle}: $e')),
        data: (d) {
          final m = d.meal;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(m.title, style: Theme.of(context).textTheme.titleLarge)),
                          Chip(label: Text(statusLabel(l, m.status)), visualDensity: VisualDensity.compact),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _infoRow(l.restaurant, m.restaurantName),
                      _infoRow(l.mealDateTime, m.mealDateTime == null ? l.notSet : formatDateTime(m.mealDateTime)),
                      if (m.seatDetails != null && m.seatDetails!.isNotEmpty) _infoRow(l.seat, m.seatDetails!),
                      if (m.farewellEnabled) _infoRow(l.farewellMeal, '✓'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(l.paymentMethods, style: Theme.of(context).textTheme.titleMedium),
              if (d.paymentMethods.isEmpty)
                Padding(padding: const EdgeInsets.all(8), child: Text(l.noPaymentMethods))
              else
                ...d.paymentMethods.map((pm) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.account_balance_wallet_outlined),
                      title: Text(_methodLine(pm)),
                    )),
              const SizedBox(height: 16),
              _SectionTile(
                icon: Icons.restaurant_menu,
                label: l.sectionMenu,
                onTap: () => context.push('/meals/$mealId/menu'),
              ),
              _SectionTile(
                icon: Icons.receipt_long,
                label: l.sectionOrders,
                onTap: () => context.push('/meals/$mealId/orders'),
              ),
              _SectionTile(
                icon: Icons.checklist,
                label: l.sectionReview,
                onTap: () => context.push('/meals/$mealId/orders'),
              ),
              _SectionTile(
                icon: Icons.calculate,
                label: l.sectionBill,
                onTap: () => context.push('/meals/$mealId/bill'),
              ),
              _SectionTile(
                icon: Icons.payments,
                label: l.sectionPaymentRequests,
                onTap: () => context.push('/meals/$mealId/payment-requests'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            Expanded(child: Text(value)),
          ],
        ),
      );
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap ?? () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.comingSoon))),
      ),
    );
  }
}

/// Owner Share sheet: shows the invite link with Copy / WhatsApp / Rotate.
/// Watches the meal detail so a rotate immediately shows the new link.
class _ShareSheet extends ConsumerWidget {
  const _ShareSheet({required this.mealId});
  final String mealId;

  String _link(String token) => '${Uri.base.origin}/#/join/$token';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final token = ref.watch(mealDetailProvider(mealId)).asData?.value.meal.inviteToken;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.shareLink, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(l.shareLinkHint, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          if (token == null || token.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(_link(token)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _link(token)));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.copied)));
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: Text(l.copyLink),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => openUrl(
                    'https://wa.me/?text=${Uri.encodeComponent('${l.shareLinkMessage}\n${_link(token)}')}',
                  ),
                  icon: const Icon(Icons.chat, size: 18),
                  label: Text(l.openWhatsApp),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await ref.read(mealsProvider.notifier).rotateInvite(mealId);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.linkRotated)));
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l.rotateLink),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
