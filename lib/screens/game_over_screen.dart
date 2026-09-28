import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../game/hydration_store.dart';
import '../theme.dart';
import '../widgets/app_background.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/stat_card.dart';

/// "Daily Goal" — the result of the day. Deliberately the darkest of the
/// light screens so it never reads as a repeat of Today or Quick Add.
class GameOverScreen extends StatefulWidget {
  const GameOverScreen({
    super.key,
    required this.store,
    required this.reached,
    required this.onAgain,
    required this.onMenu,
  });

  final HydrationStore store;
  final bool reached;
  final VoidCallback onAgain;
  final VoidCallback onMenu;

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  late final Animation<double> _pop;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConfig.resultIntroMs),
    );
    _pop = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _intro, curve: Curves.easeOutBack),
    );
    _fade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    _intro.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HydrationStore store = widget.store;
    final bool reached = widget.reached;

    final int visibleStats = <bool>[
      store.todayMl > 0,
      store.percent > 0,
      store.streak > 0,
    ].where((bool v) => v).length;

    return AppBackground(
      baseGradient: const <Color>[
        AppColors.primaryDark,
        AppColors.loaderMid,
        AppColors.primary,
      ],
      asset: AppAssets.bgResult,
      imageOpacity: 0.35,
      overlay: const <Color>[Color(0x550B4A63), Color(0x330B4A63)],
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 44, 24, 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                reached ? 'GOAL REACHED!' : 'ALMOST THERE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: reached ? AppColors.highlight : AppColors.textOnDark,
                  shadows: reached
                      ? const <Shadow>[
                          Shadow(color: Color(0x73FFD166), blurRadius: 20),
                        ]
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Image.asset(
                AppAssets.spriteWave,
                width: 180,
                height: 44,
                fit: BoxFit.contain,
                errorBuilder:
                    (BuildContext context, Object error, StackTrace? stack) =>
                        const SizedBox(width: 180, height: 44),
              ),
              const SizedBox(height: 18),
              ScaleTransition(scale: _pop, child: _trophy(reached)),
              const SizedBox(height: 22),
              FadeTransition(
                opacity: _fade,
                child: visibleStats >= 2
                    ? _statsRow(store)
                    : const Text(
                        'No water logged yet today',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textOnDark,
                        ),
                      ),
              ),
              const SizedBox(height: 26),
              PrimaryButton(
                label: 'DRINK AGAIN',
                icon: Icons.water_drop_rounded,
                gradient: const <Color>[
                  AppColors.highlight,
                  AppColors.highlightDeep,
                ],
                textColor: AppColors.textPrimary,
                iconColor: AppColors.textPrimary,
                shadowColor: AppColors.highlightDeep,
                onTap: widget.onAgain,
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'BACK TO TODAY',
                icon: Icons.home_rounded,
                foreground: AppColors.textOnDark,
                fill: Colors.white,
                fillAlpha: 0.14,
                borderColor: Colors.white,
                borderAlpha: 0.28,
                onTap: widget.onMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trophy(bool reached) {
    final Widget image = Image.asset(
      AppAssets.spritePebbleTrophy,
      width: 108,
      height: 108,
      fit: BoxFit.contain,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
          const SizedBox(width: 108, height: 108),
    );

    if (reached) {
      return image;
    }

    return Opacity(
      opacity: 0.65,
      child: ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Color(0x552A9DCE),
          BlendMode.srcATop,
        ),
        child: image,
      ),
    );
  }

  Widget _statsRow(HydrationStore store) {
    final List<Widget> cards = <Widget>[];

    if (store.todayMl > 0) {
      cards.add(
        StatCard(
          value: '${store.todayMl} ml',
          label: 'Today',
          valueColor: AppColors.primary,
        ),
      );
    }
    if (store.percent > 0) {
      cards.add(
        StatCard(
          value: '${store.percent}%',
          label: 'Of goal',
          valueColor: AppColors.highlightDeep,
        ),
      );
    }
    if (store.streak > 0) {
      cards.add(
        StatCard(
          value: '${store.streak}',
          label: 'Streak',
          valueColor: AppColors.accent,
        ),
      );
    }

    return SizedBox(
      height: 96,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < cards.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: cards[i]),
          ],
        ],
      ),
    );
  }
}
