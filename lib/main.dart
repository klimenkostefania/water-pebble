import 'package:flutter/material.dart';

import 'game/game_config.dart';
import 'game/hydration_store.dart';
import 'panels/history_screen.dart';
import 'panels/settings_screen.dart';
import 'screens/game_over_screen.dart';
import 'screens/game_screen.dart';
import 'screens/loader_screen.dart';
import 'screens/menu_screen.dart';
import 'theme.dart';

/// Whole app navigation. Plain enum + setState — no router, no deep links.
enum Screen { loader, menu, game, gameover, history, settings }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WaterPebbleApp());
}

class WaterPebbleApp extends StatefulWidget {
  const WaterPebbleApp({super.key});

  @override
  State<WaterPebbleApp> createState() => _WaterPebbleAppState();
}

class _WaterPebbleAppState extends State<WaterPebbleApp> {
  final HydrationStore _store = HydrationStore();

  Screen _screen = Screen.loader;
  bool _reached = false;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
    _store.load();
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _store.dispose();
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _go(Screen next) {
    if (!mounted) {
      return;
    }
    setState(() => _screen = next);
  }

  void _finishRound(bool reached) {
    if (!mounted) {
      return;
    }
    setState(() {
      _reached = reached;
      _screen = Screen.gameover;
    });
  }

  Widget _currentScreen() {
    switch (_screen) {
      case Screen.loader:
        return LoaderScreen(
          key: const ValueKey<String>('loader'),
          onDone: () => _go(Screen.menu),
        );
      case Screen.menu:
        return MenuScreen(
          key: const ValueKey<String>('menu'),
          store: _store,
          onStart: () => _go(Screen.game),
          onHistory: () => _go(Screen.history),
          onSettings: () => _go(Screen.settings),
        );
      case Screen.game:
        return GameScreen(
          key: const ValueKey<String>('game'),
          store: _store,
          onBack: () => _go(Screen.menu),
          onFinish: _finishRound,
          onSettings: () => _go(Screen.settings),
        );
      case Screen.gameover:
        return GameOverScreen(
          key: const ValueKey<String>('gameover'),
          store: _store,
          reached: _reached,
          onAgain: () => _go(Screen.game),
          onMenu: () => _go(Screen.menu),
        );
      case Screen.history:
        return HistoryScreen(
          key: const ValueKey<String>('history'),
          store: _store,
          onBack: () => _go(Screen.menu),
        );
      case Screen.settings:
        return SettingsScreen(
          key: const ValueKey<String>('settings'),
          store: _store,
          onBack: () => _go(Screen.menu),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaterPebble',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: Scaffold(
        backgroundColor: AppColors.bg,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: AppConfig.screenFadeMs),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _currentScreen(),
        ),
      ),
    );
  }
}
