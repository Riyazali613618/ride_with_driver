import 'package:dio/dio.dart';

import '../../constants/token_manager.dart';

class DioClient {
  final Dio dio;

  DioClient({required String accessToken})
      : dio = Dio(
    BaseOptions(
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    ),
  ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = /*await _refreshToken()*/false;
            if (refreshed) {
              final token= await TokenManager.getToken();
              error.requestOptions.headers['Authorization'] =
              'Bearer $token';
              final retryResponse =
              await dio.fetch(error.requestOptions);
              return handler.resolve(retryResponse);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

 /* static Future<bool> _refreshToken() async {
    final refreshToken = await SecureStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await Dio().post(
        'https://api.ridewithdriverr.com/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      await SecureStorage.saveTokens(
        accessToken: response.data['accessToken'],
        refreshToken: response.data['refreshToken'],
      );
      return true;
    } catch (_) {
      await SecureStorage.clear();
      return false;
    }
  }*/
}
