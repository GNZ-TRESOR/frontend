import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Chat input bar widget
class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;
  final bool isConnected;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isLoading,
    required this.isConnected,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: widget.controller,
                  enabled: !widget.isLoading && widget.isConnected,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: widget.isConnected
                        ? 'Ask about family planning...'
                        : 'Connecting...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    prefixIcon: Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.grey[500],
                      size: 20,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                  ),
                  onSubmitted: (_) {
                    if (_hasText && !widget.isLoading && widget.isConnected) {
                      widget.onSend();
                    }
                  },
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _hasText && !widget.isLoading && widget.isConnected
                    ? AppColors.primary
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _hasText && !widget.isLoading && widget.isConnected
                      ? widget.onSend
                      : null,
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey[600]!,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            color: _hasText && widget.isConnected
                                ? Colors.white
                                : Colors.grey[500],
                            size: 20,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
