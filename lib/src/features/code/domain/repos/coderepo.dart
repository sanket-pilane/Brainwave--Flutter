import 'dart:developer';

import 'package:brainwave/src/features/code/domain/model/code_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CodeRepo {
  // ignore: non_constant_identifier_names
  static Future<String> CodeGenerateRepo(
      List<CodeModel> previousMessages) async {
    try {
      final String additionalText =
          "You are a code generator. You must answer only in markdown code snippets. Use code comments for explanations.";

      Dio dio = Dio();
      String apiKey = dotenv.env['API_KEY'] ?? 'default_api_key';

      // Prepend additional text to each message's content
      List<CodeModel> updatedMessages = previousMessages.map((e) {
        return CodeModel(
          role: e.role,
          parts: e.parts
              .map((part) =>
                  CodePartModel(text: "$additionalText ${part.text}".trim()))
              .toList(),
        );
      }).toList();

      // Log to check the updated messages
      log("Updated Messages: ${updatedMessages.map((e) => e.toMap()).toList()}");

      final response = await dio.post(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey",
        data: {
          "contents": updatedMessages.map((e) => e.toMap()).toList(),
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
