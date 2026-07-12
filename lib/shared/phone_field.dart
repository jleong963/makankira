import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import 'countries.dart';

/// Mobile-number input with a country-code selector (flag + dial code). The
/// composed international number (`+<dial><national>`, or '' when blank) is kept
/// in [controller].text, so callers read it exactly like a plain field — no API
/// change at the call site beyond swapping the widget. The controller's initial
/// value is parsed to pick the starting country + national digits.
class PhoneField extends StatefulWidget {
  const PhoneField({super.key, required this.controller, this.labelText, this.validator});

  /// Holds the composed value (`+<dial><national>`). Read this on submit.
  final TextEditingController controller;
  final String? labelText;

  /// Validates the national part (e.g. required). Null → optional field.
  final String? Function(String national)? validator;

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  late Country _country;
  late final TextEditingController _national;

  @override
  void initState() {
    super.initState();
    final parsed = parsePhone(widget.controller.text);
    _country = parsed.country;
    _national = TextEditingController(text: parsed.national);
    // Publish the normalized composed value up front, so saving an unchanged
    // number sends the E.164 form rather than the raw stored string.
    widget.controller.text = _compose();
  }

  @override
  void dispose() {
    _national.dispose();
    super.dispose();
  }

  String _compose() {
    final n = _national.text.trim();
    return n.isEmpty ? '' : '+${_country.dial}$n';
  }

  void _sync() => widget.controller.text = _compose();

  Future<void> _pickCountry() async {
    final picked = await showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CountryPickerSheet(),
    );
    if (picked != null) {
      setState(() => _country = picked);
      _sync();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // The country selector lives INSIDE the field as a prefix, so it shares the
    // input's box and vertical centering — no two-widget alignment to fight.
    return TextFormField(
      controller: _national,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
      validator: widget.validator == null ? null : (v) => widget.validator!((v ?? '').trim()),
      onChanged: (_) => _sync(),
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        prefixIcon: InkWell(
          onTap: _pickCountry,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 8, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CountryFlag.fromCountryCode(_country.iso, height: 18, width: 24, shape: const RoundedRectangle(3)),
                const SizedBox(width: 6),
                Text('+${_country.dial}', style: const TextStyle(fontWeight: FontWeight.w500)),
                Icon(Icons.arrow_drop_down, size: 22, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Container(width: 1, height: 22, color: scheme.outlineVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Searchable country list (flag · name · dial code) shown as a bottom sheet.
class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet();

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final q = _q.trim().toLowerCase();
    final list = q.isEmpty
        ? countries
        : countries
            .where((c) => c.name.toLowerCase().contains(q) || c.dial.contains(q) || c.iso.toLowerCase().contains(q))
            .toList();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l.searchCountry, isDense: true),
                onChanged: (v) => setState(() => _q = v),
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? Center(child: Text(l.noCountryMatch))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final c = list[i];
                        return ListTile(
                          leading: CountryFlag.fromCountryCode(c.iso, height: 20, width: 28, shape: const RoundedRectangle(3)),
                          title: Text(c.name),
                          trailing: Text('+${c.dial}', style: TextStyle(color: scheme.onSurfaceVariant)),
                          onTap: () => Navigator.pop(context, c),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
