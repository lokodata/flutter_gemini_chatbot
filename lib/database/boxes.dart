import 'package:flutter_gemini_chatbot/constants.dart';
import 'package:flutter_gemini_chatbot/database/chat_history.dart';
import 'package:flutter_gemini_chatbot/database/settings.dart';
import 'package:flutter_gemini_chatbot/database/user_model.dart';
import 'package:hive/hive.dart';

class Boxes {
  // get the chat history box
  static Box<ChatHistory> getChatHistory() =>
      Hive.box<ChatHistory>(Constants.chatHistoryBox);

  // get the user box
  static Box<UserModel> getUser() => Hive.box<UserModel>(Constants.userBox);

  // get the settings box
  static Box<Settings> getSettings() =>
      Hive.box<Settings>(Constants.settingsBox);
}
