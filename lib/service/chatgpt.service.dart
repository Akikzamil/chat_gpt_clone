import 'package:chat_gpt_clone/constant/constant.dart';
import 'package:chat_gpt_clone/util/env.util.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';

class ChatGptService {
  static late final openAI ;

  init()async{
    String token = await Env().getChatGptCradential();
    openAI = OpenAI.instance.build(
        token: token,
        baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 10),connectTimeout: const Duration(seconds: 10),sendTimeout: const Duration(seconds: 10)),
        enableLog: true);

  }

  Future<CTResponse?> sendCompleTextRequest(String text)async{
    final request = CompleteText(
        prompt: text,
        maxTokens: 2000,
        model: Model.textDavinci3);

    final CTResponse? response = await openAI.onCompletion(request: request);
    return response;
  }

  Stream<CTResponse> sendCompleTextRequestSSE(String text)async*{
    final request = CompleteText(
        prompt: text,
        maxTokens: 2000,
        model: Model.textDavinci3);

      yield* openAI.onCompletionSSE(request: request);
  }

}
