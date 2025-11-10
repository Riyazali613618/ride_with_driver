import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatStarted extends ChatState {
  final Map<String, dynamic> chatData;
  final String chatId;

  const ChatStarted({required this.chatData, required this.chatId});

  @override
  List<Object?> get props => [chatData, chatId];
}

class ChatHistoryLoaded extends ChatState {
  final List<Map<String, dynamic>> chatHistory;

  const ChatHistoryLoaded({required this.chatHistory});

  @override
  List<Object?> get props => [chatHistory];
}

class ChatConversationLoaded extends ChatState {
  final List<Map<String, dynamic>> messages;
  final String chatId;

  const ChatConversationLoaded({required this.messages, required this.chatId});

  @override
  List<Object?> get props => [messages, chatId];
}

class MessageSent extends ChatState {
  final String message;
  final String chatId;

  const MessageSent({required this.message, required this.chatId});

  @override
  List<Object?> get props => [message, chatId];
}

class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  List<Object?> get props => [message];
}
