import 'package:dio/dio.dart';
import 'package:rwd/constants/api_constants.dart';
import 'package:rwd/constants/token_manager.dart';

import '../model/communications.dart';

abstract class CommunicationRepository {
  Future<List<Communication>> fetchCommunications();
}

class CommunicationRepositoryImpl implements CommunicationRepository {
  final Dio dio;

  CommunicationRepositoryImpl(this.dio);

  @override
  Future<List<Communication>> fetchCommunications() async {
    final token = await TokenManager.getRefreshToken();
    final response = await dio.get(
      ApiConstants.baseUrl+ApiConstants.communication,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    print(response.data);

    final List list = response.data['data']['communications'];
    return list.map((e) => Communication.fromJson(e)).toList();
  }
}
