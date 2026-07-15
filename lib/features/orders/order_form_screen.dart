import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/models.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/browser.dart';
import '../../shared/formatters.dart';
import '../../shared/phone_field.dart';
import '../auth/auth_controller.dart';
import '../meals/meals_controller.dart';
import '../menu/menu_controller.dart';
import '../menu/menu_images_controller.dart';
import '../menu/menu_images_editor.dart';
import 'orders_controller.dart';

/// Screen 5 — participant order form (organizer enters on their device).
/// Doubles as the edit form when [order] is supplied.
class OrderFormScreen extends ConsumerStatefulWidget {
  const OrderFormScreen({super.key, required this.mealId, this.order});
  final String mealId;
  final ParticipantOrder? order;

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final Map<String, int> _qty = {};
  final Map<String, String> _remarks = {};
  bool _honoree = false;
  bool _myOrder = false;
  String? _userId;
  bool _saving = false;

  bool get _isEditing => widget.order != null;

  @override
  void initState() {
    super.initState();
    final order = widget.order;
    if (order != null) {
      // Edit mode: prefill from the existing order.
      _name.text = order.participantName;
      _mobile.text = order.mobileNumber ?? '';
      _honoree = order.isHonoree;
      for (final it in order.items) {
        _qty[it.menuItemId] = it.quantity;
        if (it.remarks != null && it.remarks!.isNotEmpty) _remarks[it.menuItemId] = it.remarks!;
      }
    } else {
      // New order: default name/mobile to the signed-in organizer.
      final auth = ref.read(authProvider);
      final user = auth is AsyncData<AppUser?> ? auth.value : null;
      _userId = user?.id;
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

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    final items = _qty.entries.where((e) => e.value > 0).map((e) {
      final r = (_remarks[e.key] ?? '').trim();
      return {'menuItemId': e.key, 'quantity': e.value, if (r.isNotEmpty) 'remarks': r};
    }).toList();
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.selectItems)));
      return;
    }
    setState(() => _saving = true);
    final body = <String, dynamic>{
      'participantName': _name.text.trim(),
      'mobileNumber': _mobile.text.trim(),
      'participantRole': _honoree ? 'farewell_honoree' : 'paying_participant',
      if (!_isEditing && _myOrder && _userId != null) 'participantUserId': _userId,
      'items': items,
    };
    try {
      final repo = ref.read(ordersRepositoryProvider);
      if (_isEditing) {
        await repo.update(widget.mealId, widget.order!.id, body);
      } else {
        await repo.create(widget.mealId, body);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.orderSaved)));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      setState(() => _saving = false);
    }
  }

  /// Add a brand-new item straight to this meal's shared menu (so it also shows
  /// on the menu page and for the next person ordering), then pre-select it.
  Future<void> _addNewMenuItem() async {
    final l = AppLocalizations.of(context);
    final nameC = TextEditingController();
    final priceC = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.addItem),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameC,
              autofocus: true,
              decoration: InputDecoration(labelText: l.itemName),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceC,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l.estimatedPrice),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l.add)),
        ],
      ),
    );
    final name = nameC.text.trim();
    final priceCents = parseRMToCents(priceC.text);
    nameC.dispose();
    priceC.dispose();
    if (ok != true || name.isEmpty) return;
    try {
      final item = await ref.read(menuRepositoryProvider).add(widget.mealId, {
        'name': name,
        'estimatedPriceCents': ?priceCents,
      });
      if (!mounted) return;
      // The watched menu list refetches (add() invalidated it); pre-select the
      // new item so it's included in this order right away.
      setState(() => _qty[item.id] = 1);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final menu = ref.watch(menuListProvider(widget.mealId));
    final menuUrl = ref.watch(mealDetailProvider(widget.mealId)).asData?.value.meal.menuUrl;
    final menuImageUrls =
        ref.watch(menuImagesProvider(widget.mealId)).asData?.value.map((e) => e.url).toList() ?? const <String>[];
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l.edit : l.addOrder)),
      body: menu.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l.errorTitle}: $e')),
        data: (items) {
          final available = items.where((i) => i.available).toList();
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Menu reference for whoever is entering this order: the menu
                    // link (if any) plus the uploaded menu photos (tap to zoom).
                    if (menuUrl != null && menuUrl.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () => openUrl(ensureUrlScheme(menuUrl)),
                          icon: const Icon(Icons.open_in_new),
                          label: Text(l.menuUrl),
                        ),
                      ),
                    if (menuImageUrls.isNotEmpty) ...[
                      if (menuUrl != null && menuUrl.isNotEmpty) const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(l.menuPhotos, style: Theme.of(context).textTheme.labelLarge),
                      ),
                      const SizedBox(height: 8),
                      MenuImageGallery(urls: menuImageUrls),
                    ],
                    if ((menuUrl != null && menuUrl.isNotEmpty) || menuImageUrls.isNotEmpty)
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
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _honoree,
                      onChanged: (v) => setState(() => _honoree = v),
                      title: Text(l.roleHonoree),
                    ),
                    if (!_isEditing)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _myOrder,
                        onChanged: (v) => setState(() => _myOrder = v ?? false),
                        title: Text(l.myOrder),
                      ),
                    const Divider(),
                    if (available.isEmpty)
                      Padding(padding: const EdgeInsets.all(16), child: Text(l.noMenuItems)),
                    ...available.map(_itemRow),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: _addNewMenuItem,
                        icon: const Icon(Icons.add),
                        label: Text(l.addItem),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l.save),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
            padding: const EdgeInsets.only(left: 0, bottom: 8),
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
