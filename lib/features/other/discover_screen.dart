import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/countries.dart';
import '../../providers/discover_providers.dart';
import '../../providers/settings_providers.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../widgets/section_label.dart';
import '../settings/settings_screen.dart';
import 'widgets/discover_filter_sheet.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  Timer? _spinTimer;
  final Random _rng = Random();

  @override
  void dispose() {
    _spinTimer?.cancel();
    super.dispose();
  }

  void _randomize() {
    final controller = ref.read(discoverControllerProvider.notifier);
    final pool = ref.read(discoverPoolProvider);
    final state = ref.read(discoverControllerProvider);
    if (state.spinning || pool.isEmpty) return;
    if (!controller.beginSpin()) return;

    var count = 0;
    String pickName() => pool[_rng.nextInt(pool.length)].name;

    // Show the first cycle immediately so the user sees motion.
    controller.cycleTo(pickName());

    _spinTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      count++;
      if (count > 12) {
        timer.cancel();
        _spinTimer = null;
        // Re-read pool in case it changed mid-spin (it shouldn't, but be safe).
        final livePool = ref.read(discoverPoolProvider);
        if (livePool.isEmpty) {
          controller.cancelSpin();
          return;
        }
        controller.commit(livePool[_rng.nextInt(livePool.length)].name);
      } else {
        controller.cycleTo(pickName());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = ref.watch(accentColorProvider);
    final state = ref.watch(discoverControllerProvider);
    final pool = ref.watch(discoverPoolProvider);
    final cooked = ref.watch(cookedCountriesProvider);

    return ColoredBox(
      color: AppColors.cream,
      child: Column(
        children: [
          _Header(accent: accent),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MainCard(
                    accent: accent,
                    state: state,
                    pool: pool,
                    cooked: cooked,
                    onFilter: () => showDiscoverFilterSheet(context),
                    onRandomize: _randomize,
                  ),
                  if (state.recentPicks.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    const SectionLabel('Recent picks'),
                    _RecentPicksList(
                      picks: state.recentPicks,
                      cooked: cooked,
                      accent: accent,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'omnom',
                    style: AppTextStyles.brandLogo(color: accent)
                        .copyWith(letterSpacing: -0.02 * 26),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Discover',
                    style: AppTextStyles.body(
                      size: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            _SettingsButton(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SettingsScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Semantics(
          label: 'Open settings',
          button: true,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.settings_outlined,
              size: 18,
              color: AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class _MainCard extends StatelessWidget {
  const _MainCard({
    required this.accent,
    required this.state,
    required this.pool,
    required this.cooked,
    required this.onFilter,
    required this.onRandomize,
  });

  final Color accent;
  final DiscoverState state;
  final List<Country> pool;
  final Set<String> cooked;
  final VoidCallback onFilter;
  final VoidCallback onRandomize;

  @override
  Widget build(BuildContext context) {
    final activeFilters = state.filter.activeCount;
    final filtersActive = activeFilters > 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CardHeader(
              accent: accent,
              activeFilters: activeFilters,
              onFilter: onFilter,
            ),
            if (filtersActive) _PoolInfoBar(accent: accent, pool: pool),
            _CountryDisplay(
              state: state,
              pool: pool,
              cooked: cooked,
              accent: accent,
            ),
            _RandomizeButton(
              accent: accent,
              spinning: state.spinning,
              poolEmpty: pool.isEmpty,
              hasPick: state.currentPick != null,
              onTap: onRandomize,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.accent,
    required this.activeFilters,
    required this.onFilter,
  });

  final Color accent;
  final int activeFilters;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'RANDOM COUNTRY',
                    style: AppTextStyles.sectionLabel(),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Not sure which cuisine to cook? Let fate decide.',
                    style: AppTextStyles.body(size: 13)
                        .copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _FilterButton(
              accent: accent,
              activeCount: activeFilters,
              onTap: onFilter,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.accent,
    required this.activeCount,
    required this.onTap,
  });

  final Color accent;
  final int activeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = activeCount > 0;
    final bg = active ? accent.withValues(alpha: 0x18 / 0xFF) : AppColors.creamDark;
    final borderColor =
        active ? accent.withValues(alpha: 0x44 / 0xFF) : AppColors.border;
    final fg = active ? accent : AppColors.muted;
    final label = active
        ? '$activeCount ${activeCount > 1 ? 'filters' : 'filter'}'
        : 'Filter';

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                size: const Size(13, 12),
                painter: _FilterIconPainter(color: fg),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTextStyles.body(
                  size: 12,
                  color: fg,
                  weight: active ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterIconPainter extends CustomPainter {
  _FilterIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    void line(double x1, double y, double x2) {
      canvas.drawLine(Offset(x1, y), Offset(x2, y), paint);
    }

    line(1, 2, 12);
    line(3, 6, 10);
    line(5, 10, 8);
  }

  @override
  bool shouldRepaint(covariant _FilterIconPainter old) => old.color != color;
}

class _PoolInfoBar extends StatelessWidget {
  const _PoolInfoBar({required this.accent, required this.pool});

  final Color accent;
  final List<Country> pool;

  @override
  Widget build(BuildContext context) {
    final empty = pool.isEmpty;
    final text = empty
        ? 'No countries match — try adjusting filters.'
        : '${pool.length} ${pool.length == 1 ? 'country' : 'countries'} in pool';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0x0D / 0xFF),
        border: Border(
          bottom: BorderSide(
            color: accent.withValues(alpha: 0x22 / 0xFF),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        text,
        style: AppTextStyles.body(size: 12, color: accent),
      ),
    );
  }
}

class _CountryDisplay extends StatelessWidget {
  const _CountryDisplay({
    required this.state,
    required this.pool,
    required this.cooked,
    required this.accent,
  });

  final DiscoverState state;
  final List<Country> pool;
  final Set<String> cooked;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final pick = state.currentPick;
    return SizedBox(
      height: 130,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: pick == null ? _idle(context) : _picked(context, pick),
        ),
      ),
    );
  }

  Widget _idle(BuildContext context) {
    final empty = pool.isEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🌍', style: TextStyle(fontSize: 34)),
        const SizedBox(height: 8),
        Text(
          empty
              ? 'No countries match your filters.'
              : 'Press the button to get a random country',
          textAlign: TextAlign.center,
          style: AppTextStyles.body(size: 13, color: AppColors.muted)
              .copyWith(height: 1.6),
        ),
      ],
    );
  }

  Widget _picked(BuildContext context, String name) {
    final cd = kCountries.where((c) => c.name == name).cast<Country?>().firstOrNull;
    final inDiary = cooked.contains(name);
    final spinning = state.spinning;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'COOK FROM',
          style: AppTextStyles.small(
            size: 11,
            color: AppColors.muted,
            weight: FontWeight.w500,
          ).copyWith(letterSpacing: 0.08 * 11),
        ),
        const SizedBox(height: 6),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: AppTextStyles.largeNumber(
            size: 30,
            color: spinning ? AppColors.muted : AppColors.ink,
          ).copyWith(letterSpacing: -0.02 * 30, height: 1.2),
          child: Text(name, textAlign: TextAlign.center),
        ),
        if (cd != null) ...[
          const SizedBox(height: 2),
          Text(
            cd.continent,
            style: AppTextStyles.body(size: 12, color: AppColors.muted),
          ),
        ],
        if (inDiary && !spinning) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0x18 / 0xFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Already in your diary',
              style: AppTextStyles.body(size: 11, color: accent),
            ),
          ),
        ],
      ],
    );
  }
}

class _RandomizeButton extends StatelessWidget {
  const _RandomizeButton({
    required this.accent,
    required this.spinning,
    required this.poolEmpty,
    required this.hasPick,
    required this.onTap,
  });

  final Color accent;
  final bool spinning;
  final bool poolEmpty;
  final bool hasPick;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = spinning || poolEmpty;
    final bg = disabled ? AppColors.border : accent;
    final fg = disabled ? AppColors.muted : AppColors.white;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: DecoratedBox(
        decoration: disabled
            ? const BoxDecoration()
            : BoxDecoration(
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
          color: bg,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: disabled ? null : onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (spinning) ...[
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(fg),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Picking…',
                      style: AppTextStyles.body(
                        size: 15,
                        color: fg,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ] else
                    Text(
                      hasPick
                          ? '↺ Randomize again'
                          : '🎲 Randomize a country',
                      style: AppTextStyles.body(
                        size: 15,
                        color: fg,
                        weight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentPicksList extends StatelessWidget {
  const _RecentPicksList({
    required this.picks,
    required this.cooked,
    required this.accent,
  });

  final List<String> picks;
  final Set<String> cooked;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < picks.length; i++) ...[
          if (i > 0) const SizedBox(height: 7),
          AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 250),
            child: _RecentPickRow(
              key: ValueKey(picks[i]),
              name: picks[i],
              accent: accent,
              inDiary: cooked.contains(picks[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _RecentPickRow extends StatelessWidget {
  const _RecentPickRow({
    super.key,
    required this.name,
    required this.accent,
    required this.inDiary,
  });

  final String name;
  final Color accent;
  final bool inDiary;

  @override
  Widget build(BuildContext context) {
    final cd = kCountries.where((c) => c.name == name).cast<Country?>().firstOrNull;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0x18 / 0xFF),
                shape: BoxShape.circle,
              ),
              child: const Text('🌍', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(name, style: AppTextStyles.cardTitle()),
                  if (cd != null)
                    Text(
                      cd.continent,
                      style: AppTextStyles.small(size: 11),
                    ),
                ],
              ),
            ),
            if (inDiary)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0x18 / 0xFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'in diary',
                  style: AppTextStyles.body(size: 11, color: accent),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
