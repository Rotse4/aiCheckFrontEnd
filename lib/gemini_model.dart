import 'package:my_flutter_project/logger.dart';

class GeminiModel {
  bool? success;
  Result? results;

  GeminiModel({this.success, this.results});

  GeminiModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true || json['success'] == 'true';
    results = json['results'] != null ? Result.fromJson(json['results']) : null;
  }
}

class Result {
  double? aiProbability; // 0.0 .. 1.0
  String? reasoning;

  Result({this.aiProbability, this.reasoning});

  Result.fromJson(Map<String, dynamic> json) {
    Logger.log("result from json ${json['ai_probability']} ${json['reasoning']}");
    final raw = json['ai_probability'];
    if (raw is num) {
      aiProbability = raw.toDouble();
    } else if (raw is String) {
      aiProbability = double.tryParse(raw);
    } else {
      aiProbability = null;
    }
    reasoning = json['reasoning']?.toString();
  }

  double get aiPercent => aiProbability != null ? aiProbability! * 100.0 : 0.0;
  double get humanProbability => aiProbability != null ? (1.0 - aiProbability!) : 0.0;
  double get humanPercent => humanProbability * 100.0;
}
