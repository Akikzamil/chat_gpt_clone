import 'package:chat_gpt_clone/service/chatgpt.service.dart';
import 'package:chat_gpt_clone/util/text_to_voice.dart';
import 'package:chat_gpt_clone/util/voice_to_text.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

class MessageProvider extends StateNotifier<List<types.TextMessage>> {
  MessageProvider() : super([]);
  final _user = const types.User(
      id: '82091008-a484-4a89-ae75-a22bf8d6f3ac', firstName: "Me");

  addChat(String text) async {
    _addUserChat(text);
    String repliedText = "...";
    state = [
      types.TextMessage(
          text: repliedText,
          id: const Uuid().v4(),
          status: types.Status.sending,
          showStatus: true,
          author: types.User(id: "chat", firstName: "ChatGpt")),
      ...state
    ];
    try{
    CTResponse? response = await ChatGptService().sendCompleTextRequest(text);
    state[0] = types.TextMessage(
        text: response?.choices.last.text ?? "Not Available",
        id: const Uuid().v4(),
        status: types.Status.delivered,
        showStatus: true,
        author: types.User(id: "chat", firstName: "ChatGpt"));
    state =[...state];
    await TextToVoice().speak(response?.choices.last.text ?? "Not Available");
    }catch(e){
      print(e);
      state[0] = types.TextMessage(
          text: "unable to process",
          id: const Uuid().v4(),
          status: types.Status.delivered,
          showStatus: true,
          author: types.User(id: "chat", firstName: "ChatGpt"));
      state =[...state];
      await TextToVoice().speak("unable to process");
    }

  }

  _addUserChat(String text) {
    state = [
      types.TextMessage(
          text: text,
          id: const Uuid().v4(),
          author: _user),
      ...state
    ];
  }

  addVoiceToChat()async{
    await VoiceToText().listen();
  }

  stopVoiceChat(bool isCanceled)async{
    if(isCanceled){
      VoiceToText().stop();
      VoiceToText().clearMessage();
    }else{
      await Future.delayed(Duration(seconds: 1));
      String message = VoiceToText().getMessage();
      if(message!=""){
        VoiceToText().stop();
        await addChat(message);
        VoiceToText().clearMessage();
      }else{
        VoiceToText().stop();
        VoiceToText().clearMessage();
      }
    }
  }
}

final messageProvider =
    StateNotifierProvider<MessageProvider, List<types.TextMessage>>(
        (ref) => MessageProvider());
