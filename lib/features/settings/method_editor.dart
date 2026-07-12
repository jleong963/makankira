import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_client.dart';
import '../../api/models.dart';
import '../../l10n/app_localizations.dart';

/// Human label for a payment-method type.
String methodTypeLabel(AppLocalizations l, String type) {
  switch (type) {
    case 'bank_account':
      return l.methodBank;
    case 'duitnow_id':
      return l.methodDuitNowId;
    case 'duitnow_qr':
      return l.methodDuitNowQr;
    default:
      return l.methodCustom;
  }
}

/// One-line summary of a payment method's details.
String methodLine(PaymentMethod m) {
  switch (m.methodType) {
    case 'bank_account':
      return [m.bankName, m.accountNumber, m.accountName].where((s) => s != null && s.isNotEmpty).join(' · ');
    case 'duitnow_id':
      return m.duitNowId ?? '';
    case 'duitnow_qr':
      return 'QR';
    default:
      return m.instructions ?? '';
  }
}

/// Add/edit bottom sheet for a payment method, shared by the account defaults
/// (Settings 2B) and the per-meal-session methods. The caller supplies [onSubmit]
/// (add when id is null, else update) so the same form drives either scope.
/// [showDefault] hides the "set as default" switch where it has no meaning
/// (e.g. per-session methods).
class MethodEditorSheet extends ConsumerStatefulWidget {
  const MethodEditorSheet({super.key, this.method, required this.onSubmit, this.showDefault = true});

  final PaymentMethod? method;
  final bool showDefault;
  final Future<void> Function(Map<String, dynamic> body, String? id) onSubmit;

  @override
  ConsumerState<MethodEditorSheet> createState() => _MethodEditorSheetState();
}

class _MethodEditorSheetState extends ConsumerState<MethodEditorSheet> {
  late String _type;
  late final TextEditingController _accountName;
  late final TextEditingController _bankName;
  late final TextEditingController _accountNumber;
  late final TextEditingController _duitNowId;
  late final TextEditingController _instructions;
  late bool _isDefault;
  String? _qrFileId;
  bool _uploading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.method;
    _type = m?.methodType ?? 'bank_account';
    _qrFileId = m?.qrImageFileId;
    _accountName = TextEditingController(text: m?.accountName ?? '');
    _bankName = TextEditingController(text: m?.bankName ?? '');
    _accountNumber = TextEditingController(text: m?.accountNumber ?? '');
    _duitNowId = TextEditingController(text: m?.duitNowId ?? '');
    _instructions = TextEditingController(text: m?.instructions ?? '');
    _isDefault = m?.isDefault ?? false;
  }

  @override
  void dispose() {
    for (final c in [_accountName, _bankName, _accountNumber, _duitNowId, _instructions]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _t(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _pickQr() async {
    final res = await FilePicker.pickFiles(type: FileType.image, withData: true);
    final file = (res != null && res.files.isNotEmpty) ? res.files.first : null;
    final bytes = file?.bytes;
    if (bytes == null) return;
    final ext = (file!.extension ?? '').toLowerCase();
    final contentType = ext == 'png' ? 'image/png' : (ext == 'webp' ? 'image/webp' : 'image/jpeg');
    setState(() => _uploading = true);
    try {
      final data = await ref.read(apiClientProvider).uploadBytes(
            '/files',
            bytes,
            contentType: contentType,
            query: {'fileKind': 'duitnow_qr', 'filename': file.name},
          );
      if (!mounted) return;
      setState(() => _qrFileId = data['id'] as String?);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), duration: const Duration(seconds: 6)),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final body = <String, dynamic>{
      'methodType': _type,
      'accountName': _t(_accountName),
      'bankName': _t(_bankName),
      'accountNumber': _t(_accountNumber),
      'duitNowId': _t(_duitNowId),
      'instructions': _t(_instructions),
      'qrImageFileId': _qrFileId,
      'isDefault': widget.showDefault ? _isDefault : false,
    };
    try {
      await widget.onSubmit(body, widget.method?.id);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: InputDecoration(labelText: l.methodType),
            items: [
              DropdownMenuItem(value: 'bank_account', child: Text(l.methodBank)),
              DropdownMenuItem(value: 'duitnow_id', child: Text(l.methodDuitNowId)),
              DropdownMenuItem(value: 'duitnow_qr', child: Text(l.methodDuitNowQr)),
              DropdownMenuItem(value: 'custom', child: Text(l.methodCustom)),
            ],
            onChanged: (v) => setState(() => _type = v ?? 'bank_account'),
          ),
          const SizedBox(height: 12),
          if (_type == 'bank_account') ...[
            TextField(controller: _bankName, decoration: InputDecoration(labelText: l.bankName)),
            const SizedBox(height: 12),
            TextField(controller: _accountNumber, decoration: InputDecoration(labelText: l.accountNumber)),
            const SizedBox(height: 12),
            TextField(controller: _accountName, decoration: InputDecoration(labelText: l.accountName)),
          ] else if (_type == 'duitnow_id') ...[
            TextField(controller: _duitNowId, decoration: InputDecoration(labelText: l.duitNowIdLabel)),
            const SizedBox(height: 12),
            TextField(controller: _accountName, decoration: InputDecoration(labelText: l.accountName)),
          ] else if (_type == 'duitnow_qr') ...[
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _uploading ? null : _pickQr,
                  icon: _uploading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.upload),
                  label: Text(l.methodDuitNowQr),
                ),
                const SizedBox(width: 12),
                if (_qrFileId != null) const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: _accountName, decoration: InputDecoration(labelText: l.accountName)),
          ] else ...[
            TextField(
              controller: _instructions,
              decoration: InputDecoration(labelText: l.instructions),
              maxLines: 3,
            ),
          ],
          if (widget.showDefault)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
              title: Text(l.setDefault),
            ),
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
    );
  }
}
