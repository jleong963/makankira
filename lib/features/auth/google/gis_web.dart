// GIS configuration keys are snake_case to match the Google Identity Services
// JavaScript object contract; they cannot be renamed to lowerCamelCase.
// ignore_for_file: non_constant_identifier_names
import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

// Web implementation of the Google Identity Services (GIS) facade.
//
// Loads https://accounts.google.com/gsi/client, initialises the ID flow, and
// renders the official Google button into a Flutter platform view. The button
// artwork, text, and branding are produced by Google's SDK, so they always
// match the current Google branding guideline.

const String _gsiScriptSrc = 'https://accounts.google.com/gsi/client';

bool get gisIsSupported => true;

// --- JS interop bindings ----------------------------------------------------

@JS('google.accounts.id.initialize')
external void _idInitialize(_IdConfiguration config);

@JS('google.accounts.id.renderButton')
external void _idRenderButton(
  web.HTMLElement parent,
  _ButtonConfiguration options,
);

@JS('google.accounts.id.disableAutoSelect')
external void _idDisableAutoSelect();

extension type _IdConfiguration._(JSObject _) implements JSObject {
  external factory _IdConfiguration({
    required String client_id,
    required JSFunction callback,
    bool auto_select,
    bool cancel_on_tap_outside,
    String ux_mode,
    bool use_fedcm_for_button,
  });
}

extension type _ButtonConfiguration._(JSObject _) implements JSObject {
  external factory _ButtonConfiguration({
    String type,
    String theme,
    String size,
    String text,
    String shape,
    String logo_alignment,
    String? locale,
    double width,
  });
}

extension type _CredentialResponse._(JSObject _) implements JSObject {
  external String get credential;
}

// --- State ------------------------------------------------------------------

Completer<void>? _scriptLoad;
bool _initialized = false;
void Function(String idToken)? _onCredential;
final Set<String> _registeredViewTypes = <String>{};

Future<void> _ensureScriptLoaded() {
  final existingLoad = _scriptLoad;
  if (existingLoad != null) return existingLoad.future;

  final completer = Completer<void>();
  _scriptLoad = completer;

  final already = web.document.querySelector('script[data-makankira-gis="true"]');
  if (already != null) {
    completer.complete();
    return completer.future;
  }

  final script = web.document.createElement('script') as web.HTMLScriptElement;
  script
    ..src = _gsiScriptSrc
    ..async = true
    ..defer = true;
  script.setAttribute('data-makankira-gis', 'true');
  script.addEventListener(
    'load',
    (web.Event _) {
      if (!completer.isCompleted) completer.complete();
    }.toJS,
  );
  script.addEventListener(
    'error',
    (web.Event _) {
      // Forget this attempt (and drop the dead tag) before reporting the
      // failure, so a user-triggered retry re-injects the script instead of
      // being handed the same errored future.
      script.remove();
      _scriptLoad = null;
      if (!completer.isCompleted) {
        completer.completeError(
          StateError('Failed to load Google Identity Services'),
        );
      }
    }.toJS,
  );
  web.document.head!.appendChild(script);
  return completer.future;
}

Future<void> gisInitialize({
  required String clientId,
  required void Function(String idToken) onCredential,
}) async {
  _onCredential = onCredential;
  await _ensureScriptLoaded();

  void handleCredential(_CredentialResponse response) {
    final token = response.credential;
    final callback = _onCredential;
    if (callback != null && token.isNotEmpty) callback(token);
  }

  // FedCM button UX: the browser renders a native account chooser instead of a
  // popup window, which desktop Chrome (M125+) now blocks for the legacy
  // `gsi/select` popup (part of Google's third-party-cookie phase-out). Browsers
  // without FedCM-button support fall back to the `ux_mode: 'popup'` flow below
  // (vercel.json's Cross-Origin-Opener-Policy allows that popup to respond).
  _idInitialize(
    _IdConfiguration(
      client_id: clientId,
      callback: handleCredential.toJS,
      auto_select: false,
      cancel_on_tap_outside: true,
      ux_mode: 'popup',
      use_fedcm_for_button: true,
    ),
  );
  _initialized = true;
}

Widget gisButton({required bool isDark, String? locale, double width = 320}) {
  // Approved GIS styles: dark surface -> filled black; light -> outline.
  final theme = isDark ? 'filled_black' : 'outline';
  final viewType = 'makankira-gis-$theme-${locale ?? 'auto'}-${width.round()}';

  if (!_registeredViewTypes.contains(viewType)) {
    _registeredViewTypes.add(viewType);
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int _) {
      final host = web.document.createElement('div') as web.HTMLDivElement;
      host.style
        ..width = '${width.toStringAsFixed(0)}px'
        ..height = '44px';
      // Render on the next frame, once the host is attached to the DOM.
      web.window.requestAnimationFrame(
        (JSNumber _) {
          if (_initialized) {
            _idRenderButton(
              host,
              _ButtonConfiguration(
                type: 'standard',
                theme: theme,
                size: 'large',
                text: 'continue_with',
                shape: 'rectangular',
                logo_alignment: 'left',
                locale: locale,
                width: width,
              ),
            );
          }
        }.toJS,
      );
      return host;
    });
  }

  return SizedBox(
    width: width,
    height: 44,
    child: HtmlElementView(viewType: viewType),
  );
}

void gisSignOut() {
  if (_initialized) _idDisableAutoSelect();
}
