import 'package:flutter/material.dart';
import 'package:voidnet/views/chatbot_view.dart';
import 'package:voidnet/views/components/history-card.dart';
import 'package:voidnet/views/styles/spaces.dart';
import 'package:voidnet/views/utils/chat_session.dart';
import 'package:voidnet/views/utils/chat_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'components/empty_history.dart';

class ChatHistoryView extends StatelessWidget {
  const ChatHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 32.0,
            bottom: 32.0,
            left: 24.0,
            right: 24.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.history,
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.start,
                textScaler: const TextScaler.linear(1.0),
              ),
              VerticalSpacing(8.0),
              Text(
                AppLocalizations.of(context)!.historyDescription,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.start,
                textScaler: const TextScaler.linear(1.0),
              ),
              VerticalSpacing(16.0),
              Text(
                AppLocalizations.of(context)!.recentConversations,
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.start,
                textScaler: const TextScaler.linear(1.0),
              ),
              VerticalSpacing(16.0),
              FutureBuilder<List<ChatSession>>(
                future: ChatStorage.getAllChatSessions(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final sessions = snapshot.data!;
                  return sessions.isNotEmpty
                      ? Expanded(
                        child: ListView.builder(
                          itemCount: sessions.length,
                          itemBuilder: (context, index) {
                            final session = sessions[index];
                            return Column(
                              children: [
                                HistoryCard(
                                  historyTitle:
                                      "${session.messages.length} mensajes",
                                  historyDate:
                                      "Chat del ${session.startedAt.toLocal()}",
                                  onCardTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatbotView(),
                                      ),
                                    );
                                  },
                                ),
                                VerticalSpacing(8.0),
                              ],
                            );
                          },
                        ),
                      )
                      : EmptyHistory();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
