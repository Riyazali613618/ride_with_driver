import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/api/api_model/home/home_data_model.dart';
import 'package:r_w_r/api/api_service/api_repository.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ApiRepository apiRepository;

  HomeBloc({required this.apiRepository}) : super(const HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<RefreshHomeDataEvent>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(LoadHomeDataEvent event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    await _fetchHomeData(event.fcmToken, emit);
  }

  Future<void> _onRefreshHomeData(RefreshHomeDataEvent event, Emitter<HomeState> emit) async {
    // Don't show loading for refresh, just fetch data
    await _fetchHomeData(event.fcmToken, emit);
  }

  Future<void> _fetchHomeData(String? fcmToken, Emitter<HomeState> emit) async {
    try {
      final response = await apiRepository.getHome(fcmToken: fcmToken);
      final homeData = HomeInfoResponse.fromJson(response);

      emit(HomeLoaded(homeData: homeData));
    } on ApiException catch (e) {
      debugPrint('HomeBloc ApiException: ${e.message}');
      emit(HomeError(message: e.message));
    } catch (e) {
      debugPrint('HomeBloc Exception: $e');
      emit(const HomeError(message: 'Failed to load home data. Please try again.'));
    }
  }
}
