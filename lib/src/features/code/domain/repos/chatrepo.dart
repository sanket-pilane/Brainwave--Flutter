import 'dart:developer';

import 'package:brainwave/src/features/code/domain/model/chat_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatRepo {
  static ChatGenerateRepo(List<ChatModel> previousMessages) async {
    try {
      Dio dio = Dio();
      String? apikey = dotenv.env["API_KEY"];

      final response = dio.post(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apikey}",
          data: {
            "contents": previousMessages.map((e) => e.toMap()).toList(),
            "generationConfig": {
              "temperature": 1,
              "topK": 40,
              "topP": 0.95,
              "maxOutputTokens": 8192,
              "responseMimeType": "text/plain"
            }
          });

      log(response.toString());
    } catch (e) {
      log(e.toString());
    }
  }
}
