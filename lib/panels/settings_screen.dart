import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../game/hydration_store.dart';
import '../theme.dart';
import '../widgets/app_background.dart';
import '../widgets/bento_tile.dart';
import '../widgets/chip_selector.dart';
import '../widgets/screen_header.dart';

/// Daily goal, glass size and the two local toggles.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.store, required this.onBack});

  final HydrationStore store;
  final VoidCallback onBack;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _flushError() {
    final String? error = widget.store.consumeError();
    if (error == null || !mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.error,
        content: Text(error),
      ),
    );
  }

  Future<void> _confirmReset() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Reset today?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'This clears the water logged today. History stays.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'RESET',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (ok ?? false) {
      widget.store.resetToday();
      _flushError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final HydrationStore store = widget.store;

    return AppBackground(
      bubbles: true,
      overlay: const <Color>[Color(0x00FFFFFF), Color(0x14FFFFFF)],
      child: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            ScreenHeader(title: 'SETTINGS',
              titleSize: 18,
              titleSpacing: 2.2,
              onBack: widget.onBack,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  BentoTile(
                    radius: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'DAILY GOAL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${store.goalMl} ml',
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ChipSelector(
                          values: AppConfig.goalPresets,
                          selected: store.goalMl,
                          onSelect: (int value) {
                            store.setGoal(value);
                            _flushError();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  BentoTile(
                    radius: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Image.asset(
                              AppAssets.spriteGlass,
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (
                                    BuildContext context,
                                    Object error,
                                    StackTrace? stack,
                                  ) => const SizedBox(width: 32, height: 32),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'GLASS SIZE, ML',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ChipSelector(
                          values: AppConfig.glassPresets,
                          selected: store.glassMl,
                          onSelect: (int value) {
                            store.setGlassSize(value);
                            _flushError();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  BentoTile(
                    radius: 22,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.notifications_none_rounded,
                          size: 24,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Gentle reminders',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Switch(
                          value: store.reminders,
                          onChanged: (bool value) {
                            store.setReminders(value);
                            _flushError();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  BentoTile(
                    radius: 22,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            AppAssets.icon,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (
                                  BuildContext context,
                                  Object error,
                                  StackTrace? stack,
                                ) => const SizedBox(width: 36, height: 36),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'WaterPebble · v1.0',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _confirmReset,
                          child: const Text(
                            'RESET TODAY',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
