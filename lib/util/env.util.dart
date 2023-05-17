import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env{
  Future<String> getChatGptCradential()async{
    await dotenv.load();
    return dotenv.get("CHAT");
  }
}