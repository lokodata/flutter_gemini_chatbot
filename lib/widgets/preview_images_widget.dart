import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gemini_chatbot/models/message.dart';
import 'package:flutter_gemini_chatbot/providers/chat_provider.dart';
import 'package:provider/provider.dart';

class PreviewImagesWidget extends StatelessWidget {
  const PreviewImagesWidget({super.key, this.message});

  final Message? message;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final messageToShow =
            message != null ? message!.imagesURLs : chatProvider.imagesFileList;
        final padding = message != null
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 8);

        return Padding(
          padding: padding,
          child: SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: messageToShow.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(message != null
                          ? message!.imagesURLs[index]
                          : chatProvider.imagesFileList[index].path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
