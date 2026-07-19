import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../api/models.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/browser.dart';
import '../../shared/formatters.dart';
import '../../shared/phone_field.dart';
import '../auth/auth_controller.dart';
import '../menu/menu_images_editor.dart';
import 'participant_controller.dart';
import '../../shared/language_menu.dart';

/// Participant view of a meal they joined via an invite link: meal info, their
/// own order (add / edit / withdraw), and everyone's orders (read-only). Editing
/// or deleting other people's orders is not possible here — only the organizer
/// can, from the owner screens.
class ParticipantMealScreen extends ConsumerWidget {
  const ParticipantMealScreen({super.key, required this.mealId});
  final String mealId;

  bool _collecting(String status) => status == 'draft' || status == 'collecting_orders';

  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l.leaveMealConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.leaveMeal)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ref.read(participantRepositoryProvider).leave(mealId);
    if (!context.mounted) return;
    context.go('/');
  }

  Future<void> _withdraw(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l.deleteOrderConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.delete)),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(participantRepositoryProvider).deleteMyOrder(mealId);
  }

  Future<void> _editOrder(BuildContext context, MemberMealView v) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _MyOrderEditor(mealId: mealId, menu: v.menu, existing: v.myOrder),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final view = ref.watch(memberViewProvider(mealId));
    final menuUrl = view.asData?.value.meal.menuUrl;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(view.asData?.value.meal.title ?? l.mealSessions),
        actions: [
          const LanguageMenu(),
          if (menuUrl != null && menuUrl.isNotEmpty)
            IconButton(
              tooltip: l.menuUrl,
              icon: const Icon(Icons.open_in_new),
              onPressed: () => openUrl(ensureUrlScheme(menuUrl)),
            ),
          IconButton(
            tooltip: l.leaveMeal,
            icon: const Icon(Icons.logout),
            onPressed: () => _leave(context, ref),
          ),
        ],
      ),
      body: view.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l.errorTitle}: $e')),
        data: (v) {
          final collecting = _collecting(v.meal.status);
          final rows = v.orders.cast<Map<String, dynamic>>();
          final others = rows.where((o) => o['participantOrderId'] != v.myOrder?.id).toList();
          final myRow = rows.where((o) => o['participantOrderId'] == v.myOrder?.id).firstOrNull;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MealHeader(meal: v.meal),
              if (v.menuImages.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(l.menuPhotos, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                MenuImageGallery(urls: v.menuImages.map((e) => e.url).toList()),
              ],
              const SizedBox(height: 16),
              Text(l.yourOrder, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (v.myOrder != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Honoree status is set by the organizer; shown here read-only.
                        if (myRow?['role'] == 'farewell_honoree')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Chip(
                              avatar: const Icon(Icons.card_giftcard, size: 18),
                              label: Text(l.roleHonoree),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ..._itemLines(myRow),
                        const SizedBox(height: 8),
                        if (collecting)
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () => _editOrder(context, v),
                                icon: const Icon(Icons.edit, size: 18),
                                label: Text(l.edit),
                              ),
                              TextButton.icon(
                                onPressed: () => _withdraw(context, ref),
                                icon: const Icon(Icons.delete_outline, size: 18),
                                label: Text(l.withdrawOrder),
                              ),
                            ],
                          )
                        else
                          Text(l.ordersClosed, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                )
              else if (collecting)
                FilledButton.icon(
                  onPressed: () => _editOrder(context, v),
                  icon: const Icon(Icons.add),
                  label: Text(l.addYourOrder),
                )
              else
                Text(l.ordersClosed, style: Theme.of(context).textTheme.bodySmall),
              const Divider(height: 32),
              _MyPaymentSection(mealId: mealId),
              const Divider(height: 32),
              Text(l.everyonesOrders, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (others.isEmpty)
                Text(l.noOrders, style: Theme.of(context).textTheme.bodyMedium)
              else
                ...others.map((o) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    o['participantName'] as String? ?? '',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),
                                if (o['role'] == 'farewell_honoree') ...[
                                  const SizedBox(width: 8),
                                  Chip(label: Text(l.roleHonoree), visualDensity: VisualDensity.compact),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            ..._itemLines(o),
                          ],
                        ),
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }

  /// Render the per-item lines of a live-order-summary row (read-only).
  List<Widget> _itemLines(Map<String, dynamic>? row) {
    final items = (row?['items'] as List? ?? const []).cast<Map<String, dynamic>>();
    if (items.isEmpty) return const [Text('—')];
    return items.map((it) {
      final remarks = (it['remarks'] as String?) ?? '';
      return Text(
        '• ${it['itemName']} ×${it['quantity']}${remarks.isNotEmpty ? ' — $remarks' : ''}',
      );
    }).toList();
  }
}

class _MealHeader extends StatelessWidget {
  const _MealHeader({required this.meal});
  final MealSession meal;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meal.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _row(l.restaurant, meal.restaurantName),
            _row(l.mealDateTime, meal.mealDateTime == null ? l.notSet : formatDateTime(meal.mealDateTime)),
            if (meal.organizerName != null && meal.organizerName!.isNotEmpty)
              _row(l.organizerName, meal.organizerName!),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 110, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            Expanded(child: Text(value)),
          ],
        ),
      );
}

/// The participant's OWN bill: their final amount, breakdown, payment status,
/// and how to pay the organizer. Loads independently of the order view; shows a
/// gentle "not ready" state until the organizer has calculated the bill.
class _MyPaymentSection extends ConsumerWidget {
  const _MyPaymentSection({required this.mealId});
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
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final async = ref.watch(myPaymentProvider(mealId));

    Widget shell(Widget child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.whatYouOwe, style: text.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        );

    return async.when(
      loading: () => shell(const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
        ),
      )),
      // Don't let a payment fetch error block the order screen — just hide it.
      error: (e, _) => const SizedBox.shrink(),
      data: (mp) {
        final r = mp.result;
        if (r == null) {
          return shell(Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.hourglass_empty, color: scheme.onSurfaceVariant, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l.paymentPending, style: TextStyle(color: scheme.onSurfaceVariant))),
                ],
              ),
            ),
          ));
        }
        if (r.isHonoree) {
          return shell(Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.card_giftcard, color: scheme.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l.honoreeNoPay)),
                ],
              ),
            ),
          ));
        }
        final paid = r.paymentStatus == 'paid';
        final parts = <String>[
          '${l.subtotal} ${formatRM(r.subtotalCents)}',
          if (r.farewellSponsoredShareCents > 0) '${l.farewellShareLabel} ${formatRM(r.farewellSponsoredShareCents)}',
          if (r.taxCents + r.serviceChargeCents > 0) '+${formatRM(r.taxCents + r.serviceChargeCents)}',
          if (r.discountCents > 0) '-${formatRM(r.discountCents)}',
          if (r.companyClaimCents > 0) '-${formatRM(r.companyClaimCents)}',
          if (r.roundingAdjustmentCents != 0) formatRM(r.roundingAdjustmentCents),
        ];
        return shell(Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        formatRM(r.totalDueCents),
                        style: text.headlineSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: Icon(
                        paid ? Icons.check_circle : Icons.schedule,
                        size: 18,
                        color: paid ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
                      ),
                      label: Text(paid ? l.paid : l.pending),
                      backgroundColor: paid ? scheme.secondaryContainer : scheme.surfaceContainerHighest,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(parts.join(' · '), style: text.bodySmall),
                if (mp.paymentMethods.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(l.howToPay, style: text.titleSmall),
                  const SizedBox(height: 6),
                  ...mp.paymentMethods.map((m) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, size: 18, color: scheme.onSurfaceVariant),
                            const SizedBox(width: 10),
                            Expanded(child: Text(_methodLine(m))),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ));
      },
    );
  }
}

/// Bottom-sheet editor for the participant's own order.
class _MyOrderEditor extends ConsumerStatefulWidget {
  const _MyOrderEditor({required this.mealId, required this.menu, this.existing});
  final String mealId;
  final List<MenuItem> menu;
  final ParticipantOrder? existing;

  @override
  ConsumerState<_MyOrderEditor> createState() => _MyOrderEditorState();
}

class _MyOrderEditorState extends ConsumerState<_MyOrderEditor> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final Map<String, int> _qty = {};
  final Map<String, String> _remarks = {};
  // Local, mutable copy of the orderable menu. Items the participant adds in
  // this session are appended here with a temporary id and tracked in
  // [_pendingIds]; they're only created on the server at save time (and only if
  // still ordered), so adding an item then cancelling never leaves an orphan in
  // the shared menu.
  late List<MenuItem> _items;
  final Set<String> _pendingIds = {};
  int _tempSeq = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _items = widget.menu.where((i) => i.available).toList();
    final existing = widget.existing;
    if (existing != null) {
      _name.text = existing.participantName;
      _mobile.text = existing.mobileNumber ?? '';
      for (final it in existing.items) {
        _qty[it.menuItemId] = it.quantity;
        if (it.remarks != null && it.remarks!.isNotEmpty) _remarks[it.menuItemId] = it.remarks!;
      }
    } else {
      final auth = ref.read(authProvider);
      final user = auth is AsyncData<AppUser?> ? auth.value : null;
      _name.text = user?.displayName ?? '';
      _mobile.text = user?.mobileNumber ?? '';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    final selected = _qty.entries.where((e) => e.value > 0).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.selectItems)));
      return;
    }
    // Build the items payload. A participant-added (pending) entry is sent as an
    // inline `newItem`, so the server creates the menu item and saves the order
    // in one atomic call — a failed save can't leave an orphan item behind, and
    // an item added-then-unselected is simply never sent.
    final items = selected.map((e) {
      final r = (_remarks[e.key] ?? '').trim();
      final item = <String, dynamic>{'quantity': e.value};
      if (r.isNotEmpty) item['remarks'] = r;
      if (_pendingIds.contains(e.key)) {
        final draft = _items.firstWhere((i) => i.id == e.key);
        final newItem = <String, dynamic>{'name': draft.name};
        if (draft.estimatedPriceCents != null) newItem['estimatedPriceCents'] = draft.estimatedPriceCents;
        item['newItem'] = newItem;
      } else {
        item['menuItemId'] = e.key;
      }
      return item;
    }).toList();
    final mobile = _mobile.text.trim();
    setState(() => _saving = true);
    try {
      await ref.read(participantRepositoryProvider).saveMyOrder(widget.mealId, {
        'participantName': _name.text.trim(),
        'mobileNumber': mobile,
        'items': items,
      });
      // Remember the number on the user's profile the first time they enter it,
      // so every later form is prefilled ("type once"). Best-effort — never fail
      // the order over this.
      final auth = ref.read(authProvider);
      final user = auth is AsyncData<AppUser?> ? auth.value : null;
      if (user != null && (user.mobileNumber == null || user.mobileNumber!.isEmpty) && mobile.isNotEmpty) {
        try {
          await ref.read(authProvider.notifier).updateProfile({'mobileNumber': mobile});
        } catch (_) {/* ignore */}
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      setState(() => _saving = false);
    }
  }

  /// Add an item the organizer didn't list, as a local pending entry preselected
  /// at qty 1. Name is required; price is optional — the organizer confirms the
  /// actual price at the bill step. Nothing is persisted here: the item only
  /// reaches the shared menu when the order is saved (see [_save]).
  Future<void> _addNewItem() async {
    final l = AppLocalizations.of(context);
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.addNewMenuItem),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.addNewItemHint, style: Theme.of(ctx).textTheme.bodySmall),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameCtrl,
                autofocus: true,
                decoration: InputDecoration(labelText: l.itemName),
                validator: (v) => (v == null || v.trim().isEmpty) ? l.required : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: priceCtrl,
                decoration: InputDecoration(labelText: l.estimatedPrice),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: Text(l.add),
          ),
        ],
      ),
    );
    final name = nameCtrl.text.trim();
    final price = parseRMToCents(priceCtrl.text);
    nameCtrl.dispose();
    priceCtrl.dispose();
    if (confirmed != true || name.isEmpty || !mounted) return;
    setState(() {
      final tempId = '__pending_${_tempSeq++}';
      _items = [..._items, MenuItem(id: tempId, name: name, estimatedPriceCents: price)];
      _pendingIds.add(tempId);
      _qty[tempId] = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.yourOrder, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: l.participantName),
              validator: (v) => (v == null || v.trim().isEmpty) ? l.required : null,
            ),
            const SizedBox(height: 12),
            PhoneField(
              controller: _mobile,
              labelText: l.mobileNumber,
              validator: (national) => national.isEmpty ? l.required : null,
            ),
            const Divider(height: 24),
            if (_items.isEmpty)
              Padding(padding: const EdgeInsets.all(8), child: Text(l.noMenuItems)),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ..._items.map(_itemRow),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _saving ? null : _addNewItem,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(l.addNewMenuItem),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemRow(MenuItem item) {
    final l = AppLocalizations.of(context);
    final q = _qty[item.id] ?? 0;
    final price = item.actualPriceCents ?? item.estimatedPriceCents;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(item.name),
          subtitle: price == null ? null : Text(formatRM(price)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: q > 0 ? () => setState(() => _qty[item.id] = q - 1) : null,
              ),
              Text('$q'),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => setState(() => _qty[item.id] = q + 1),
              ),
            ],
          ),
        ),
        if (q > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextFormField(
              initialValue: _remarks[item.id],
              decoration: InputDecoration(labelText: l.remarks, isDense: true),
              onChanged: (v) => _remarks[item.id] = v,
            ),
          ),
      ],
    );
  }
}
