import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_pebble/game/game_config.dart';
import 'package:water_pebble/game/hydration_store.dart';
import 'package:water_pebble/widgets/primary_button.dart';
import 'package:water_pebble/widgets/stat_card.dart';

// Screens paint AI-generated artwork that only exists after the asset step,
// so the widget tests cover the asset-free building blocks.

void main() {
  testWidgets('PrimaryButton renders its label and reports taps', (
    WidgetTester tester,
  ) async {
    int taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PrimaryButton(
              label: 'START HYDRATING',
              icon: Icons.water_drop_rounded,
              onTap: () => taps += 1,
            ),
          ),
        ),
      ),
    );

    expect(find.text('START HYDRATING'), findsOneWidget);

    await tester.tap(find.text('START HYDRATING'));
    await tester.pumpAndSettle();

    expect(taps, 1);
  });

  testWidgets('StatCard shows value and uppercased label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 140,
              height: 96,
              child: StatCard(
                value: '3',
                label: 'Day streak',
                valueColor: Color(0xFFFFD166),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.text('DAY STREAK'), findsOneWidget);
  });

  test('store adds, undoes and never drops below zero', () {
    final HydrationStore store = HydrationStore();

    expect(store.todayMl, 0);
    store.addGlass();
    expect(store.todayMl, AppConfig.defaultGlassMl);
    expect(store.glassesDone, 1);

    store.undo();
    expect(store.todayMl, 0);

    store.undo();
    expect(store.todayMl, 0);
    expect(store.progress, 0);
  });

  test('history seed list stays mutable across updates', () {
    final HydrationStore store = HydrationStore();

    store.addGlass();
    expect(store.history.length, 1);

    store.addGlass();
    expect(store.history.length, 1);
    expect(store.history.first.ml, AppConfig.defaultGlassMl * 2);
  });

  test('last7 is zero-filled and always seven days long', () {
    final HydrationStore store = HydrationStore();

    expect(store.last7.length, 7);
    expect(store.hasHistory, isFalse);

    store.addGlass();
    expect(store.last7.length, 7);
    expect(store.last7.last.ml, AppConfig.defaultGlassMl);
    expect(store.hasHistory, isTrue);
  });
}
