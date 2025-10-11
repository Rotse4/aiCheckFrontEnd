import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:my_flutter_project/dashboard_controller.dart';
import 'package:my_flutter_project/logger.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final DashboardController controller = Get.put(DashboardController());
  String? _fileName;

  Future<void> _pickFile() async {
    Logger.log('Pick File button pressed');
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['docx'],
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path!;
        setState(() {
          _fileName = result.files.first.name;
        });

        print('Uploading file: $_fileName');
        final extractedText = await controller.uploadDocx(filePath);

        if (extractedText != null) {
          controller.textController.text = extractedText;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File uploaded and text extracted.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to extract text from the document.'),
            ),
          );
        }
      } else {
        print('No file selected');
      }
    } catch (e) {
      print('Error picking file: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  Future<void> _analyzeEssay() async {
    await controller.analyzeEssay();
  }

  @override
  void dispose() {
    controller.textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Essay Analyzer Dashboard'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: controller.textController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Enter or paste text to analyze',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // File upload
                ElevatedButton.icon(
                  onPressed: controller.loading.value ? null : _pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload .docx File'),
                ),
                const SizedBox(height: 10),
                Text(
                  _fileName != null
                      ? 'Selected file: $_fileName'
                      : 'No file selected',
                ),
                const SizedBox(height: 20),

                // Analyze button
                ElevatedButton(
                  onPressed: controller.loading.value ? null : _analyzeEssay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: controller.loading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Analyze Essay',
                          style: TextStyle(fontSize: 16),
                        ),
                ),

                const SizedBox(height: 20),

                // Error display
                if (controller.errorMessage.isNotEmpty)
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),

                // Results display
                if (controller.result.isNotEmpty) ...[
                  const Divider(height: 30),
                  const Text(
                    'Analysis Result',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verdict: ${controller.result["verdict"] ?? "Unknown"}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'AI Probability: ${controller.result["aiProbability"] ?? "?"}%',
                          ),
                          Text(
                            'Human Probability: ${controller.result["humanProbability"] ?? "?"}%',
                          ),
                          Text(
                            'Confidence: ${controller.result["confidence"] ?? "?"}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.result["reasoning"] ??
                                'No reasoning provided.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}
