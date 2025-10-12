import 'package:dio/dio.dart';
import 'auth_service.dart';
import 'history_model.dart';

class HistoryService {
  HistoryService._internal();
  static final HistoryService instance = HistoryService._internal();

  final String baseUrl = 'http://10.193.115.168:8000/api';

  Future<List<HistoryItem>> fetchHistory({bool includeText = false}) async {
    final token = await AuthService.instance.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Unauthorized');
    }
    final dio = Dio();
    final url = includeText ? '$baseUrl/history/?include_text=1' : '$baseUrl/history/';
    final resp = await dio.get(
      url,
      options: Options(headers: {
        'Authorization': 'Token $token',
      }),
    );
    if (resp.statusCode == 200) {
      final data = resp.data;
      final list = (data['results'] as List<dynamic>? ?? [])
          .map((e) => HistoryItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return list;
    } else if (resp.statusCode == 401) {
      throw Exception('Unauthorized');
    }
    throw Exception('Failed to fetch history: ${resp.statusCode}');
  }
}