import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import 'participant_controller.dart';
import '../../shared/language_menu.dart';

/// Landing target of an invite link (/join/:token). The auth gate guarantees the
/// user is signed in by the time we get here; we record the membership and open
/// the meal's participant view.
class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({super.key, required this.token});
  final String token;

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _join());
  }

  Future<void> _join() async {
    try {
      final mealId = await ref.read(participantRepositoryProvider).join(widget.token);
      if (!mounted) return;
      context.go('/joined/$mealId');
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = _error ?? 'invalid');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.appName), actions: const [LanguageMenu()]),
      body: Center(
        child: _error == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.link_off, size: 48),
                    const SizedBox(height: 12),
                    Text(l.inviteInvalid, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: () => context.go('/'), child: Text(l.mealSessions)),
                  ],
                ),
              ),
      ),
    );
  }
}
