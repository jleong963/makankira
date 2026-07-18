import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/models.dart';
import '../../app/navigation.dart';
import '../../app/router.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../settings/web_push.dart';
import 'meals_controller.dart';

/// The signed-in organizer's meals that may still need an in-session reminder.
/// Gated on auth so we never fetch /meals (a 401) while logged out; only owned
/// meals come back from /meals, so every entry is one this user organizes.
final _reminderMealsProvider = Provider<List<MealSession>>((ref) {
  final signedIn = ref.watch(authProvider).value != null;
  if (!signedIn) return const [];
  return ref.watch(mealsProvider).value ?? const [];
});

/// Fires a foreground reminder (in-app SnackBar + best-effort system
/// notification) at each meal's `remind_at` while the app is open. This is the
/// counterpart to the server-side Web Push cron: the cron covers the app being
/// closed; this covers it being open, which is the moment the organizer is most
/// likely to act. Only future remind_at times fire here — anything already past
/// is the cron's job, so reopening the app never replays an old reminder.
class ReminderWatcher extends ConsumerStatefulWidget {
  const ReminderWatcher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ReminderWatcher> createState() => _ReminderWatcherState();
}

class _ReminderWatcherState extends ConsumerState<ReminderWatcher> {
  // Web/JS timers overflow above ~24.8 days (the setTimeout limit); cap well
  // under that and let a later reconcile pick up far-future reminders when the
  // app is reopened closer to the time.
  static const _maxDelay = Duration(days: 20);

  final Map<String, Timer> _timers = {};
  final Map<String, DateTime> _scheduledAt = {};
  final Set<String> _shown = {}; // fired this app-session — never repeated

  @override
  void dispose() {
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    super.dispose();
  }

  bool _stillCollecting(String status) => status == 'draft' || status == 'collecting_orders';

  void _reconcile(List<MealSession> meals) {
    final now = DateTime.now();
    final wanted = <String, DateTime>{};
    for (final m in meals) {
      if (!m.reminderEnabled || !_stillCollecting(m.status) || _shown.contains(m.id)) continue;
      final iso = m.remindAt;
      if (iso == null) continue;
      final at = DateTime.tryParse(iso)?.toLocal();
      if (at == null || !at.isAfter(now)) continue; // past → the cron handles it
      if (at.difference(now) > _maxDelay) continue; // too far out to schedule now
      wanted[m.id] = at;
    }

    // Drop timers that are no longer wanted or whose target time changed.
    _timers.removeWhere((id, timer) {
      if (wanted[id] != _scheduledAt[id]) {
        timer.cancel();
        _scheduledAt.remove(id);
        return true;
      }
      return false;
    });

    // Schedule anything newly due.
    wanted.forEach((id, at) {
      if (_timers.containsKey(id)) return;
      _scheduledAt[id] = at;
      _timers[id] = Timer(at.difference(DateTime.now()), () => _fire(id));
    });
  }

  void _fire(String mealId) {
    _timers.remove(mealId);
    _scheduledAt.remove(mealId);
    if (!mounted || _shown.contains(mealId)) return;

    // Re-read the meal from the latest list: it may have been renamed, closed,
    // or deleted between scheduling and firing.
    final meals = ref.read(_reminderMealsProvider).where((m) => m.id == mealId);
    if (meals.isEmpty) return;
    final meal = meals.first;
    if (!_stillCollecting(meal.status)) return;

    _shown.add(mealId);

    final l = AppLocalizations.of(context);
    final body = l.inSessionReminder(meal.title);

    // When the tab is backgrounded the in-app banner won't be seen, so raise a
    // best-effort system notification too; when the app is on-screen the banner
    // below is enough on its own.
    if (pageIsHidden()) showLocalNotification(l.orderReminder, body);

    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(body),
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: l.manage,
          onPressed: () => ref.read(routerProvider).go('/meals/$mealId'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meals = ref.watch(_reminderMealsProvider);
    // Reconcile after the frame so we never mutate timers mid-build. This runs
    // only when the meal list actually changes (the sole watched dependency).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reconcile(meals);
    });
    return widget.child;
  }
}
