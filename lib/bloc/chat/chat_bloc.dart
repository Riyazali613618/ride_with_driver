import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/api/api_service/api_repository.dart';

import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ApiRepository apiRepository;

  ChatBloc({required this.apiRepository}) : super(const ChatInitial()) {
    on<StartChatEvent>(_onStartChat);
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
    on<SendMessageEvent>(_onSendMessage);
    on<LoadChatConversationEvent>(_onLoadChatConversation);
  }

  Future<void> _onStartChat(StartChatEvent event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());

    try {
      final response = await apiRepository.startChat(event.chatData);
      
      if (response['status'] == true) {
        final chatId = response['data']?['chatId']?.toString() ?? '';
        emit(ChatStarted(
          chatData: response,
          chatId: chatId,
        ));
      } else {
        emit(ChatError(
          message: response['message'] ?? 'Failed to start chat',
        ));
      }
    } on ApiException catch (e) {
      debugPrint('ChatBloc StartChat ApiException: ${e.message}');
      emit(ChatError(message: e.message));
    } catch (e) {
      debugPrint('ChatBloc StartChat Exception: $e');
      emit(const ChatError(message: 'Failed to start chat. Please try again.'));
    }
  }

  Future<void> _onLoadChatHistory(LoadChatHistoryEvent event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());

    try {
      final response = await apiRepository.fetchChatHistory(event.historyParams);
      
      if (response['status'] == true) {
        final chatHistory = (response['data'] as List?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ?? [];
        
        emit(ChatHistoryLoaded(chatHistory: chatHistory));
      } else {
        emit(ChatError(
          message: response['message'] ?? 'Failed to load chat history',
        ));
      }
    } on ApiException catch (e) {
      debugPrint('ChatBloc LoadChatHistory ApiException: ${e.message}');
      emit(ChatError(message: e.message));
    } catch (e) {
      debugPrint('ChatBloc LoadChatHistory Exception: $e');
      emit(const ChatError(message: 'Failed to load chat history. Please try again.'));
    }
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      // For now, just emit success without API call
      // This would need proper implementation based on your chat service
      emit(MessageSent(message: event.message, chatId: event.chatId));
    } catch (e) {
      debugPrint('ChatBloc SendMessage Exception: $e');
      emit(const ChatError(message: 'Failed to send message. Please try again.'));
    }
  }

  Future<void> _onLoadChatConversation(LoadChatConversationEvent event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());

    try {
      // This would need proper implementation based on your chat conversation service
      // For now, using placeholder
      emit(ChatConversationLoaded(messages: [], chatId: event.chatId));
    } catch (e) {
      debugPrint('ChatBloc LoadChatConversation Exception: $e');
      emit(const ChatError(message: 'Failed to load conversation. Please try again.'));
    }
  }
}
