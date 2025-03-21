import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VideoRepo {
  static Future<String> VideoGenerateRepo(String prompt) async {
    const url =
        'https://api.replicate.com/v1/models/minimax/video-01/predictions';
    String apiKey = dotenv.env['REPLICATE_API_KEY'] ?? 'default_api_key';

    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final body = {
      'input': {
        'prompt': prompt,
      }
    };

    try {
      Dio dio = Dio();

      // Step 1: Send the POST request
      final response = await dio.post(
        url,
        options: Options(headers: headers),
        data: json.encode(body),
      );

      log('Response Status Code: ${response.statusCode}');
      log('Response Data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 202) {
        final responseData = response.data;
        String getUrl = responseData['urls']['get']; // Polling URL

        // Step 2: Poll the API for the result
        return await _pollForVideo(getUrl, headers, dio);
      } else {
        log('Failed with status code: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      log(e.toString());
      return '';
    }
  }

  // Poll the API for the video result (up to 4 minutes)
  static Future<String> _pollForVideo(
      String getUrl, Map<String, String> headers, Dio dio) async {
    int retries = 48; // Max retries (up to 4 min)
    int delaySeconds = 5; // Start polling every 5 sec

    while (retries > 0) {
      await Future.delayed(Duration(seconds: delaySeconds));

      final response =
          await dio.get(getUrl, options: Options(headers: headers));

      log('Polling Response: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['status'] == 'succeeded' &&
            responseData['output'] != null) {
          return responseData['output']; // Return video URL
        } else if (responseData['status'] == 'failed') {
          return ''; // Stop polling if failed
        }

        // If still processing, increase delay gradually (up to 15s)
        if (responseData['status'] == 'processing') {
          delaySeconds = (delaySeconds < 15) ? delaySeconds + 2 : 15;
        }
      }

      retries--;
    }

    log('Timeout: Video generation took too long.');
    return ''; // Return empty string if timeout
  }
}
