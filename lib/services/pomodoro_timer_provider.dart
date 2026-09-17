import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The three phases of a Pomodoro cycle.
enum TimerMode { focus, shortBreak, longBreak }

/// A drift-free, persistent Pomodoro/Focus timer provider.
class PomodoroTimerProvider extends ChangeNotifier with WidgetsBindingObserver {
  PomodoroTimerProvider() {
    WidgetsBinding.instance.addObserver(this);
    _restore();
  }

  // ---- Configurable durations ----
  Duration focusDuration = const Duration(minutes: 25);
  Duration shortBreakDuration = const Duration(minutes: 5);
  Duration longBreakDuration = const Duration(minutes: 15);
  int sessionsBeforeLongBreak = 4;

  // ---- Core state ----
  TimerMode _mode = TimerMode.focus;
  bool _isRunning = false;
  DateTime? _endTime;
  Duration _remainingWhenPaused = const Duration(minutes: 25);
  int _completedFocusSessions = 0;

  Timer? _uiTicker;

  TimerMode get mode => _mode;
  bool get isRunning => _isRunning;
  int get completedFocusSessions => _completedFocusSessions;

  Duration get totalForMode {
    switch (_mode) {
      case TimerMode.focus:
        return focusDuration;
      case TimerMode.shortBreak:
        return shortBreakDuration;
      case TimerMode.longBreak:
        return longBreakDuration;
    }
  }

  Duration get remaining {
    if (_isRunning && _endTime != null) {
      final diff = _endTime!.difference(DateTime.now());
      return diff.isNegative ? Duration.zero : diff;
    }
    return _remainingWhenPaused;
  }

  double get progress {
    final total = totalForMode.inMilliseconds;
    if (total == 0) return 0;
    return 1 - (remaining.inMilliseconds / total);
  }

  void start() {
    if (_isRunning) return;
    _endTime = DateTime.now().add(
      _remainingWhenPaused == Duration.zero ? totalForMode : _remainingWhenPaused,
    );
    _isRunning = true;
    _startUiTicker();
    _persist();
    notifyListeners();
  }

  void pause() {
    if (!_isRunning) return;
    _remainingWhenPaused = remaining;
    _isRunning = false;
    _endTime = null;
    _uiTicker?.cancel();
    _persist();
    notifyListeners();
  }

  void reset() {
    _isRunning = false;
    _endTime = null;
    _remainingWhenPaused = totalForMode;
    _uiTicker?.cancel();
    _persist();
    notifyListeners();
  }

  void skip() => _advancePhase();

  void switchMode(TimerMode newMode) {
    _mode = newMode;
    _isRunning = false;
    _endTime = null;
    _remainingWhenPaused = totalForMode;
    _uiTicker?.cancel();
    _persist();
    notifyListeners();
  }

  void updateDurations({
    Duration? focus,
    Duration? shortBreak,
    Duration? longBreak,
    int? sessionsBeforeLong,
  }) {
    if (focus != null) focusDuration = focus;
    if (shortBreak != null) shortBreakDuration = shortBreak;
    if (longBreak != null) longBreakDuration = longBreak;
    if (sessionsBeforeLong != null) sessionsBeforeLongBreak = sessionsBeforeLong;
    if (!_isRunning) _remainingWhenPaused = totalForMode;
    _persist();
    notifyListeners();
  }

  void _startUiTicker() {
    _uiTicker?.cancel();
    _uiTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remaining == Duration.zero) {
        _onPhaseComplete();
      }
      notifyListeners();
    });
  }

  void _onPhaseComplete() {
    if (_mode == TimerMode.focus) _completedFocusSessions++;
    _advancePhase();
  }

  void _advancePhase() {
    _isRunning = false;
    _uiTicker?.cancel();
    _endTime = null;

    if (_mode == TimerMode.focus) {
      final onLongBreak = _completedFocusSessions % sessionsBeforeLongBreak == 0;
      _mode = onLongBreak ? TimerMode.longBreak : TimerMode.shortBreak;
    } else {
      _mode = TimerMode.focus;
    }
    _remainingWhenPaused = totalForMode;
    _persist();
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isRunning && _endTime != null) {
      if (remaining == Duration.zero) {
        _onPhaseComplete();
      } else {
        notifyListeners();
      }
    }
  }

  static const _kMode = 'timer_mode';
  static const _kIsRunning = 'timer_running';
  static const _kEndTime = 'timer_end_epoch_ms';
  static const _kRemainingMs = 'timer_remaining_ms';
  static const _kCompleted = 'timer_completed_sessions';

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kMode, _mode.index);
    await prefs.setBool(_kIsRunning, _isRunning);
    await prefs.setInt(_kEndTime, _endTime?.millisecondsSinceEpoch ?? 0);
    await prefs.setInt(_kRemainingMs, _remainingWhenPaused.inMilliseconds);
    await prefs.setInt(_kCompleted, _completedFocusSessions);
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    _mode = TimerMode.values[prefs.getInt(_kMode) ?? 0];
    _completedFocusSessions = prefs.getInt(_kCompleted) ?? 0;
    final wasRunning = prefs.getBool(_kIsRunning) ?? false;
    final endMs = prefs.getInt(_kEndTime) ?? 0;
    final remMs = prefs.getInt(_kRemainingMs);

    if (wasRunning && endMs > 0) {
      final end = DateTime.fromMillisecondsSinceEpoch(endMs);
      if (end.isAfter(DateTime.now())) {
        _endTime = end;
        _isRunning = true;
        _startUiTicker();
      } else {
        if (_mode == TimerMode.focus) _completedFocusSessions++;
        _advancePhase();
      }
    } else {
      _remainingWhenPaused = remMs != null ? Duration(milliseconds: remMs) : totalForMode;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _uiTicker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
