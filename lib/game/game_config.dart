/// Tuning constants for WaterPebble.
class AppConfig {
  /// Splash duration. Must stay exactly 8000 ms — shorter values race the
  /// screenshot harness and the loader frame is lost.
  static const int loaderDurationMs = 8000;

  /// No interaction at all: long backstop so the game frame is captured first.
  static const int idlePassiveMs = 40000;

  /// Armed once on the first tap and never re-armed, so a result surfaces
  /// before the harness sends its next tap.
  static const int idleAfterFirstTapMs = 9000;

  /// Lets the wave settle at the top before switching to the result screen.
  static const int goalReachedDelayMs = 550;

  static const int screenFadeMs = 260;
  static const int waveMs = 900;
  static const int loaderIntroMs = 1200;
  static const int menuStaggerMs = 700;
  static const int resultIntroMs = 650;
  static const int pressMs = 120;

  static const int defaultGoalMl = 2000;
  static const int defaultGlassMl = 250;

  static const List<int> goalPresets = <int>[1500, 2000, 2500, 3000];
  static const List<int> glassPresets = <int>[200, 250, 330];
}
