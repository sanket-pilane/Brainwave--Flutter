import 'dart:convert';
import 'dart:developer';
import 'dart:async'; // For polling

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageRepo {
  static Future<String> imageGenerateRepo(String prompt) async {
    const url =
        'https://api.replicate.com/v1/models/black-forest-labs/flux-1.1-pro/predictions';
    String apiKey = dotenv.env['REPLICATE_API_KEY'] ?? 'default_api_key';

    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
      'Prefer': 'wait',
    };

    final body = {
      'input': {
        'prompt': prompt,
        'aspect_ratio': '1:1',
        'output_format': 'webp',
        'output_quality': 80,
        'safety_tolerance': 2,
        'prompt_upsampling': true,
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

      if (response.statusCode == 201) {
        final responseData = response.data;
        String getUrl = responseData['urls']['get']; // This is the polling URL

        // Step 2: Poll the API until the image is ready
        return await _pollForImage(getUrl, headers, dio);
      } else {
        print('Failed with status code: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      log(e.toString());
      return '';
    }
  }

  // Helper function to poll the API
  static Future<String> _pollForImage(
      String getUrl, Map<String, String> headers, Dio dio) async {
    int retries = 20; // Maximum retries before giving up
    const delayDuration = Duration(seconds: 2); // Wait time between polls

    while (retries > 0) {
      await Future.delayed(delayDuration);

      final response =
          await dio.get(getUrl, options: Options(headers: headers));

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == 'succeeded' &&
            responseData['output'] != null) {
          return responseData['output']; // Return the final image URL
        } else if (responseData['status'] == 'failed') {
          return ''; // Generation failed
        }
      }

      retries--;
    }

    return ''; // Return empty string if timeout
  }
}
