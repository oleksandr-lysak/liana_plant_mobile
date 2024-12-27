import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/models/user.dart';
import 'package:liana_plant/services/user_service.dart';
import 'package:provider/provider.dart';
import '../token_service.dart';
import 'api_service.dart';

class AuthService {
  final ApiService apiService;

  AuthService() : apiService = ApiService(AppConstants.serverUrl);

  Future<bool> confirmLogin(
      String phone, int code, BuildContext context) async {
    try {
      final response = await apiService
          .postRequest('auth/verify-code', {'sms_code': code, 'phone': phone});

      if (response.containsKey('error')) {
        final errorMessage = FlutterI18n.translate(context, response['error']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        return false;
      }

      final token = response['token'];
      final tokenService = TokenService();
      await tokenService.saveToken(token);

      final int userId = response['user']['id'];
      final String userName = response['user']['name'];
      final masterData = response['user']['master_data'];
      Map<String, dynamic>? jsonMaster;
      if (masterData != null) {
        jsonMaster = {
          'id': masterData['id'],
          'name': masterData['name'],
          'description': masterData['description'],
          'photo': masterData['photo'],
          'phone': masterData['phone'],
          'address': masterData['address'],
          'services': masterData['services'],
          'speciality_id': masterData['speciality_id'],
          'age': masterData['age'],
          'longitude': masterData['longitude'],
          'latitude': masterData['latitude'],
        };
      }
      Map<String, dynamic> jsonUser = {
        'id': userId,
        'name': userName,
        'phone': phone,
        'master': jsonMaster,
      };

      final User user = User.fromJson(jsonUser);
      UserService userService = UserService();
      await userService.saveUserData(user);
      return true;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(FlutterI18n.translate(context, 'system.filed_verify'))),
      );
      return false;
    }
  }

  Future<void> register(
      Map<String, dynamic> userData, BuildContext context) async {
    final response =
        await apiService.postRequest('auth/master-register', userData);
    final token = response['token'];
    final tokenService = Provider.of<TokenService>(context, listen: false);
    final userService = Provider.of<UserService>(context, listen: false);
    await tokenService.saveToken(token);
    User user = User.fromJson(response);
    await userService.saveUserData(user);
  }

  Future<void> sendSms(String phone) async {
    var result =
        await apiService.postRequest('auth/send-code', {'phone': phone});
    print(result);
  }

  Future<void> registerClient(
      String name, String phone, BuildContext context) async {
    final response = await apiService
        .postRequest('auth/client-register', {'name': name, 'phone': phone});
    final token = response['token'];
    final tokenService =
        TokenService(); //Provider.of<TokenService>(context, listen: false);
    final userService =
        UserService(); // Provider.of<UserService>(context, listen: false);
    await tokenService.saveToken(token);
    Map<String, dynamic> data = {
      'id': response['user']['id'],
      'name': response['user']['name'],
      'phone': response['user']['client_data']['phone'],
    };
    User user = User.fromJson(data);
    await userService.saveUserData(user);
  }
}
