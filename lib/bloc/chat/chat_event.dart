import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class StartChatEvent extends ChatEvent {
  final Map<String, dynamic> chatData;

  const StartChatEvent({required this.chatData});

  @override
  List<Object?> get props => [chatData];
}

class LoadChatHistoryEvent extends ChatEvent {
  final Map<String, dynamic> historyParams;

  const LoadChatHistoryEvent({required this.historyParams});

  @override
  List<Object?> get props => [historyParams];
}

class SendMessageEvent extends ChatEvent {
  final String chatId;
  final String message;

  const SendMessageEvent({required this.chatId, required this.message});

  @override
  List<Object?> get props => [chatId, message];
}

class LoadChatConversationEvent extends ChatEvent {
  final String chatId;

  const LoadChatConversationEvent({required this.chatId});

  @override
  List<Object?> get props => [chatId];
}
