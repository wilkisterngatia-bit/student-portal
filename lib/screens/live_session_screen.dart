import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/biometric_service.dart';
import '../services/virtual_session_store.dart';

class LiveSessionScreen extends StatefulWidget {
  final String unit;
  final String day;
  final String time;

  const LiveSessionScreen({
    super.key,
    required this.unit,
    required this.day,
    required this.time,
  });

  @override
  State<LiveSessionScreen> createState() => _LiveSessionScreenState();
}

enum _SessionStage { confirming, failed, live, ended }

class _LiveSessionScreenState extends State<LiveSessionScreen> {
  _SessionStage _stage = _SessionStage.confirming;
  Timer? _ticker;
  int _seconds = 0;
  late DateTime _joinedAt;

  @override
  void initState() {
    super.initState();
    _runBiometricCheck();
  }

  Future<void> _runBiometricCheck() async {
    final confirmed = await BiometricService.authenticate(
      reason: 'Confirm it\'s you to join ${widget.unit}',
    );
    if (!mounted) return;
    if (confirmed) {
      _joinedAt = DateTime.now();
      setState(() => _stage = _SessionStage.live);
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _seconds++);
      });
    } else {
      setState(() => _stage = _SessionStage.failed);
    }
  }

  void _retry() {
    setState(() => _stage = _SessionStage.confirming);
    _runBiometricCheck();
  }

  Future<void> _endSession() async {
    _ticker?.cancel();
    await VirtualSessionStore.add(VirtualSessionRecord(
      unit: widget.unit,
      joinedAt: _joinedAt,
      durationSeconds: _seconds,
    ));
    if (!mounted) return;
    setState(() => _stage = _SessionStage.ended);
  }

  String _formatDuration(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.inkPlumDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _buildStage(context),
        ),
      ),
    );
  }

  Widget _buildStage(BuildContext context) {
    switch (_stage) {
      case _SessionStage.confirming:
        return _centered(
          icon: Icons.fingerprint,
          iconColor: Colors.white,
          title: 'Confirming your identity',
          subtitle: 'Use your fingerprint to join ${widget.unit}',
          showSpinner: true,
        );
      case _SessionStage.failed:
        return _centered(
          icon: Icons.error_outline,
          iconColor: AppColors.coral,
          title: 'Identity not confirmed',
          subtitle: 'We couldn\'t verify your fingerprint. Try again to join the lesson.',
          action: ElevatedButton(
            onPressed: _retry,
            child: const Text('Try again'),
          ),
        );
      case _SessionStage.live:
        return _buildLive(context);
      case _SessionStage.ended:
        return _buildEnded(context);
    }
  }

  Widget _buildLive(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(color: AppColors.coral, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            const Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1)),
            const Spacer(),
            Text('${widget.day} · ${widget.time}',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
          ],
        ),
        const Spacer(),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.unit,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.xl),
              Text(
                _formatDuration(_seconds),
                style: const TextStyle(
                    color: Colors.white, fontSize: 56, fontWeight: FontWeight.w700, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              Text('Time in lesson', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _endSession,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral),
            icon: const Icon(Icons.call_end, size: 18),
            label: const Text('Leave lesson'),
          ),
        ),
      ],
    );
  }

  Widget _buildEnded(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: AppColors.sage, size: 56),
        const SizedBox(height: AppSpacing.md),
        const Text('Lesson attendance recorded',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(
          'You were in ${widget.unit} for ${_formatDuration(_seconds)}.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }

  Widget _centered({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool showSpinner = false,
    Widget? action,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 56),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13)),
          if (showSpinner) ...[
            const SizedBox(height: AppSpacing.lg),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppSpacing.lg),
            action,
          ],
        ],
      ),
    );
  }
}
