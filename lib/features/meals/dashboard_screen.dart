import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/brand.dart';
import '../../api/models.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/formatters.dart';
import '../../shared/language_menu.dart';
import '../auth/auth_controller.dart';
import 'meals_controller.dart';

/// Screen 2 — meal sessions dashboard: list, search, create.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _query = '';

  /// Organizer marks a meal session complete (terminal 'closed' status), after
  /// confirming. Keeps meals from being stuck in draft forever.
  Future<void> _markComplete(MealSession m) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(m.title),
        content: Text(l.markCompleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.markComplete)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(mealsProvider.notifier).markComplete(m.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.mealMarkedComplete)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final meals = ref.watch(mealsProvider);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const MakanKiraWordmark(fontSize: 20),
        actions: [
          const LanguageMenu(),
          IconButton(
            tooltip: l.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            tooltip: l.signOut,
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/meals/new'),
        icon: const Icon(Icons.add),
        label: Text(l.newMeal),
      ),
      body: meals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(message: '$e', onRetry: () => ref.read(mealsProvider.notifier).refresh()),
        data: (list) {
          final q = _query.trim().toLowerCase();
          final filtered = q.isEmpty
              ? list
              : list
                  .where((m) =>
                      m.title.toLowerCase().contains(q) || m.restaurantName.toLowerCase().contains(q))
                  .toList();
          return RefreshIndicator(
            onRefresh: () => ref.read(mealsProvider.notifier).refresh(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.mealSessions, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: l.searchMeals,
                          isDense: true,
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? _EmptyState(hasQuery: q.isNotEmpty)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _MealCard(
                              meal: filtered[i],
                              onTap: () => context.push(
                                  filtered[i].isParticipant ? '/joined/${filtered[i].id}' : '/meals/${filtered[i].id}'),
                              onComplete: () => _markComplete(filtered[i]),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A single meal in the dashboard list — role avatar, title, status, and the
/// restaurant / time metadata, with an organizer "mark complete" menu.
class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, required this.onTap, required this.onComplete});

  final MealSession meal;
  final VoidCallback onTap;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final showMenu = !meal.isParticipant && meal.status != 'closed';
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role avatar.
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  meal.isParticipant ? Icons.group_rounded : Icons.restaurant_rounded,
                  color: scheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            meal.title,
                            style: text.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showMenu)
                          _CompleteMenu(onComplete: onComplete)
                        else
                          const SizedBox(height: 4),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (meal.restaurantName.isNotEmpty)
                      _MetaRow(icon: Icons.storefront_outlined, text: meal.restaurantName),
                    if (meal.mealDateTime != null && meal.mealDateTime!.isNotEmpty)
                      _MetaRow(icon: Icons.schedule_rounded, text: formatDateTime(meal.mealDateTime)),
                    const SizedBox(height: 10),
                    StatusPill(status: meal.status, label: statusLabel(l, meal.status), compact: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompleteMenu extends StatelessWidget {
  const _CompleteMenu({required this.onComplete});
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SizedBox(
      height: 28,
      width: 28,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        iconSize: 20,
        tooltip: '',
        onSelected: (v) {
          if (v == 'complete') onComplete();
        },
        itemBuilder: (ctx) => [
          PopupMenuItem<String>(
            value: 'complete',
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 20),
                const SizedBox(width: 12),
                Text(l.markComplete),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 15, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Friendly empty state — a faded brand mark plus guidance to create the first
/// meal (or a "no matches" note while searching).
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasQuery});
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 64, 32, 32),
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasQuery ? Icons.search_off_rounded : Icons.ramen_dining,
                  size: 44,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                hasQuery ? l.search : l.noMeals,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

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
            Icon(Icons.error_outline_rounded, size: 48, color: scheme.error),
            const SizedBox(height: 16),
            Text('${l.errorTitle}\n$message', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(l.retry)),
          ],
        ),
      ),
    );
  }
}
