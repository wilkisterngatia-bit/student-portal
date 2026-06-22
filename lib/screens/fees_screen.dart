import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../widgets/screen_header.dart';
import '../widgets/status_pill.dart';
<<<<<<< HEAD
import '../widgets/ai_insight_card.dart';
=======
>>>>>>> 0bafda798c711ccdbff03b4e01897423b69b639f

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  int _totalBilled = 0;
  int _amountPaid = 0;
  int _balance = 0;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchFeesStatement();
  }

  Future<void> _fetchFeesStatement() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final url = Uri.parse('https://jsonplaceholder.typicode.com/users/1');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final multiplier = (data['id'] as int) * 15000;
        setState(() {
          _totalBilled = multiplier + 35000;
          _amountPaid = multiplier;
          _balance = 35000;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Server error (${response.statusCode}). Try again shortly.';
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _errorMessage = 'No connection. Check your internet and try again.';
        _isLoading = false;
      });
    }
  }

  String _fmt(int amount) {
    final str = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return 'KES $buf';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(eyebrow: 'FINANCE', title: 'Fees statement'),
              const SizedBox(height: AppSpacing.lg),
              Expanded(child: _buildBody(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.violet));
    }
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 36, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.sm),
            Text(_errorMessage, textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: _fetchFeesStatement, child: const Text('Retry')),
          ],
        ),
      );
    }

    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Outstanding balance',
                  style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
              const SizedBox(height: 6),
              Text(_fmt(_balance),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.sm),
              StatusPill(
                label: _balance > 0 ? 'Payment due' : 'Cleared',
                kind: _balance > 0 ? StatusKind.pending : StatusKind.positive,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
<<<<<<< HEAD
        _buildFeesInsight(),
        const SizedBox(height: AppSpacing.lg),
=======
>>>>>>> 0bafda798c711ccdbff03b4e01897423b69b639f
        _statRow(context, 'Total billed', _fmt(_totalBilled), Icons.receipt_long_outlined),
        const SizedBox(height: AppSpacing.sm),
        _statRow(context, 'Amount paid', _fmt(_amountPaid), Icons.check_circle_outline),
        const SizedBox(height: AppSpacing.sm),
        _statRow(context, 'Bank reference', 'Generated on payment', Icons.tag_outlined),
      ],
    );
  }

<<<<<<< HEAD
  /// Rule-based insight from the billed/paid figures already on
  /// screen — no external AI call involved.
  Widget _buildFeesInsight() {
    if (_balance <= 0) {
      return const AiInsightCard(
        tone: InsightTone.positive,
        message: 'Your fees are fully cleared for this semester. No action needed.',
      );
    }
    final proportionPaid = _totalBilled > 0 ? _amountPaid / _totalBilled : 0;
    if (proportionPaid < 0.5) {
      return AiInsightCard(
        tone: InsightTone.warning,
        message:
            'You\'ve paid less than half of this semester\'s fees. Clearing your balance before exams helps avoid delays accessing your results.',
      );
    }
    return AiInsightCard(
      tone: InsightTone.info,
      message: 'You have ${_fmt(_balance)} remaining. Clear it before the semester ends to avoid late fees.',
    );
  }

=======
>>>>>>> 0bafda798c711ccdbff03b4e01897423b69b639f
  Widget _statRow(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.violet),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
