import 'package:flutter/widgets.dart';

// No-op Google Identity Services implementation for non-web targets and VM
// widget tests. The login screen falls back to the branded custom button
// (disabled) when GIS is not supported.

bool get gisIsSupported => false;

Future<void> gisInitialize({
  required String clientId,
  required void Function(String idToken) onCredential,
}) async {}

Widget gisButton({required bool isDark, String? locale, double width = 320}) =>
    const SizedBox.shrink();

void gisSignOut() {}
