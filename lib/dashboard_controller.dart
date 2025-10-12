import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:file_picker/file_picker.dart';
import 'package:my_flutter_project/gemini_model.dart';
import 'package:my_flutter_project/logger.dart';
import 'package:my_flutter_project/auth_service.dart';

class DashboardController extends GetxController {
  final TextEditingController textController = TextEditingController();
  Rx<GeminiModel> result = GeminiModel().obs;
  var loading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  // Backend base URL (Django API root)
  final String baseUrl = 'http://10.193.115.168:8000/api';

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
      final token = await AuthService.instance.getToken();
      final response = await Dio().post(
        '$baseUrl/analyze/',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Token $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {'essay': text},
      );
      Logger.log("respone body ${response.data}");

      if (response.statusCode == 200) {
        var geminiData = GeminiModel.fromJson(response.data);
        result.value = geminiData;
        Logger.log("result sucess ${geminiData.success}");
        Logger.log("result ${geminiData.results?.reasoning} ${geminiData.results?.aiProbability}");
      } else if (response.statusCode == 401) {
        errorMessage.value = 'Unauthorized. Please log in first.';
      }
    } catch (e) {
      Logger.log("error cought $e");
      errorMessage.value = 'Error: $e';
    } finally {
      loading.value = false;
    }
  }

  /// Upload a .docx file and extract text (web-friendly: uses bytes)
  Future<String?> uploadDocx(PlatformFile file) async {
    try {
      if (file.bytes == null) {
        errorMessage.value = 'Selected file has no bytes (not supported on this platform).';
        return null;
      }
      final token = await AuthService.instance.getToken();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
        ),
      });

      final dio = Dio();
      final response = await dio.post(
        '$baseUrl/upload-docx',
        data: formData,
        options: Options(headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Token $token',
          // Content-Type will be set automatically for FormData
        }),
      );

      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        if (data['success'] == true) {
          return data['text'];
        } else {
          errorMessage.value = data['error'] ?? 'Failed to extract text';
        }
      } else {
        errorMessage.value = 'Upload failed: ${response.statusCode}';
      }
    } catch (e) {
      Logger.log('Upload error: $e');
      errorMessage.value = 'Error uploading file: $e';
    }

    return null;
  }
}
