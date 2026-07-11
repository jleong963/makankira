import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/web.dart' as web;
import '../../api/models.dart';
import 'auth_controller.dart';

/// Inactivity auto-logout window in seconds, compiled in via
/// --dart-define-from-file. Sourced from the INACTIVE_TIMEOUT GitHub variable
/// through CI/CD (config/app-config.*.yaml → load-config → dart-define);
/// defaults to 960. A value <= 0 disables the timeout.
const inactivityTimeoutSeconds = int.fromEnvironment('INACTIVE_TIMEOUT', defaultValue: 960);

const _lastActivityKey = 'mk_last_activity';

/// Stamp "activity now". Called on each interaction and right after login, so a
/// freshly signed-in session is never treated as already-stale.
void markSessionActive() {
  web.window.localStorage.setItem(_lastActivityKey, DateTime.now().millisecondsSinceEpoch.toString());
}

int? _lastActivityMs() {
  final v = web.window.localStorage.getItem(_lastActivityKey);
  return v == null ? null : int.tryParse(v);
}

/// Wraps the app: after [inactivityTimeoutSeconds] with no interaction the user
/// is signed out (server logout + local state), so returning requires signing in
/// again. A persisted last-activity timestamp also logs out a session that was
/// left idle and reopened later (e.g. the tab was closed before the timer fired).
class InactivityGuard extends ConsumerStatefulWidget {
  const InactivityGuard({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<InactivityGuard> createState() => _InactivityGuardState();
}

class _InactivityGuardState extends ConsumerState<InactivityGuard> {
  Timer? _timer;
  bool _armed = false;
  DateTime _lastBump = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    _timer?.cancel();
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent _) {
    _bump();
    return false; // observe only; never consume the key
  }

  bool _loggedIn() {
    final a = ref.read(authProvider);
    return a is AsyncData<AppUser?> && a.value != null;
  }

  void _arm() {
    if (_armed) return;
    _armed = true;
    // If the session was left idle past the window before this load, log out now.
    final last = _lastActivityMs();
    if (last != null && DateTime.now().millisecondsSinceEpoch - last > inactivityTimeoutSeconds * 1000) {
      Future.microtask(_logout); // defer: don't mutate providers during build/listen
      return;
    }
    markSessionActive();
    _restart();
  }

  void _disarm() {
    _armed = false;
    _timer?.cancel();
    _timer = null;
  }

  void _restart() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: inactivityTimeoutSeconds), _logout);
  }

  void _bump() {
    if (!_armed) return;
    final now = DateTime.now();
    if (now.difference(_lastBump).inSeconds < 3) return; // throttle bursts (e.g. mouse moves)
    _lastBump = now;
    markSessionActive();
    _restart();
  }

  void _logout() {
    if (!_armed) return;
    _disarm();
    if (_loggedIn()) ref.read(authProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (inactivityTimeoutSeconds > 0) {
      // React to sign-in / sign-out transitions.
      ref.listen<AsyncValue<AppUser?>>(authProvider, (_, next) {
        final loggedIn = next is AsyncData<AppUser?> && next.value != null;
        if (loggedIn) {
          _arm();
        } else {
          _disarm();
        }
      });
      // Cover the case where auth had already resolved before this mounted
      // (listen only fires on later changes). Deferred so we never touch a
      // provider during build.
      if (!_armed && _loggedIn()) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _arm();
        });
      }
    }
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _bump(),
      onPointerSignal: (_) => _bump(),
      onPointerMove: (_) => _bump(),
      child: widget.child,
    );
  }
}
