import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/models.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/phone_field.dart';
import '../auth/auth_controller.dart';

/// Screen 2D — profile: display name + mobile (email read-only).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  String _email = '';
  String? _photoUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authProvider);
    final user = auth is AsyncData<AppUser?> ? auth.value : null;
    _name.text = user?.displayName ?? '';
    _mobile.text = user?.mobileNumber ?? '';
    _email = user?.email ?? '';
    _photoUrl = user?.photoUrl;
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
    setState(() => _saving = true);
    try {
      await ref.read(authProvider.notifier).updateProfile({
        'displayName': _name.text.trim(),
        'mobileNumber': _mobile.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.profileSaved)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Read-only avatar synced from the user's Google account. Falls back to a
  /// person icon when there is no photo or the image fails to load. There is no
  /// upload/edit affordance — the picture always mirrors the Google account.
  Widget _avatarHeader() {
    final theme = Theme.of(context);
    const double d = 56;
    final url = _photoUrl;
    final fallback = Container(
      width: d,
      height: d,
      color: theme.colorScheme.primaryContainer,
      alignment: Alignment.center,
      child: Icon(Icons.person, size: 30, color: theme.colorScheme.onPrimaryContainer),
    );
    return ClipOval(
      child: (url == null || url.isEmpty)
          ? fallback
          : Image.network(
              url,
              width: d,
              height: d,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
              loadingBuilder: (ctx, child, progress) => progress == null
                  ? child
                  : const SizedBox(
                      width: d,
                      height: d,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.profile)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_email.isNotEmpty || (_photoUrl?.isNotEmpty ?? false)) ...[
                  Row(
                    children: [
                      _avatarHeader(),
                      if (_email.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.email,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(_email, style: theme.textTheme.bodyLarge),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Divider(height: 32),
                ],
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: l.displayName),
                  validator: (v) => (v == null || v.trim().isEmpty) ? l.required : null,
                ),
                const SizedBox(height: 12),
                PhoneField(controller: _mobile, labelText: l.mobileNumber),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
