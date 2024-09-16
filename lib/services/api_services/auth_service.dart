import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:liana_plant/models/master.dart';
import 'package:provider/provider.dart';

import '../token_service.dart';

/// A service class for handling authentication-related API calls.
class AuthService {
  /// The base URL of the API.
  final String apiUrl;

  /// The Dio instance used for making HTTP requests.
  final Dio dio;

  /// Constructs an [AuthService] with the given [apiUrl].
  /// Initializes the [dio] instance.
  AuthService(this.apiUrl) : dio = Dio();

  /// Logs in a user with the provided [email] and [password].
  ///
  /// Sends a POST request to the `/login` endpoint with the user's credentials.
  /// If the login is successful, returns a [Master] object created from the response data.
  /// Throws an [Exception] if the login fails or an error occurs during the request.
  ///
  /// - Parameters:
  ///   - email: The user's email address.
  ///   - password: The user's password.
  /// - Returns: A [Future] that resolves to a [Master] object.
  Future<Master> login(String email, String password) async {
    try {
      final response = await dio.post(
        '$apiUrl/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return Master.fromJson(data['data']);
      } else {
        throw Exception('Failed to log in');
      }
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  Future<void> register(
      Map<String, dynamic> userData, BuildContext context) async {
    final dio = Dio(
      BaseOptions(
        validateStatus: (status) {
          // Дозволити обробку всіх статусів коду, які ти хочеш
          return status! < 503; // дозволити статуси від 200 до 499
        },
      ),
    );
    final response = await dio.post(
      '${apiUrl}auth/master-register',
      data: userData,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      // Припустимо, токен міститься у data['token']
      final token = data['token'];

      // Збереження токену через TokenService
      // ignore: use_build_context_synchronously
      final tokenService = Provider.of<TokenService>(context, listen: false);
      await tokenService.saveToken(token);
    } else {
      throw Exception('Failed to register. Response code: ${response.data}');
    }
  }

  Future<void> sendSms(String phone) async {
    try {
      final response = await dio.post(
        '${apiUrl}auth/send-code',
        data: {
          'phone': phone,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print(data);
      } else {
        throw Exception('Failed to send sms');
      }
    } catch (e) {
      throw Exception('Error during send sms: $e');
    }
  }
}
