import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/settings.dart';
import '../../providers/settings_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/section_label.dart';
import '../../widgets/text_field.dart';
import '../diary/widgets/omnom_back_button.dart';

/// Curated accent palette — covers the prototype default plus a few tones
/// the user is likely to try. Free-form hex is also supported below.
const List<String> _kAccentSwatches = [
  '#C07B39', // default — burnt orange
  '#A0522D', // sienna
  '#B8860B', // dark gold
  '#6B8E23', // olive
  '#2E8B57', // forest
  '#5F7E8A', // slate
  '#3F5772', // navy
  '#7B5B82', // dusty plum
  '#9C2A2A', // brick
  '#2A1F14', // ink (subtle)
];

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _person1;
  late final TextEditingController _person2;
  late final TextEditingController _hex;
  String _accentHex = '#C07B39';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _person1 = TextEditingController();
    _person2 = TextEditingController();
    _hex = TextEditingController()..addListener(_onHexChanged);
  }

  @override
  void dispose() {
    _person1.dispose();
    _person2.dispose();
    _hex
      ..removeListener(_onHexChanged)
      ..dispose();
    super.dispose();
  }

  void _seed(Settings s) {
    if (_initialized) return;
    _person1.text = s.person1;
    _person2.text = s.person2;
    _hex.text = s.accentHex.toUpperCase();
    _accentHex = s.accentHex.toUpperCase();
    _initialized = true;
  }

  bool _isValidHex(String raw) {
    final cleaned = raw.trim().replaceFirst('#', '');
    if (cleaned.length != 6) return false;
    return RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(cleaned);
  }

  String _normalizeHex(String raw) {
    final cleaned = raw.trim().replaceFirst('#', '').toUpperCase();
    return '#$cleaned';
  }

  Future<void> _save() async {
    final p1 = _person1.text.trim();
    final p2 = _person2.text.trim();
    final accent = _isValidHex(_hex.text) ? _normalizeHex(_hex.text) : _accentHex;
    await ref.read(settingsControllerProvider.notifier).save(
          Settings(
            person1: p1.isEmpty ? 'Jonathan' : p1,
            person2: p2.isEmpty ? 'Louise' : p2,
            accentHex: accent,
          ),
        );
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  void _pickSwatch(String hex) {
    setState(() {
      _accentHex = hex.toUpperCase();
      _hex.text = _accentHex;
    });
  }

  void _onHexChanged() {
    if (_isValidHex(_hex.text)) {
      final normalized = _normalizeHex(_hex.text);
      if (normalized != _accentHex) {
        setState(() => _accentHex = normalized);
      }
    } else {
      // Force a rebuild so the validation hint appears.
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final accent = HexColor.fromHex(_accentHex);
    settingsAsync.whenData(_seed);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(accent: accent, onSave: _save),
            Expanded(
              child: settingsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.muted),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Kunde inte ladda inställningar: $e',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(color: AppColors.muted),
                    ),
                  ),
                ),
                data: (_) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionLabel('Personer'),
                      Text(
                        'Namn som visas bredvid varje betyg på logginlägg.',
                        style: AppTextStyles.small(size: 11),
                      ),
                      const SizedBox(height: 10),
                      OmnomTextField(
                        controller: _person1,
                        placeholder: 'Person 1',
                      ),
                      const SizedBox(height: 8),
                      OmnomTextField(
                        controller: _person2,
                        placeholder: 'Person 2',
                      ),
                      const SizedBox(height: 22),
                      const SectionLabel('Accentfärg'),
                      Text(
                        'Färgar knappar, betyg, aktiv flik och varumärkeslogotypen.',
                        style: AppTextStyles.small(size: 11),
                      ),
                      const SizedBox(height: 12),
                      _SwatchGrid(
                        selectedHex: _accentHex,
                        onPick: _pickSwatch,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _AccentPreview(color: accent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OmnomTextField(
                              key: const Key('settings.hex-field'),
                              controller: _hex,
                              placeholder: '#C07B39',
                              prefix: 'HEX  ',
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(7),
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9a-fA-F#]'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_hex.text.isNotEmpty && !_isValidHex(_hex.text)) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Hexkod måste vara 6 tecken (t.ex. #C07B39).',
                          style: AppTextStyles.small(
                            size: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      _SaveButton(accent: accent, onTap: _save),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.accent, required this.onSave});

  final Color accent;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 20, 12),
        child: Row(
          children: [
            const OmnomBackButton(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Inställningar',
                style: AppTextStyles.screenTitle(size: 20),
              ),
            ),
            Text(
              'omnom',
              style: AppTextStyles.brandLogo(color: accent)
                  .copyWith(fontSize: 18, letterSpacing: -0.02 * 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwatchGrid extends StatelessWidget {
  const _SwatchGrid({required this.selectedHex, required this.onPick});

  final String selectedHex;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final hex in _kAccentSwatches)
          _Swatch(
            hex: hex,
            selected: hex.toUpperCase() == selectedHex.toUpperCase(),
            onTap: () => onPick(hex),
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.hex,
    required this.selected,
    required this.onTap,
  });

  final String hex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = HexColor.fromHex(hex);
    return Semantics(
      label: 'Accent $hex',
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.ink : AppColors.border,
              width: selected ? 2 : 1.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0x44 / 0xFF),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: selected
              ? const Icon(Icons.check, size: 18, color: AppColors.white)
              : null,
        ),
      ),
    );
  }
}

class _AccentPreview extends StatelessWidget {
  const _AccentPreview({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.accent, required this.onTap});

  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0x44 / 0xFF),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: accent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: Text(
              'Spara ändringar',
              style: AppTextStyles.body(
                size: 15,
                color: AppColors.white,
                weight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
