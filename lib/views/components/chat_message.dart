import 'package:flutter/material.dart';

class ChatMessage extends StatefulWidget {
  final String message;
  final bool isUser;
  final bool isTemporary;

  const ChatMessage({
    super.key,
    required this.message,
    required this.isUser,
    this.isTemporary = false,
  });

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: widget.isUser ? const Offset(1.0, 0.1) : const Offset(-1.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Align(
          alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isUser ? const Color(0xFFEAF2F8) : const Color(0xFFFFFFFF),
              borderRadius: widget.isUser
                  ? const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
                bottomLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(0.0),
              )
                  : const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
                bottomLeft: Radius.circular(0.0),
                bottomRight: Radius.circular(16.0),
              ),
              border: Border.all(
                color: const Color(0xFFD5D8DC),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.message,
              style: TextStyle(
                fontStyle: widget.isTemporary ? FontStyle.italic : FontStyle.normal,
                color: widget.isUser ? const Color(0xFF333A40) : const Color(0xFF3A7CA5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
