import 'package:flutter/material.dart';
import 'package:flutter_gemini_chatbot/providers/chat_provider.dart';
import 'package:flutter_gemini_chatbot/utility/utilities.dart';
import 'package:flutter_gemini_chatbot/widgets/bottom_chat_field.dart';
import 'package:flutter_gemini_chatbot/widgets/chat_messages_widget.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // scroll controller
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0.0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(builder: (context, chatProvider, child) {
      if (chatProvider.inChatMessages.isNotEmpty) {
        _scrollToBottom();
      }

      // auto scroll to bottom on new message
      chatProvider.addListener(() {
        if (chatProvider.inChatMessages.isNotEmpty) {
          _scrollToBottom();
        }
      });

      return Scaffold(
        // appbar
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          centerTitle: true,
          title: const Text('Chat with Gemini'),
          actions: [
            if (chatProvider.inChatMessages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      // show my animated dialog to start new chat
                      showMyAnimatedDialog(
                          context: context,
                          title: 'Start New Chat',
                          content: 'Are you sure you want to start a new chat?',
                          actionText: 'Start',
                          onActionPressed: (value) async {
                            if (value) {
                              // prepare chatroom
                              await chatProvider.prepareChatRoom(
                                isNewChat: true,
                                chatId: '',
                              );
                            }
                          });
                    },
                  ),
                ),
              )
          ],
        ),

        // body
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child:
                      // check if there are messages
                      chatProvider.inChatMessages.isEmpty
                          ? const Center(
                              child: Text('No messages yet'),
                            )
                          : ChatMessages(
                              scrollController: _scrollController,
                              chatProvider: chatProvider),
                ),

                // input field
                BottomChatField(
                  chatProvider: chatProvider,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
