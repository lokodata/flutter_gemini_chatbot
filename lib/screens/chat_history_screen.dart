import 'package:flutter/material.dart';
import 'package:flutter_gemini_chatbot/database/boxes.dart';
import 'package:flutter_gemini_chatbot/database/chat_history.dart';
import 'package:flutter_gemini_chatbot/widgets/chat_history_widget.dart';
import 'package:flutter_gemini_chatbot/widgets/empty_history_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text('Chat History'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<Box<ChatHistory>>(
        valueListenable: Boxes.getChatHistory().listenable(),
        builder: (context, box, _) {
          final chatHistory = box.values.toList().cast<ChatHistory>();

          return chatHistory.isEmpty
              ? const EmptyHistoryWidget()
              : ListView.builder(
                  itemCount: chatHistory.length,
                  itemBuilder: (context, index) {
                    final chat = chatHistory[index];

                    return ChatHistoryWidget(chat: chat);
                  },
                );
        },
      ),
    );
  }
}
