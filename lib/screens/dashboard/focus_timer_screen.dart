import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/pomodoro_timer_provider.dart';

/// Redesigned Focus Timer / Pomodoro Screen.
class FocusTimerScreen extends StatelessWidget {
  const FocusTimerScreen({super.key});

  static const _bg = Color(0xFF05070F);
  static const _card = Color(0xFF0F1422);
  static const _accent = Color(0xFFF0A93E);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PomodoroTimerProvider(),
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          foregroundColor: const Color(0xFFF4EFE6),
          title: const Text('Focus Timer', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'serif')),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Color(0xFFF0A93E)),
              onPressed: () => _openSettingsSheet(context),
            ),
          ],
        ),
        body: Consumer<PomodoroTimerProvider>(
          builder: (context, timer, _) {
            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _ModeSelector(timer: timer),
                  const Spacer(),
                  _TimerRing(timer: timer, accent: _accent),
                  const SizedBox(height: 28),
                  Text(
                    _label(timer.mode),
                    style: const TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Session ${timer.completedFocusSessions + 1}',
                    style: const TextStyle(color: Color(0xFF8B93A6), fontSize: 13),
                  ),
                  const Spacer(),
                  _Controls(timer: timer, accent: _accent, card: _card),
                  const SizedBox(height: 36),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _label(TimerMode mode) {
    switch (mode) {
      case TimerMode.focus:
        return 'FOCUS SESSION';
      case TimerMode.shortBreak:
        return 'SHORT BREAK';
      case TimerMode.longBreak:
        return 'LONG BREAK';
    }
  }

  void _openSettingsSheet(BuildContext context) {
    final timer = context.read<PomodoroTimerProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DurationSettingsSheet(timer: timer, accent: _accent),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.timer});
  final PomodoroTimerProvider timer;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, TimerMode mode) {
      final selected = timer.mode == mode;
      return Expanded(
        child: GestureDetector(
          onTap: () => timer.switchMode(mode),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFF0A93E).withOpacity(0.18) : const Color(0xFF0F1422),
              border: Border.all(
                color: selected ? const Color(0xFFF0A93E) : const Color(0x1AF4EFE6),
                width: selected ? 1.5 : 1.0,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? const Color(0xFFF0A93E) : const Color(0xFF8B93A6),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          chip('Focus', TimerMode.focus),
          chip('Short Break', TimerMode.shortBreak),
          chip('Long Break', TimerMode.longBreak),
        ],
      ),
    );
  }
}

class _TimerRing extends StatelessWidget {
  const _TimerRing({required this.timer, required this.accent});
  final PomodoroTimerProvider timer;
  final Color accent;

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      height: 270,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 270,
            height: 270,
            child: CircularProgressIndicator(
              value: timer.progress.clamp(0, 1),
              strokeWidth: 12,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          Text(
            _fmt(timer.remaining),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.timer, required this.accent, required this.card});
  final PomodoroTimerProvider timer;
  final Color accent;
  final Color card;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundButton(icon: Icons.refresh_rounded, onTap: timer.reset, background: card),
        const SizedBox(width: 24),
        _RoundButton(
          icon: timer.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          onTap: timer.isRunning ? timer.pause : timer.start,
          background: accent,
          large: true,
          iconColor: const Color(0xFF0B0E14),
        ),
        const SizedBox(width: 24),
        _RoundButton(icon: Icons.skip_next_rounded, onTap: timer.skip, background: card),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.onTap,
    required this.background,
    this.large = false,
    this.iconColor = Colors.white,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color background;
  final bool large;
  final Color iconColor;

  static const _accentColor = Color(0xFFF0A93E);

  @override
  Widget build(BuildContext context) {
    final size = large ? 72.0 : 56.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: background == _accentColor ? _accentColor.withOpacity(0.35) : Colors.black26,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: large ? 36 : 24),
      ),
    );
  }
}

class _DurationSettingsSheet extends StatefulWidget {
  const _DurationSettingsSheet({required this.timer, required this.accent});
  final PomodoroTimerProvider timer;
  final Color accent;

  @override
  State<_DurationSettingsSheet> createState() => _DurationSettingsSheetState();
}

class _DurationSettingsSheetState extends State<_DurationSettingsSheet> {
  late int focusMin = widget.timer.focusDuration.inMinutes;
  late int shortMin = widget.timer.shortBreakDuration.inMinutes;
  late int longMin = widget.timer.longBreakDuration.inMinutes;

  Widget _row(String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14))),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.white54),
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Text('$value min', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white54),
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Timer Durations', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _row('Focus Session', focusMin, (v) => setState(() => focusMin = v)),
          _row('Short Break', shortMin, (v) => setState(() => shortMin = v)),
          _row('Long Break', longMin, (v) => setState(() => longMin = v)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () {
                widget.timer.updateDurations(
                  focus: Duration(minutes: focusMin),
                  shortBreak: Duration(minutes: shortMin),
                  longBreak: Duration(minutes: longMin),
                );
                Navigator.pop(context);
              },
              child: const Text('Save Durations', style: TextStyle(color: Color(0xFF0B0E14), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
