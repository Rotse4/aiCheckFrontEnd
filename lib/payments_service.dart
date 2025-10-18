import 'package:dio/dio.dart';
import 'auth_service.dart';

class PaymentsService {
  PaymentsService._internal();
  static final PaymentsService instance = PaymentsService._internal();

  final String baseUrl = 'http://10.193.115.168:8000/api';

  Future<int> fetchWalletBalance() async {
    final token = await AuthService.instance.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Unauthorized');
    }
    final dio = Dio();
    final resp = await dio.get(
      '$baseUrl/wallet/',
      options: Options(headers: {'Authorization': 'Token $token'}),
    );
    if (resp.statusCode == 200) {
      return (resp.data['balance'] as num).toInt();
    }
    throw Exception('Failed to fetch wallet: ${resp.statusCode}');
  }

  Future<void> initiateStkPush({required int credits, required String phone}) async {
    final token = await AuthService.instance.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Unauthorized');
    }
    final dio = Dio();
    final resp = await dio.post(
      '$baseUrl/payments/initiate/',
      options: Options(headers: {'Authorization': 'Token $token', 'Content-Type': 'application/json'}),
      data: {'credits': credits, 'phone': phone},
    );
    if (resp.statusCode != 200) {
      throw Exception('STK push failed: ${resp.data}');
    }
  }
}