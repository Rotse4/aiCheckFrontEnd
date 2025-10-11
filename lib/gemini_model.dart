import 'package:my_flutter_project/logger.dart';

class GeminiModel {
  bool? success;
  Result? results;

  GeminiModel({this.success, this.results});

  GeminiModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    results = json['results'] != null ? Result.fromJson(json['results']) : null;
  }
}

class Result {
  double? aiProbability;
  String? reasoning;

  Result({this.aiProbability, this.reasoning});

  Result.fromJson(Map<String, dynamic> json) {
    Logger.log("result from json ${json['ai_probability']} ${json['reasoning']}");
    aiProbability = json['ai_probability'];
    reasoning = json['reasoning'];
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   data['text'] = text;
  //   return data;
  // }
}
