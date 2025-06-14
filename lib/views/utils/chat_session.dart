class ChatSession {
  final String sessionId;
  final String sessionType;
  final DateTime startedAt;
  final List<Map<String, dynamic>> messages;

  ChatSession({
    required this.sessionId,
    required this.sessionType,
    required this.startedAt,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'sessionType': sessionType,
    'startedAt': startedAt.toIso8601String(),
    'messages': messages,
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      sessionId: json['sessionId'],
      sessionType: json['sessionType'],
      startedAt: DateTime.parse(json['startedAt']),
      messages: List<Map<String, dynamic>>.from(json['messages']),
    );
  }
}
