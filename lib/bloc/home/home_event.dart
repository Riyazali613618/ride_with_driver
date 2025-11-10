import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {
  final String? fcmToken;

  const LoadHomeDataEvent({this.fcmToken});

  @override
  List<Object?> get props => [fcmToken];
}

class RefreshHomeDataEvent extends HomeEvent {
  final String? fcmToken;

  const RefreshHomeDataEvent({this.fcmToken});

  @override
  List<Object?> get props => [fcmToken];
}
