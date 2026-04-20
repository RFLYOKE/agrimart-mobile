import 'dart:async';
import 'package:flutter/material.dart';

class SessionTimerWidget extends StatefulWidget {
  final DateTime startedAt;
  final int durationMin;
  final VoidCallback onTimerFinished;

  const SessionTimerWidget({
    super.key,
    required this.startedAt,
    required this.durationMin,
    required this.onTimerFinished,
  });

  @override
  State<SessionTimerWidget> createState() => _SessionTimerWidgetState();
}

class _SessionTimerWidgetState extends State<SessionTimerWidget> {
  Timer? _timer;
  late DateTime _endTime;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _endTime = widget.startedAt.add(Duration(minutes: widget.durationMin));
    _calculateRemaining();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateRemaining();
    });
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    if (now.isAfter(_endTime)) {
      _timer?.cancel();
      setState(() => _remaining = Duration.zero);
      widget.onTimerFinished();
    } else {
      if (mounted) setState(() => _remaining = _endTime.difference(now));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(_remaining.inMinutes.remainder(60));
    final seconds = twoDigits(_remaining.inSeconds.remainder(60));

    final isCritical = _remaining.inMinutes < 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCritical ? Colors.red : Colors.green[800],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            '$minutes:$seconds',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
