import 'package:flutter/material.dart';
import 'package:flutter_gemini_chatbot/database/chat_history.dart';
import 'package:flutter_gemini_chatbot/providers/chat_provider.dart';
import 'package:flutter_gemini_chatbot/utility/utilities.dart';
import 'package:provider/provider.dart';

class ChatHistoryWidget extends StatelessWidget {
  const ChatHistoryWidget({
    super.key,
    required this.chat,
  });

  final ChatHistory chat;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        leading: const CircleAvatar(radius: 30, child: Icon(Icons.chat)),
        title: Text(
          chat.prompt,
          maxLines: 1,
        ),
        subtitle: Text(
          chat.response,
          maxLines: 1,
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () async {
          // navigate to chat screen
          final chatProvider = context.read<ChatProvider>();

          // repare the chat provider
          await chatProvider.prepareChatRoom(
              isNewChat: false, chatId: chat.chatId);

          chatProvider.setCurrentIndex(newIndex: 1);
          chatProvider.pageController.jumpToPage(1);
        },
        onLongPress: () {
          // show animated dialog to delete chat
          showMyAnimatedDialog(
            context: context,
            title: 'Delete Chat',
            content: 'Are you sure you want to delete this chat?',
            actionText: 'Delete',
            onActionPressed: (value) async {
              if (value) {
                // delete chat
                await context
                    .read<ChatProvider>()
                    .deleteChatMessages(chatId: chat.chatId);

                // delete chat history
                await chat.delete();
              }
            },
          );
        },
      ),
    );
  }
}
