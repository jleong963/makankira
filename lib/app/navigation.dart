import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Root navigator key, wired into GoRouter so non-widget code (e.g. the API
/// client) can surface app-level dialogs.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Root scaffold-messenger key, wired into MaterialApp so app-level code (e.g.
/// the in-session reminder watcher) can show a SnackBar from any route.
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

bool _storageDialogOpen = false;

/// Prominent alert shown when a database write fails because storage is full,
/// telling the user to free space by deleting old data. De-duplicated so repeated
/// failures don't stack multiple dialogs.
void showStorageFullDialog() {
  final ctx = rootNavigatorKey.currentContext;
  if (ctx == null || _storageDialogOpen) return;
  _storageDialogOpen = true;
  final l = AppLocalizations.of(ctx);
  showDialog<void>(
    context: ctx,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.storage),
      title: Text(l.storageFullTitle),
      content: Text(l.storageFullBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    ),
  ).whenComplete(() => _storageDialogOpen = false);
}
