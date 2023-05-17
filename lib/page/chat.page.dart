import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:chat_gpt_clone/controller/message.provider.dart';
import 'package:chat_gpt_clone/service/chatgpt.service.dart';
import 'package:chat_gpt_clone/util/text_to_voice.dart';
import 'package:chat_gpt_clone/util/voice_to_text.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:music_visualizer/music_visualizer.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _user = const types.User(
      id: '82091008-a484-4a89-ae75-a22bf8d6f3ac', firstName: "Me");
  bool isSentButtonVisible = false;
  bool isRecording = false;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    TextToVoice().init();
    VoiceToText().init();
    ChatGptService().init();
  }

  @override
  Widget build(BuildContext context) {
    List<types.Message> messages = ref.watch(messageProvider);
    return Scaffold(
      body: Chat(
        messages: messages,
        onSendPressed: (v) async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Press double tap to cancel the voice message"),
            ),
          );
          await ref.read(messageProvider.notifier).addChat(v.text);
        },
        onMessageDoubleTap: (c, message) async {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Stopping")));
          await TextToVoice().stop();
        },
        customBottomWidget: Row(
          children: [
            !isRecording
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, bottom: 5),
                      child: Container(
                        // height: 70,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        decoration: const BoxDecoration(
                          color: Color(0xff2b2250),
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _textEditingController,
                                textInputAction: TextInputAction.go,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isCollapsed: true,
                                  hintText: "Message",
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                    color: const Color(0xffffffff)
                                        .withOpacity(0.5),
                                  ),
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: 5,
                                minLines: 1,
                                onChanged: (v) {
                                  setState(() {
                                    isSentButtonVisible = v != "";
                                  });
                                },
                                onSubmitted: (v) async {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Press double tap to cancel the voice message"),
                                    ),
                                  );
                                  await ref
                                      .read(messageProvider.notifier)
                                      .addChat(_textEditingController.text);
                                  setState(() {
                                    _textEditingController.text = "";
                                  });
                                },
                                textCapitalization:
                                    TextCapitalization.sentences,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                    color: Color(0xffffffff)),
                              ),
                            ),
                            Visibility(
                              visible: isSentButtonVisible,
                              child: IconButton(
                                constraints: const BoxConstraints(
                                  minHeight: 24,
                                  minWidth: 24,
                                ),
                                icon: const Icon(Icons.send),
                                color: Colors.white,
                                onPressed: () async {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Press double tap to cancel the voice message"),
                                    ),
                                  );
                                  await ref
                                      .read(messageProvider.notifier)
                                      .addChat(_textEditingController.text);
                                  setState(() {
                                    _textEditingController.text = "";
                                  });
                                },
                                splashRadius: 24,
                                tooltip: "Send Message",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15,),
                    child: MusicVisualizer(
                      barCount: 50,
                      colors: [
                        Colors.white!,
                        Colors.white!,
                        Colors.white!,
                        Colors.white!,
                      ],
                      duration: [900, 700, 600, 800, 500],
                    ),
                  ),
                ),
            Visibility(
              visible: isRecording,
              child: IconButton(
                constraints: const BoxConstraints(
                  minHeight: 24,
                  minWidth: 24,
                ),
                icon: const Icon(Icons.send),
                color: Colors.white,
                onPressed: () async{
                  setState(() {
                    isRecording = !isRecording;
                  });
                  print("123");
                  await ref.read(messageProvider.notifier).stopVoiceChat(false);
                },
                splashRadius: 24,
                tooltip: "Send Message",
              ),
            ),
            IconButton.filled(
              onPressed: () async{
                setState(() {
                  isRecording = !isRecording;
                });
                if(isRecording){
                  print("huuhduh");
                  await ref.read(messageProvider.notifier).addVoiceToChat();
                }else{
                  print("2");
                  await ref.read(messageProvider.notifier).stopVoiceChat(true);
                }

              },
              icon: Icon(
                isRecording?Icons.cancel:Icons.mic,
                color: Colors.white,
              ),
            )
          ],
        ),
        // customBottomWidget: IconButton(onPressed: (){},icon: Icon(Icons.mic)),
        user: _user,
        showUserAvatars: true,
        showUserNames: true,
        theme: const DarkChatTheme(),
      ),
    );
  }
}
