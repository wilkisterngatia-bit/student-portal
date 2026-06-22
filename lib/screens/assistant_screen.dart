import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_header.dart';
import '../services/assistant_engine.dart';

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage(this.text, this.isUser);
}

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isThinking = false;

  static const _suggestions = [
    'What\'s my fee balance?',
    'How is my attendance?',
    'When is my next class?',
    'What\'s a retake exam?',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      'Hi, I\'m your portal assistant. Ask me about your fees, attendance, results, timetable, or exam registration.',
      false,
    ));
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text.trim(), true));
      _isThinking = true;
    });
    _inputController.clear();
    _scrollToBottom();

    final reply = await AssistantEngine.respond(text);
    // Small delay so the "thinking" state is visible — mirrors how a
    // real AI response feels, even though this is a local rule-based
    // lookup with no network round trip required.
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(reply, false));
      _isThinking = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
              child: const ScreenHeader(eyebrow: 'HELP', title: 'Portal assistant'),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                itemCount: _messages.length + (_isThinking ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isThinking && index == _messages.length) {
                    return _buildBubble(context, _ChatMessage('…', false), thinking: true);
                  }
                  return _buildBubble(context, _messages[index]);
                },
              ),
            ),
            if (_messages.length <= 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _suggestions.map((s) {
                    return GestureDetector(
                      onTap: () => _send(s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.violetSoft,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(s,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.inkPlum, fontWeight: FontWeight.w600)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      onSubmitted: _send,
                      decoration: const InputDecoration(
                        hintText: 'Ask about fees, attendance, results...',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    height: 54,
                    width: 54,
                    child: ElevatedButton(
                      onPressed: () => _send(_inputController.text),
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Icon(Icons.arrow_upward, color: Colors.white),
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

  Widget _buildBubble(BuildContext context, _ChatMessage message, {bool thinking = false}) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? AppColors.violet : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: isUser ? null : Border.all(color: AppColors.divider),
        ),
        child: thinking
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.violet),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isUser) ...[
                    const Icon(Icons.auto_awesome, size: 14, color: AppColors.violet),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: isUser ? Colors.white : AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
