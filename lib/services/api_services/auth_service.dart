import 'package:flutter/cupertino.dart';
import 'package:liana_plant/models/master.dart';
import 'package:provider/provider.dart';
import '../token_service.dart';
import 'api_service.dart';

class AuthService {
  final ApiService apiService;

  AuthService(String apiUrl) : apiService = ApiService(apiUrl);

  Future<Master> login(String email, String password) async {
    final response = await apiService.postRequest('login', {'email': email, 'password': password});
    return Master.fromJson(response['data']);
  }

  Future<void> register(Map<String, dynamic> userData, BuildContext context) async {
    final response = await apiService.postRequest('auth/master-register', userData);
    final token = response['token'];
    final tokenService = Provider.of<TokenService>(context, listen: false);
    await tokenService.saveToken(token);
  }

  Future<void> sendSms(String phone) async {
    await apiService.postRequest('auth/send-code', {'phone': phone});
  }
}
