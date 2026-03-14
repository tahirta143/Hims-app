class ChatMessage {
  final String role; // 'user' or 'ai'
  final String content;

  ChatMessage({
    required this.role,
    required this.content,
  });

  bool get isUser => role == 'user';
  bool get isAi => role == 'ai';
}
