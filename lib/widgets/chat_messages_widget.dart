import 'package:flutter/material.dart';
import 'package:flutter_gemini_chatbot/models/message.dart';
import 'package:flutter_gemini_chatbot/providers/chat_provider.dart';
import 'package:flutter_gemini_chatbot/widgets/assistance_message_widget.dart';
import 'package:flutter_gemini_chatbot/widgets/my_message_widget.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({
    super.key,
    required this.scrollController,
    required this.chatProvider,
  });

  final ScrollController scrollController;
  final ChatProvider chatProvider;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: chatProvider.inChatMessages.length,
      itemBuilder: (context, index) {
        // compare with time sent before showing the list

        //
        final message = chatProvider.inChatMessages[index];

        return message.role == Role.user
            ? MyMessageWidget(message: message)
            : AssistantMessageWidget(message: message.message.toString());
      },
    );
  }
}
