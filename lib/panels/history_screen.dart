import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/hydration_store.dart';
import '../theme.dart';
import '../widgets/app_background.dart';
import '../widgets/history_row.dart';
import '../widgets/screen_header.dart';

/// Last seven days, zero-filled. Seven fixed rows always fit, so the screen
/// needs no scroll wrapper.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.store, required this.onBack});

  final HydrationStore store;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final List<DayEntry> days = store.last7;
    final bool hasData = store.hasHistory;

    return AppBackground(
      bubbles: true,
      overlay: const <Color>[Color(0x00FFFFFF), Color(0x14FFFFFF)],
      child: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            ScreenHeader(title: 'HISTORY',
              titleSize: 18,
              titleSpacing: 2.2,
              onBack: onBack,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Image.asset(
                    AppAssets.spriteCalendar,
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stack,
                        ) => const SizedBox(width: 28, height: 28),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'LAST 7 DAYS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (hasData)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < days.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == days.length - 1 ? 0 : 10,
                        ),
                        child: HistoryRow(
                          day: days[i].weekdayLabel,
                          ml: days[i].ml,
                          pct: store.goalMl <= 0
                              ? 0
                              : days[i].ml / store.goalMl,
                        ),
                      ),
                  ],
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.history_toggle_off_rounded,
                      size: 56,
                      color: AppColors.emptyIcon,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No days logged yet',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Your first glass starts the streak',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
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
