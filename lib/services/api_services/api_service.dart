import 'package:dio/dio.dart';
import 'package:liana_plant/services/language_service.dart';
import 'package:liana_plant/services/token_service.dart';

class ApiService {
  final Dio dio;
  final String apiUrl;

  ApiService(this.apiUrl) : dio = Dio() {
    _initializeHeaders(); // Ініціалізуємо заголовки при створенні екземпляра
  }

  /// Ініціалізує заголовки один раз, включаючи локаль.
  Future<void> _initializeHeaders() async {
    final String locale = await LanguageService.getLanguage() ?? 'en';
    dio.options.headers['locale'] = locale;
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
  }

  /// Додає заголовки з токеном, якщо вони ще не були додані.
  Future<void> _addHeaders(Map<String, String>? additionalHeaders) async {
    String? token = await TokenService().getToken();
    Map<String, String> headers = {};

    // Додаємо токен, якщо він є
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    // Додаємо додаткові заголовки, якщо вони є
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    dio.options.headers.addAll(headers); // Додаємо заголовки до Dio
  }

  /// GET запит
  Future<Map<String, dynamic>> getRequest(String endpoint, {Map<String, String>? headers}) async {
    String url = '$apiUrl$endpoint';
    try {
      await _addHeaders(headers); // Додаємо заголовки з токеном та іншими параметрами
      final response = await dio.get(url);
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed GET request with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('GET request error($url): $e');
    }
  }

  /// POST запит
  Future<Map<String, dynamic>> postRequest(String endpoint, dynamic data, {Map<String, String>? headers}) async {
    String url = '$apiUrl$endpoint';
    try {
      await _addHeaders(headers); // Додаємо заголовки з токеном та іншими параметрами
      final response = await dio.post(url, data: data);
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed POST request with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('POST request error($url): $e');
    }
  }
}
