import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AudioRepo {
  static Future<String> AudioGenerateRepo(String prompt) async {
    try {
      final dio = Dio();
      const apiUrl = "https://api.replicate.com/v1/predictions";
      String apiToken = dotenv.env['REPLICATE_API_KEY'] ?? 'default_api_key';

      final response = await dio.post(
        apiUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer $apiToken",
            "Content-Type": "application/json",
            "Prefer": "wait"
          },
        ),
        data: jsonEncode({
          "version":
              "8cf61ea6c56afd61d8f5b9ffd14d7c216c0a93844ce2d82ac1c9ecc9c7f24e05",
          "input": {"prompt_b": prompt}
        }),
      );

      if (response.statusCode == 202 || response.statusCode == 201) {
        final String getUrl = response.data["urls"]["get"];
        return await _pollForResult(getUrl);
      } else {
        log("Unexpected status code: ${response.statusCode}");
        return "";
      }
    } catch (e) {
      log("Error in AudioGenerateRepo: $e");
      return "";
    }
  }

  static Future<String> _pollForResult(String url) async {
    final dio = Dio();
    const int maxAttempts = 10;
    int attempt = 0;
    String apiToken = dotenv.env['REPLICATE_API_KEY'] ?? 'default_api_key';

    while (attempt < maxAttempts) {
      await Future.delayed(Duration(seconds: 2));
      final response = await dio.get(
        url,
        options: Options(
          headers: {"Authorization": "Bearer $apiToken"},
        ),
      );

      if (response.data["status"] == "succeeded") {
        return response.data["output"]["audio"] ?? "";
      } else if (response.data["status"] == "failed") {
        log("Generation failed");
        return "";
      }
      print(attempt);
      attempt++;
    }

    log("Timed out waiting for audio generation");
    return "";
  }
}
