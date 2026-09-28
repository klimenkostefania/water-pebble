import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../game/hydration_store.dart';
import '../theme.dart';
import '../widgets/app_background.dart';
import '../widgets/bento_tile.dart';
import '../widgets/pebble_gauge.dart';
import '../widgets/primary_button.dart';
import '../widgets/screen_header.dart';
import '../widgets/stat_card.dart';

/// "Today" hub — bento grid over the menu artwork.
class MenuScreen extends StatefulWidget {
  const MenuScreen({
    super.key,
    required this.store,
    required this.onStart,
    required this.onHistory,
    required this.onSettings,
  });

  final HydrationStore store;
  final VoidCallback onStart;
  final VoidCallback onHistory;
  final VoidCallback onSettings;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConfig.menuStaggerMs),
    );
    _intro.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  Animation<double> _fade(double begin, double end) => CurvedAnimation(
    parent: _intro,
    curve: Interval(begin, end, curve: Curves.easeOut),
  );

  Widget _staggered(int index, Widget child) {
    final double begin = (index * 0.15).clamp(0.0, 0.5).toDouble();
    final Animation<double> anim = _fade(begin, begin + 0.5);
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.14),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HydrationStore store = widget.store;
    final bool showStats = store.streak > 0 && store.bestPct > 0;

    return AppBackground(
      asset: AppAssets.bgMenu,
      overlay: const <Color>[
        Color(0xB8F2FBFF),
        Color(0xE6F2FBFF),
        Color(0xF0D8EFF8),
      ],
      bubbles: true,
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            const double headerH = 116;
            const double hintH = 28;
            const double ctaH = 58;
            const double bottomPad = 24;
            const double historyBlock = 78;
            final double statsBlock = showStats ? 110 : 0;

            double tileH = constraints.maxHeight -
                headerH -
                hintH -
                ctaH -
                bottomPad -
                historyBlock -
                statsBlock -
                14;
            if (tileH < 150) {
              tileH = 150;
            }

            return Column(
              children: <Widget>[
                ScreenHeader(title: store.todayLabel,
                  eyebrow: 'TODAY',
                  trailing: CircleIconButton(
                    icon: Icons.settings_outlined,
                    onTap: widget.onSettings,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      _staggered(0, _progressTile(store, tileH)),
                      if (showStats) ...<Widget>[
                        const SizedBox(height: 14),
                        _staggered(1, _statsRow(store)),
                      ],
                      const SizedBox(height: 14),
                      _staggered(2, _historyTile()),
                    ],
                  ),
                ),
                const Spacer(),
                _staggered(
                  3,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          'ONE TAP · ONE GLASS · 250 ML',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.6,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: PrimaryButton(
                          label: 'START HYDRATING',
                          icon: Icons.water_drop_rounded,
                          backgroundAsset: AppAssets.buttonCta,
                          onTap: widget.onStart,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _progressTile(HydrationStore store, double height) {
    return BentoTile(
      height: height,
      padding: EdgeInsets.zero,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  PebbleGauge(
                    progress: store.progress,
                    ml: store.todayMl,
                    goalMl: store.goalMl,
                    size: height > 250 ? 164 : 132,
                  ),
                  const SizedBox(height: 14),
                  if (store.todayMl == 0)
                    const Text(
                      'No water logged yet today',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    )
                  else
                    Text(
                      '${store.glassesDone} GLASSES TODAY',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Image.asset(
              AppAssets.spriteBottle,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stack) =>
                      const SizedBox(width: 40, height: 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(HydrationStore store) {
    return SizedBox(
      height: 96,
      child: Row(
        children: <Widget>[
          Expanded(
            child: StatCard(
              value: '${store.streak}',
              label: 'Day streak',
              valueColor: AppColors.highlight,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: StatCard(
              value: '${store.bestPct}%',
              label: 'Best day',
              valueColor: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyTile() {
    return BentoTile(
      height: 64,
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: widget.onHistory,
      child: Row(
        children: const <Widget>[
          Icon(Icons.show_chart_rounded, size: 22, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'LAST 7 DAYS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 22,
            color: AppColors.iconMuted,
          ),
        ],
      ),
    );
  }
}
