import 'dart:convert';
import 'package:flutter/material.dart';
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

  static Future<void> updateChatSession(ChatSession updatedSession) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getAllChatSessions();

    final index = sessions.indexWhere((session) => session.sessionId == updatedSession.sessionId);
    if (index != -1) {
      sessions[index] = updatedSession;
      final encoded = sessions.map((e) => json.encode(e.toJson())).toList();
      await prefs.setStringList(key, encoded);
    } else {
      throw Exception('ChatSession with id ${updatedSession.sessionId} not found.');
    }
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

  void clearChatHistory(BuildContext context) async {
    await ChatStorage.clearSessions();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Historial de chats eliminado.')),
    );
  }
}
