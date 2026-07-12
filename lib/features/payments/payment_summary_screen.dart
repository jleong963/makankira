import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/api_client.dart';
import '../../api/models.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/browser.dart';
import '../../shared/formatters.dart';
import '../billing/bill_controller.dart';
import '../meals/meals_controller.dart';

/// Read-only payment summary: the full breakdown per person and the final
/// amount each owes the organizer, plus the grand total payable to the
/// organizer and how to pay them. Reached from the meal-detail hub, below the
/// payment-requests tile.
class PaymentSummaryScreen extends ConsumerWidget {
  const PaymentSummaryScreen({super.key, required this.mealId});
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final results = ref.watch(paymentResultsProvider(mealId));
    final detail = ref.watch(mealDetailProvider(mealId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l.sectionPaymentSummary),
        actions: [
          results.maybeWhen(
            data: (list) => list.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: l.exportExcel,
                    icon: const Icon(Icons.download),
                    onPressed: () => downloadUrl(
                      ref
                          .read(apiClientProvider)
                          .fileUri('/meals/$mealId/export/payment-calculation.xlsx')
                          .toString(),
                    ),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: results.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l.errorTitle}: $e')),
        data: (list) {
          if (list.isEmpty) return _EmptyState(mealId: mealId);
          final grandTotal = list.fold<int>(0, (sum, r) => sum + r.totalDueCents);
          final d = detail.asData?.value;
          final organizerName = d?.meal.organizerName;
          final methods = d?.paymentMethods ?? const <PaymentMethod>[];
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  _TotalCard(total: grandTotal, organizerName: organizerName),
                  const SizedBox(height: 20),
                  _SectionHeader(label: l.results),
                  const SizedBox(height: 8),
                  ...list.map((r) => _PersonCard(result: r)),
                  if (methods.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionHeader(label: l.howToPay),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: [
                          for (var i = 0; i < methods.length; i++) ...[
                            if (i > 0) const Divider(height: 1, indent: 56),
                            ListTile(
                              leading: const Icon(Icons.account_balance_wallet_outlined),
                              title: Text(_methodLine(methods[i])),
                              dense: true,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Grand-total hero: the final amount the organizer should collect.
class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total, this.organizerName});
  final int total;
  final String? organizerName;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.request_quote_outlined, color: scheme.onPrimaryContainer, size: 20),
                const SizedBox(width: 8),
                Text(
                  l.payableToOrganizer,
                  style: text.titleSmall?.copyWith(color: scheme.onPrimaryContainer),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              formatRM(total),
              style: text.headlineMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (organizerName != null && organizerName!.isNotEmpty)
                  ? '${l.paymentSummaryHint} · ${l.organizerName}: $organizerName'
                  : l.paymentSummaryHint,
              style: text.bodySmall?.copyWith(color: scheme.onPrimaryContainer.withValues(alpha: 0.85)),
            ),
          ],
        ),
      ),
    );
  }
}

/// One participant: full breakdown line, their final amount due, and status.
class _PersonCard extends StatelessWidget {
  const _PersonCard({required this.result});
  final PaymentResult result;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final r = result;
    final paid = r.paymentStatus == 'paid';
    final parts = <String>[
      '${l.subtotal} ${formatRM(r.subtotalCents)}',
      if (r.farewellSponsoredShareCents > 0) '${l.farewellShareLabel} ${formatRM(r.farewellSponsoredShareCents)}',
      if (r.taxCents + r.serviceChargeCents > 0) '+${formatRM(r.taxCents + r.serviceChargeCents)}',
      if (r.discountCents > 0) '-${formatRM(r.discountCents)}',
      if (r.companyClaimCents > 0) '-${formatRM(r.companyClaimCents)}',
      if (r.roundingAdjustmentCents != 0) formatRM(r.roundingAdjustmentCents),
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    r.participantName,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (r.isHonoree) ...[
                  const SizedBox(width: 8),
                  Chip(label: Text(l.roleHonoree), visualDensity: VisualDensity.compact),
                ],
                const SizedBox(width: 8),
                Text(formatRM(r.totalDueCents), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 6),
            Text(parts.join(' · '), style: Theme.of(context).textTheme.bodySmall),
            if (!r.isHonoree) ...[
              const SizedBox(height: 8),
              _StatusChip(paid: paid),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.paid});
  final bool paid;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(
        paid ? Icons.check_circle : Icons.schedule,
        size: 18,
        color: paid ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
      ),
      label: Text(paid ? l.paid : l.pending),
      backgroundColor: paid ? scheme.secondaryContainer : scheme.surfaceContainerHighest,
    );
  }
}

/// Shown before any calculation exists — points the organizer to the bill step.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.mealId});
  final String mealId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.request_quote_outlined, size: 48, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(l.paymentSummaryEmpty, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.push('/meals/$mealId/bill'),
              icon: const Icon(Icons.calculate),
              label: Text(l.sectionBill),
            ),
          ],
        ),
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
