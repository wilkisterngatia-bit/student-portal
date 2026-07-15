import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/assistant_engine.dart';

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage(this.text, this.isUser);
}

class FloatingAssistant extends StatefulWidget {
  const FloatingAssistant({super.key});

  @override
  State<FloatingAssistant> createState() => _FloatingAssistantState();
}

class _FloatingAssistantState extends State<FloatingAssistant> {
  bool _open = false;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isThinking = false;

  static const _suggestions = [
    'What\'s my fee balance?',
    'How is my attendance?',
    'Next class?',
  ];

  void _toggle() {
    setState(() => _open = !_open);
    if (_open && _messages.isEmpty) {
      _messages.add(_ChatMessage(
        'Hi, I\'m your portal assistant. Ask me about your fees, attendance, results, timetable, or exam registration.',
        false,
      ));
    }
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
    await Future.delayed(const Duration(milliseconds: 450));

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
    final screenSize = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Positioned(
      right: 16,
      bottom: 16 + bottomInset,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_open)
              Container(
                width: screenSize.width > 420 ? 340 : screenSize.width - 32,
                height: screenSize.height * 0.55,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.linen,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.inkPlumDark.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text('Portal assistant',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                          GestureDetector(
                            onTap: _toggle,
                            child: const Icon(Icons.close, size: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppSpacing.sm + 2),
                        itemCount: _messages.length + (_isThinking ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (_isThinking && index == _messages.length) {
                            return _buildBubble(_ChatMessage('', false), thinking: true);
                          }
                          return _buildBubble(_messages[index]);
                        },
                      ),
                    ),
                    if (_messages.length <= 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _suggestions.map((s) {
                            return GestureDetector(
                              onTap: () => _send(s),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.violetSoft,
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                ),
                                child: Text(s,
                                    style: const TextStyle(
                                        fontSize: 11, color: AppColors.inkPlum, fontWeight: FontWeight.w600)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm + 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              onSubmitted: _send,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'Ask something...',
                                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 42,
                            width: 42,
                            child: ElevatedButton(
                              onPressed: () => _send(_inputController.text),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                              ),
                              child: const Icon(Icons.arrow_upward, size: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            GestureDetector(
              onTap: _toggle,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.inkPlumDark.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  _open ? Icons.close : Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(_ChatMessage message, {bool thinking = false}) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: const BoxConstraints(maxWidth: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isUser ? AppColors.violet : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: isUser ? null : Border.all(color: AppColors.divider),
        ),
        child: thinking
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.violet),
              )
            : Text(
                message.text,
                style: TextStyle(
                  fontSize: 12.5,
                  color: isUser ? Colors.white : AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
      ),
    );
  }
}
