import 'dart:developer';

import 'package:brainwave/src/features/code/domain/model/chat_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatRepo {
  // ignore: non_constant_identifier_names
  static Future<String> ChatGenerateRepo(
      List<ChatModel> previousMessages) async {
    try {
      Dio dio = Dio();
      String apiKey = dotenv.env['API_KEY'] ?? 'default_api_key';

      final response = await dio.post(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey",
        data: {
          "contents": previousMessages.map((e) => e.toMap()).toList(),
          "generationConfig": {
            "temperature": 1,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 8192,
            "responseMimeType": "text/plain"
          }
        },
      );

      if (response.statusCode! >= 200 && response.statusCode! <= 300) {
        return response
            .data["candidates"].first['content']['parts'].first['text'];
      }

      return '';
    } catch (e) {
      log(e.toString());
      return '';
    }
  }
}
