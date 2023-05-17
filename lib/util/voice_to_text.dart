import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceToText {
  static stt.SpeechToText speech = stt.SpeechToText();
  static late bool isAvailable;
  static String message = "";

  init() async {
    isAvailable = await speech.initialize(onStatus: (s) {
      print("status...................................");
      print(s);
    }, onError: (e) {
      print("error...................................");
      print(e);
    });
  }

  listen() {
    if ( isAvailable ) {
      speech.listen( onResult: (result){
        message=result.recognizedWords;
      } );
      print(message);
    }else{
      print("sorry");
    }
  }

  String getMessage()=>message;
  String clearMessage()=>message="";

  stop(){
    speech.stop();
  }
}
