import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game_config.dart';

const List<String> _dayShort = <String>[
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

const List<String> _dayUpper = <String>[
  'MON',
  'TUE',
  'WED',
  'THU',
  'FRI',
  'SAT',
  'SUN',
];

const List<String> _monthShort = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatDate(DateTime d) {
  final String m = d.month.toString().padLeft(2, '0');
  final String day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

/// One logged day: 'yyyy-MM-dd' plus the millilitres drunk that day.
class DayEntry {
  const DayEntry(this.date, this.ml);

  final String date;
  final int ml;

  String encode() => '$date:$ml';

  String get weekdayLabel {
    final DateTime? d = DateTime.tryParse(date);
    if (d == null) {
      return '---';
    }
    return _dayUpper[d.weekday - 1];
  }

  static DayEntry? decode(String raw) {
    final int i = raw.lastIndexOf(':');
    if (i <= 0) {
      return null;
    }
    final int? ml = int.tryParse(raw.substring(i + 1));
    if (ml == null) {
      return null;
    }
    return DayEntry(raw.substring(0, i), ml);
  }
}

/// All hydration state plus its shared_preferences persistence.
/// Every read and write is guarded — a storage failure degrades to the
/// in-memory values instead of crashing the app.
class HydrationStore extends ChangeNotifier {
  static const String kGoal = 'wp_goal_ml';
  static const String kGlass = 'wp_glass_ml';
  static const String kToday = 'wp_today_ml';
  static const String kDate = 'wp_today_date';
  static const String kHistory = 'wp_history';
  static const String kStreak = 'wp_streak';
  static const String kBest = 'wp_best_pct';
  static const String kReminders = 'wp_reminders';

  int goalMl = AppConfig.defaultGoalMl;
  int glassMl = AppConfig.defaultGlassMl;
  int todayMl = 0;
  String todayDate = formatDate(DateTime.now());
  List<DayEntry> history = <DayEntry>[];
  int streak = 0;
  int bestPct = 0;
  bool reminders = true;
  bool loaded = false;
  String? lastError;

  final List<int> _glassStack = <int>[];
  SharedPreferences? _prefs;

  // ---------------------------------------------------------------- getters

  double get progress {
    if (goalMl <= 0) {
      return 0;
    }
    final double v = todayMl / goalMl;
    if (v < 0) {
      return 0;
    }
    return v > 1 ? 1 : v;
  }

  int get percent {
    if (goalMl <= 0) {
      return 0;
    }
    return (todayMl * 100 / goalMl).round();
  }

  int get glassesDone {
    if (glassMl <= 0) {
      return 0;
    }
    return todayMl ~/ glassMl;
  }

  bool get goalReached => todayMl >= goalMl;

  bool get canUndo => todayMl > 0;

  int get overshootMl {
    final int over = todayMl - goalMl;
    return over > 0 ? over : 0;
  }

  String get todayLabel {
    final DateTime n = DateTime.now();
    return '${_dayShort[n.weekday - 1]} · ${n.day} ${_monthShort[n.month - 1]}';
  }

  /// Seven entries ending today, zero-filled for days with no record.
  List<DayEntry> get last7 {
    final List<DayEntry> out = <DayEntry>[];
    DateTime cursor = DateTime.now().subtract(const Duration(days: 6));
    for (int i = 0; i < 7; i++) {
      final String key = formatDate(cursor);
      if (key == todayDate) {
        out.add(DayEntry(key, todayMl));
      } else {
        out.add(_find(key) ?? DayEntry(key, 0));
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return out;
  }

  bool get hasHistory => last7.any((DayEntry e) => e.ml > 0);

  // ------------------------------------------------------------------- load

  Future<void> load() async {
    try {
      final SharedPreferences p = await SharedPreferences.getInstance();
      _prefs = p;
      goalMl = p.getInt(kGoal) ?? AppConfig.defaultGoalMl;
      glassMl = p.getInt(kGlass) ?? AppConfig.defaultGlassMl;
      todayMl = p.getInt(kToday) ?? 0;
      todayDate = p.getString(kDate) ?? formatDate(DateTime.now());
      history = List<DayEntry>.of(
        (p.getStringList(kHistory) ?? <String>[])
            .map(DayEntry.decode)
            .whereType<DayEntry>(),
      );
      streak = p.getInt(kStreak) ?? 0;
      bestPct = p.getInt(kBest) ?? 0;
      reminders = p.getBool(kReminders) ?? true;
      _rollover();
    } catch (e) {
      lastError = 'Could not load saved data.';
      debugPrint('HydrationStore.load failed: $e');
    }
    loaded = true;
    notifyListeners();
  }

  // ---------------------------------------------------------------- actions

  void addGlass() {
    todayMl += glassMl;
    _glassStack.add(glassMl);
    _afterChange();
  }

  void undo() {
    if (todayMl <= 0) {
      return;
    }
    final int back = _glassStack.isNotEmpty ? _glassStack.removeLast() : glassMl;
    todayMl -= back;
    if (todayMl < 0) {
      todayMl = 0;
    }
    _afterChange();
  }

  void setGoal(int value) {
    if (value <= 0 || value == goalMl) {
      return;
    }
    goalMl = value;
    _afterChange();
  }

  void setGlassSize(int value) {
    if (value <= 0 || value == glassMl) {
      return;
    }
    glassMl = value;
    _afterChange();
  }

  void setReminders(bool value) {
    reminders = value;
    _afterChange();
  }

  void resetToday() {
    todayMl = 0;
    _glassStack.clear();
    _afterChange();
  }

  String? consumeError() {
    final String? e = lastError;
    lastError = null;
    return e;
  }

  // --------------------------------------------------------------- internal

  void _afterChange() {
    _upsert(todayDate, todayMl);
    if (percent > bestPct) {
      bestPct = percent;
    }
    _recomputeStreak();
    notifyListeners();
    _persist();
  }

  DayEntry? _find(String date) {
    for (final DayEntry e in history) {
      if (e.date == date) {
        return e;
      }
    }
    return null;
  }

  void _upsert(String date, int ml) {
    final List<DayEntry> next = List<DayEntry>.of(history);
    final int idx = next.indexWhere((DayEntry e) => e.date == date);
    if (idx >= 0) {
      next[idx] = DayEntry(date, ml);
    } else {
      next.add(DayEntry(date, ml));
    }
    next.sort((DayEntry a, DayEntry b) => a.date.compareTo(b.date));
    if (next.length > 14) {
      next.removeRange(0, next.length - 14);
    }
    history = next;
  }

  void _rollover() {
    final String today = formatDate(DateTime.now());
    if (todayDate == today) {
      return;
    }
    if (todayMl > 0) {
      _upsert(todayDate, todayMl);
    }
    todayDate = today;
    todayMl = 0;
    _glassStack.clear();
    _recomputeStreak();
    _persist();
  }

  void _recomputeStreak() {
    int s = todayMl >= goalMl ? 1 : 0;
    DateTime cursor = DateTime.now().subtract(const Duration(days: 1));
    for (int i = 0; i < 14; i++) {
      final DayEntry? e = _find(formatDate(cursor));
      if (e == null || e.ml < goalMl) {
        break;
      }
      s += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    streak = s;
  }

  Future<void> _persist() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final SharedPreferences p = _prefs!;
      await p.setInt(kGoal, goalMl);
      await p.setInt(kGlass, glassMl);
      await p.setInt(kToday, todayMl);
      await p.setString(kDate, todayDate);
      await p.setStringList(
        kHistory,
        history.map((DayEntry e) => e.encode()).toList(),
      );
      await p.setInt(kStreak, streak);
      await p.setInt(kBest, bestPct);
      await p.setBool(kReminders, reminders);
    } catch (e) {
      debugPrint('HydrationStore.persist failed: $e');
      lastError = 'Could not save. Try again.';
      notifyListeners();
    }
  }
}
