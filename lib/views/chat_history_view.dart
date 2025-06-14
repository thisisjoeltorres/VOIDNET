import 'package:flutter/material.dart';
import 'package:voidnet/views/chatbot_view.dart';
import 'package:voidnet/views/components/history-card.dart';
import 'package:voidnet/views/styles/spaces.dart';
import 'package:voidnet/views/utils/chat_session.dart';
import 'package:voidnet/views/utils/chat_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'components/empty_history.dart';

class ChatHistoryView extends StatefulWidget {
  const ChatHistoryView({super.key});

  @override
  State<ChatHistoryView> createState() => _ChatHistoryViewState();
}

class _ChatHistoryViewState extends State<ChatHistoryView> {
  late Future<List<ChatSession>> _chatSessionsFuture;

  @override
  void initState() {
    super.initState();
    _loadChatSessions();
  }

  void _loadChatSessions() {
    _chatSessionsFuture = ChatStorage.getAllChatSessions();
  }

  void confirmAndClearChatHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar historial?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ChatStorage.clearSessions();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Historial de chats eliminado.')),
      );
      setState(() {
        _loadChatSessions();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.history,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              VerticalSpacing(8.0),
              Text(
                AppLocalizations.of(context)!.historyDescription,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              VerticalSpacing(16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.recentConversations,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Material(
                    borderRadius: BorderRadius.circular(16.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.0),
                      onTap: () => confirmAndClearChatHistory(context),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(width: 1.0, color: const Color(0xFFE2E2E2)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                          child: Text(
                            AppLocalizations.of(context)!.clear,
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              VerticalSpacing(16.0),
              Expanded(
                child: FutureBuilder<List<ChatSession>>(
                  future: _chatSessionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const EmptyHistory();
                    }

                    final sessions = snapshot.data!;
                    return ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        return Column(
                          children: [
                            HistoryCard(
                              historyTitle: "${session.messages.length} mensajes",
                              historyDate: "Chat del ${session.startedAt.toLocal()}",
                              onCardTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatbotView(
                                      previousChatHistory: session.messages,
                                      chatSessionId: session.sessionId,
                                      chatStartedAt: session.startedAt
                                    ),
                                  ),
                                );
                              },
                            ),
                            VerticalSpacing(8.0),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}