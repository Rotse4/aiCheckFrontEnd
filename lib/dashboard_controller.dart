import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_flutter_project/logger.dart';

class DashboardController extends GetxController {
  final TextEditingController textController = TextEditingController();
  var result = {}.obs;
  var loading = false.obs;
  var errorMessage = ''.obs;

  // Backend base URL (update this to your Node.js API or local server)
  final String baseUrl = 'http://192.168.2.152:8000/api/analyze/';

  /// Analyze essay text (calls your backend `/api/analyze` endpoint)
  Future<void> analyzeEssay() async {
    final text = textController.text.trim();

    if (text.isEmpty) {
      errorMessage.value = 'Please enter some text to analyze';
      return;
    }

    loading.value = true;
    errorMessage.value = '';

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        // headers: {
        //   'Content-Type': 'application/json',
        //   // Optionally include your user session header or auth token
        // },
        body: {'essay': text},
      );
      Logger.log("respone body ${response.body}");

      if (response.statusCode == 200) {
        Logger.log("status code ${response.statusCode}");
        final Map<String, dynamic> data = jsonDecode(response.body);
        // print(object)

        if (data['success'] == true && data['result'] != null) {
          result.value = data['result'];
        } else {
          errorMessage.value =
              data['error'] ?? 'Unexpected response from the server';
        }
      } else {
        print("error fetching ${response.body}");
        errorMessage.value =
            'Failed: ${response.statusCode} - ${response.reasonPhrase}';

        print("error fetching ${errorMessage.value}");
      }
    } catch (e) {
      Logger.log("error cought $e");
      errorMessage.value = 'Errorss: $e';
    } finally {
      loading.value = false;
    }
  }

  /// Upload a .docx file and extract text (similar to `/api/upload-docx`)
  Future<String?> uploadDocx(String filePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload-docx'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['text'];
        } else {
          errorMessage.value = data['error'] ?? 'Failed to extract text';
        }
      } else {
        errorMessage.value = 'Upload failed: ${response.statusCode}';
      }
    } catch (e) {
      print(e);
      errorMessage.value = 'Error uploading file: $e';
    }

    return null;
  }
}
