import '../model/communications.dart';

abstract class CommunicationState {}

class CommunicationInitial extends CommunicationState {}

class CommunicationLoading extends CommunicationState {}

class CommunicationLoaded extends CommunicationState {
  final List<Communication> communications;
  CommunicationLoaded(this.communications);
}

class CommunicationError extends CommunicationState {
  final String message;
  CommunicationError(this.message);
}
