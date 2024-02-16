import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const ai = User(id: 'gemini');
const user = User(id: 'user');

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chat = useState<ChatSession?>(null);
    final messages = useState<List<types.Message>>([]);

    void addMessage(User author, String text) {
      final timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      final message = types.TextMessage(
        author: author,
        id: timeStamp,
        text: text,
      );
      messages.value = [message, ...messages.value];
    }

    Future<void> onSendPressed(PartialText text) async {
      addMessage(user, text.text);

      final content = Content.text(text.text);
      final response = await chat.value?.sendMessage(content);

      addMessage(ai, response?.text ?? '取得できませんでした');
    }

    useEffect(() {
      const apiKey = String.fromEnvironment('API_KEY');
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
      );

      chat.value = model.startChat();

      return null;
    }, [],);

    return Scaffold(
      body: Chat(
        user: user,
        messages: messages.value,
        onSendPressed: onSendPressed,
      ),
    );
  }
}
