import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_gemini_chatbot/api/api_service.dart';
import 'package:flutter_gemini_chatbot/constants.dart';
import 'package:flutter_gemini_chatbot/database/boxes.dart';
import 'package:flutter_gemini_chatbot/database/chat_history.dart';
import 'package:flutter_gemini_chatbot/database/settings.dart';
import 'package:flutter_gemini_chatbot/database/user_model.dart';
import 'package:flutter_gemini_chatbot/models/message.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  // list of messages
  final List<Message> _inChatMessages = [];

  // page controller
  final PageController _pageController = PageController();

  // images file list
  final List<XFile> _imagesFileList = [];

  // index of the current screen
  int _currentIndex = 0;

  // current chatId
  String _currentChatId = '';

  // initialize generative model
  GenerativeModel? _model;

  // initialize text model
  GenerativeModel? _textModel;

  // initialize visuall model
  GenerativeModel? _visualModel;

  // current model
  String _modelType = 'gemini-pro';

  // loading bool
  bool _isLoading = false;

  // getters
  List<Message> get inChatMessages => _inChatMessages;
  PageController get pageController => _pageController;
  List<XFile> get imagesFileList => _imagesFileList;
  int get currentIndex => _currentIndex;
  String get currentChatId => _currentChatId;
  GenerativeModel? get model => _model;
  GenerativeModel? get textModel => _textModel;
  GenerativeModel? get visualModel => _visualModel;
  String get modelType => _modelType;
  bool get isLoading => _isLoading;

  // setters

  // set inChatMessages
  Future<void> setInChatMessages({required String chatId}) async {
    // get messages from hive database
    final messagesfromDB = await loadMessagesfromDB(chatId: chatId);

    for (final message in messagesfromDB) {
      if (_inChatMessages.contains(message)) {
        log('Message already exists');
        continue;
      }

      _inChatMessages.add(message);
    }

    notifyListeners();
  }

  // load the messages from db
  Future<List<Message>> loadMessagesfromDB({required String chatId}) async {
    // open the box of this chatId
    await Hive.openBox('${Constants.chatMessagesBox}$chatId');

    final messageBox = Hive.box('${Constants.chatMessagesBox}$chatId');

    final newData = messageBox.keys.map((e) {
      final message = messageBox.get(e);
      final messageData = Message.fromMap(Map<String, dynamic>.from(message));
      return messageData;
    }).toList();

    notifyListeners();

    return newData;
  }

  // set file list
  void setImagesFileList({required List<XFile> listValue}) {
    _imagesFileList.clear();
    _imagesFileList.addAll(listValue);
    notifyListeners();
  }

  // set the current model
  String setCurrentModel({required String newModel}) {
    _modelType = newModel;
    notifyListeners();
    return _modelType;
  }

  // function to set the model based on bool - isTextOnly
  Future<void> setModel({required bool isTextOnly}) async {
    // set the model
    if (isTextOnly) {
      _model = _textModel ??
          GenerativeModel(
            model: setCurrentModel(newModel: 'gemini-pro'),
            apiKey: ApiService.apiKey,
          );
    } else {
      _model = _visualModel ??
          GenerativeModel(
            model: setCurrentModel(newModel: 'gemini-pro-vision'),
            apiKey: ApiService.apiKey,
          );
    }

    notifyListeners();
  }

  // set current page index
  void setCurrentIndex({required int newIndex}) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  // set current chat id
  void setCurrentChatId({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

  // set loading
  void setLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  // delete chat
  Future<void> deleteChatMessages({required String chatId}) async {
    // check if the box is open
    if (!Hive.isBoxOpen('${Constants.chatMessagesBox}$chatId')) {
      // open the box of this chatId
      await Hive.openBox('${Constants.chatMessagesBox}$chatId');

      // delete the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();

      // close the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    } else {
      // delete the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();

      // close the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    }

    // get the current chat id if its not empty
    // we check if its the same chat id, if its the same then we set it to empty
    if (currentChatId.isNotEmpty) {
      if (currentChatId == chatId) {
        setCurrentChatId(newChatId: '');
        _inChatMessages.clear();
        notifyListeners();
      }
    }
  }

  // prepare chat room
  Future<void> prepareChatRoom({
    required bool isNewChat,
    required String chatId,
  }) async {
    if (!isNewChat) {
      // load the chat messages from db
      final chatHistory = await loadMessagesfromDB(chatId: chatId);

      // clear iinChatMessages
      _inChatMessages.clear();

      for (final message in chatHistory) {
        _inChatMessages.add(message);
      }

      // set the current chat id
      setCurrentChatId(newChatId: chatId);
    } else {
      // clear iinChatMessages
      _inChatMessages.clear();

      // set the current chat id
      setCurrentChatId(newChatId: chatId);
    }
  }

  // send message to gemini and get the streamed response
  Future<void> sentMessage(
      {required String message, required bool isTextOnly}) async {
    // set the model
    await setModel(isTextOnly: isTextOnly);

    // set loading
    setLoading(value: true);

    // get the chatId
    String chatId = getChatId();

    // list of history messages
    List<Content> history = [];

    // get the chat history
    history = await getHistory(chatId: chatId);

    // get the imagesURLs
    List<String> imagesURLs = getImagesURLs(isTextOnly: isTextOnly);

    // open the box of this chatId
    final messagesBox =
        await Hive.openBox('${Constants.chatMessagesBox}$chatId');

    // get the last user message id from messagesBox
    final userMessageId = messagesBox.keys.length;

    // assistant message id
    final assistantMessageId = messagesBox.keys.length + 1;

    // user message
    final userMessage = Message(
      messageId: userMessageId.toString(),
      chatId: chatId,
      role: Role.user,
      message: StringBuffer(message),
      imagesURLs: imagesURLs,
      timeSent: DateTime.now(),
    );

    // add the user message to the list on inChatMessages
    _inChatMessages.add(userMessage);

    notifyListeners();

    if (currentChatId.isEmpty) {
      setCurrentChatId(newChatId: chatId);
    }

    // send the message to the model and wait for the response
    await sendMessageAndWaitForResponse(
      message: message,
      chatId: chatId,
      isTextOnly: isTextOnly,
      history: history,
      userMessage: userMessage,
      modelMessageId: assistantMessageId.toString(),
      messagesBox: messagesBox,
    );
  }

  // method to send message and wait for streamed response
  Future<void> sendMessageAndWaitForResponse({
    required String message,
    required String chatId,
    required bool isTextOnly,
    required List<Content> history,
    required Message userMessage,
    required String modelMessageId,
    required Box messagesBox,
  }) async {
    // start the session - only send history if its text-only
    final chatSession = _model!.startChat(
      history: history.isEmpty || !isTextOnly ? null : history,
    );

    // get content
    final content = await getContent(message: message, isTextOnly: isTextOnly);

    // assistant message
    final assistantMessage = userMessage.copyWith(
      messageId: modelMessageId,
      role: Role.assistant,
      message: StringBuffer(),
      timeSent: DateTime.now(),
    );

    // add the assistant message to the list on inChatMessages
    _inChatMessages.add(assistantMessage);

    notifyListeners();

    // wait for the stream response
    chatSession.sendMessageStream(content).asyncMap((event) {
      return event;
    }).listen((event) {
      _inChatMessages
          .firstWhere((element) =>
              element.messageId == assistantMessage.messageId &&
              element.role.name == Role.assistant.name)
          .message
          .write(event.text);
      log('event: ${event.text}');
      notifyListeners();
    }, onDone: () async {
      log('Stream Done');

      // set loading to falase
      setLoading(value: false);

      // save the message to the hive database
      await saveMessagesToDB(
        chatId: chatId,
        userMessage: userMessage,
        assistantMessage: assistantMessage,
        messagesBox: messagesBox,
      );
    }).onError((error, stackTrace) {
      // set loading
      setLoading(value: false);
    });
  }

  // method to save the message to the hive database
  Future<void> saveMessagesToDB(
      {required String chatId,
      required Message userMessage,
      required Message assistantMessage,
      required Box messagesBox}) async {
    // save the user message
    await messagesBox.add(userMessage.toMap());

    // save the assistant message
    await messagesBox.add(assistantMessage.toMap());

    // save the chat history with the same chatId
    // if its already exists, it will be overwritten, if not then it will be created
    final chatHistoryBox = Boxes.getChatHistory();

    final chatHistory = ChatHistory(
      chatId: chatId,
      prompt: userMessage.message.toString(),
      response: assistantMessage.message.toString(),
      imagesURLs: userMessage.imagesURLs,
      timestamp: DateTime.now(),
    );

    await chatHistoryBox.put(chatId, chatHistory);

    // close the box
    await messagesBox.close();
  }

  // get content method
  Future<Content> getContent(
      {required String message, required bool isTextOnly}) async {
    if (isTextOnly) {
      // generate text from text-only input
      return Content.text(message);
    } else {
      // generate text from visual input
      final imageFutures = _imagesFileList
          .map((imageFile) => imageFile.readAsBytes())
          .toList(growable: false);

      final imageBytes = await Future.wait(imageFutures);
      final prompt = TextPart(message);
      final imageParts = imageBytes
          .map((bytes) => DataPart('image/jpeg', Uint8List.fromList(bytes)))
          .toList();

      return Content.multi([prompt, ...imageParts]);
    }
  }

  // method to get the imagesURLs
  List<String> getImagesURLs({required bool isTextOnly}) {
    List<String> imagesURLs = [];

    if (!isTextOnly && imagesFileList.isNotEmpty) {
      for (final image in imagesFileList) {
        imagesURLs.add(image.path);
      }
    }

    return imagesURLs;
  }

  // method to get the chat history
  Future<List<Content>> getHistory({required String chatId}) async {
    List<Content> history = [];

    if (currentChatId.isNotEmpty) {
      await setInChatMessages(chatId: chatId);

      for (final message in inChatMessages) {
        if (message.role == Role.user) {
          history.add(Content.text(message.message.toString()));
        } else {
          history.add(Content.model([TextPart(message.message.toString())]));
        }
      }
    }

    return history;
  }

  // getChatId and check if it is empty
  String getChatId() {
    if (currentChatId.isEmpty) {
      return const Uuid().v4();
    } else {
      return currentChatId;
    }
  }

  // init Hive box
  static initHive() async {
    final dir = await path.getApplicationDocumentsDirectory();

    Hive.init(dir.path);

    await Hive.initFlutter(Constants.geminiDb);

    // chat history register adapters and box
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());
      // open the chat history box
      await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
    }

    // user adapter and box
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
      // open the user box
      await Hive.openBox<UserModel>(Constants.userBox);
    }

    // setting adapter and box
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
      // open the settings box
      await Hive.openBox<Settings>(Constants.settingsBox);
    }
  }
}
