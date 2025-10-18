import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:my_flutter_project/dashboard_controller.dart';
import 'package:my_flutter_project/logger.dart';
import 'package:my_flutter_project/auth_service.dart';
import 'package:my_flutter_project/ui/app_shell.dart';

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
        final platformFile = result.files.first;
        setState(() {
          _fileName = platformFile.name;
        });

        print('Uploading file: $_fileName');
        final extractedText = await controller.uploadDocx(platformFile);

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
    // Do not dispose controller.textController here; the GetX controller owns it.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'AI Essay Analyzer',
      selectedIndex: 0,
      body: Obx(() {
        final theme = Theme.of(context);
        final width = MediaQuery.of(context).size.width;
        final isWide = width >= 900;

        final editorCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paste or Upload your essay',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.textController,
                  maxLines: 12,
                  decoration: const InputDecoration(
                    labelText: 'Enter or paste text to analyze',
                    hintText: 'Type or paste your essay here... ',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: controller.loading.value ? null : _pickFile,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload .docx'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _fileName == null ? 'No file selected' : 'Selected: $_fileName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: controller.loading.value ? null : _analyzeEssay,
                      icon: controller.loading.value
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.analytics),
                      label: const Text('Analyze'),
                    ),
                  ],
                ),
                if (controller.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(color: theme.colorScheme.onErrorContainer),
                    ),
                  ),
                  if (controller.insufficientCredits.value) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed('/purchase'),
                        icon: const Icon(Icons.shopping_bag_outlined),
                        label: const Text('Buy Credits'),
                      ),
                    ),
                  ],
                ]
              ],
            ),
          ),
        );

        final result = controller.result.value.results;
        final resultCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: result == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Analysis Result', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(
                        'Run an analysis to see AI/Human probabilities with reasoning.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Analysis Result', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Text('AI Probability: ${result.aiPercent.toStringAsFixed(1)}%'),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: (result.aiProbability ?? 0.0).clamp(0.0, 1.0)),
                      const SizedBox(height: 12),
                      Text('Human Probability: ${result.humanPercent.toStringAsFixed(1)}%'),
                      const SizedBox(height: 20),
                      Text('Reasoning', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(result.reasoning ?? 'No reasoning provided.'),
                    ],
                  ),
          ),
        );

        final content = isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: editorCard),
                  Expanded(flex: 5, child: resultCard),
                ],
              )
            : Column(
                children: [
                  editorCard,
                  resultCard,
                ],
              );

        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: SingleChildScrollView(child: content),
            ),
          ),
        );
      }),
    );
  }
}
