import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/brand.dart';
import '../../api/models.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/browser.dart';
import '../../shared/formatters.dart';
import '../menu/menu_images_controller.dart';
import '../menu/menu_images_editor.dart';
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
          final text = Theme.of(context).textTheme;
          final scheme = Theme.of(context).colorScheme;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              // Meal hero card.
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text(m.title, style: text.titleLarge)),
                          const SizedBox(width: 8),
                          StatusPill(status: m.status, label: statusLabel(l, m.status)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (m.restaurantName.isNotEmpty)
                        _InfoRow(icon: Icons.storefront_outlined, text: m.restaurantName),
                      _InfoRow(
                        icon: Icons.schedule_rounded,
                        text: m.mealDateTime == null ? l.notSet : formatDateTime(m.mealDateTime),
                      ),
                      if (m.seatDetails != null && m.seatDetails!.isNotEmpty)
                        _InfoRow(icon: Icons.event_seat_outlined, text: m.seatDetails!),
                      if (m.farewellEnabled)
                        _InfoRow(icon: Icons.celebration_outlined, text: l.farewellMeal, accent: MkColors.amberDark),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Menu reference: the menu link and/or uploaded menu photos. Managed
              // from the meal's Edit screen (same place the organizer sets them).
              _MenuReferenceSection(mealId: mealId, meal: m),
              const SizedBox(height: 20),
              // Payment methods (editable per-session; independent of Settings defaults).
              Row(
                children: [
                  Expanded(child: _SectionHeader(label: l.paymentMethods)),
                  TextButton.icon(
                    onPressed: () => context.push('/meals/$mealId/payment-methods'),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(l.manage),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (d.paymentMethods.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, color: scheme.onSurfaceVariant, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(l.noPaymentMethods,
                              style: TextStyle(color: scheme.onSurfaceVariant)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (var i = 0; i < d.paymentMethods.length; i++) ...[
                        if (i > 0) const Divider(height: 1, indent: 56),
                        ListTile(
                          leading: const Icon(Icons.account_balance_wallet_outlined),
                          title: Text(_methodLine(d.paymentMethods[i])),
                          dense: true,
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              // Meal-flow sections.
              _SectionHeader(label: l.mealSetup),
              const SizedBox(height: 8),
              _SectionTile(
                icon: Icons.restaurant_menu,
                label: l.sectionMenu,
                color: const Color(0xFF00B14F),
                onTap: () => context.push('/meals/$mealId/menu'),
              ),
              _SectionTile(
                icon: Icons.receipt_long,
                label: l.sectionOrders,
                color: const Color(0xFF2E7CF6),
                onTap: () => context.push('/meals/$mealId/orders'),
              ),
              _SectionTile(
                icon: Icons.checklist,
                label: l.sectionReview,
                color: const Color(0xFF009688),
                onTap: () => context.push('/meals/$mealId/orders'),
              ),
              _SectionTile(
                icon: Icons.calculate,
                label: l.sectionBill,
                color: const Color(0xFFEF9A00),
                onTap: () => context.push('/meals/$mealId/bill'),
              ),
              _SectionTile(
                icon: Icons.payments,
                label: l.sectionPaymentRequests,
                color: const Color(0xFF7C4DFF),
                onTap: () => context.push('/meals/$mealId/payment-requests'),
              ),
              _SectionTile(
                icon: Icons.request_quote,
                label: l.sectionPaymentSummary,
                color: const Color(0xFF3F51B5),
                onTap: () => context.push('/meals/$mealId/payment-summary'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}

/// Menu reference card: the menu link and/or uploaded menu photos, with a
/// "Manage" affordance to the meal's Edit screen. Read-only here; tapping a
/// photo opens the full-screen viewer.
class _MenuReferenceSection extends ConsumerWidget {
  const _MenuReferenceSection({required this.mealId, required this.meal});
  final String mealId;
  final MealSession meal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final imagesAsync = ref.watch(menuImagesProvider(mealId));
    final urls = imagesAsync.asData?.value.map((e) => e.url).toList() ?? const <String>[];
    final menuUrl = meal.menuUrl;
    final hasUrl = menuUrl != null && menuUrl.isNotEmpty;
    // While the photos are still loading and there's no link to show, hold the
    // card blank rather than briefly flashing the "nothing yet" message.
    final loadingOnly = !hasUrl && urls.isEmpty && imagesAsync.isLoading;
    final empty = !hasUrl && urls.isEmpty && !imagesAsync.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _SectionHeader(label: l.menuReference)),
            TextButton.icon(
              onPressed: () => context.push('/meals/$mealId/edit', extra: meal),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(l.manage),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: loadingOnly
                ? const Center(
                    child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : empty
                ? Row(
                    children: [
                      Icon(Icons.restaurant_menu, color: scheme.onSurfaceVariant, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l.noMenuReference, style: TextStyle(color: scheme.onSurfaceVariant))),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasUrl)
                        InkWell(
                          onTap: () => openUrl(ensureUrlScheme(menuUrl)),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.link, size: 18, color: scheme.onSurfaceVariant),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    menuUrl,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: scheme.primary),
                                  ),
                                ),
                                Icon(Icons.open_in_new, size: 16, color: scheme.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ),
                      if (hasUrl && urls.isNotEmpty) const Divider(height: 20),
                      if (urls.isNotEmpty) MenuImageGallery(urls: urls),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.accent});
  final IconData icon;
  final String text;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: accent ?? scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.5,
                color: accent ?? scheme.onSurface,
                fontWeight: accent != null ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.icon, required this.label, required this.color, this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          onTap: onTap ?? () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.comingSoon))),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(child: Text(label, style: Theme.of(context).textTheme.titleSmall)),
                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
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
                borderRadius: BorderRadius.circular(12),
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
