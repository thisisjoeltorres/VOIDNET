import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voidnet/views/utils/chat_session.dart';

class ChatStorage {
  static const String key = 'chat_sessions';

  static Future<void> saveChatSession(ChatSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getAllChatSessions();
    sessions.add(session);

    final encoded = sessions.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(key, encoded);
  }

  static Future<List<ChatSession>> getAllChatSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];
    return data.map((e) => ChatSession.fromJson(json.decode(e))).toList();
  }

  static Future<void> clearSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
