import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/core/providers/api_provider.dart';
import 'package:influcollb_app/core/providers/core_providers.dart';
import 'package:influcollb_app/features/messages/data/datasources/message_remote_datasource.dart';
import 'package:influcollb_app/features/messages/data/repositories/message_repository_impl.dart';
import 'package:influcollb_app/features/messages/domain/repositories/message_repository.dart';
import 'package:influcollb_app/features/messages/domain/usecases/get_conversations_usecase.dart';
import 'package:influcollb_app/features/messages/domain/usecases/get_conversation_messages_usecase.dart';
import 'package:influcollb_app/features/messages/domain/usecases/send_message_usecase.dart';
import 'package:influcollb_app/features/messages/presentation/view_model/message_view_model.dart';

// Data Source Provider
final messageRemoteDataSourceProvider = Provider<IMessageRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return MessageRemoteDataSource(apiClient: dio);
});

// Repository Provider
final messageRepositoryProvider = Provider<IMessageRepository>((ref) {
  final remoteDataSource = ref.read(messageRemoteDataSourceProvider);
  return MessageRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Use Case Providers
final getConversationsUseCaseProvider = Provider<GetConversationsUseCase>((ref) {
  final repository = ref.read(messageRepositoryProvider);
  return GetConversationsUseCase(repository: repository);
});

final getConversationMessagesUseCaseProvider = Provider<GetConversationMessagesUseCase>((ref) {
  final repository = ref.read(messageRepositoryProvider);
  return GetConversationMessagesUseCase(repository: repository);
});

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  final repository = ref.read(messageRepositoryProvider);
  return SendMessageUseCase(repository: repository);
});

// ViewModel Provider
final messageViewModelProvider = StateNotifierProvider<MessageViewModel, MessageState>((ref) {
  final getConversationsUseCase = ref.read(getConversationsUseCaseProvider);
  final getConversationMessagesUseCase = ref.read(getConversationMessagesUseCaseProvider);
  final sendMessageUseCase = ref.read(sendMessageUseCaseProvider);
  final sessionService = ref.read(userSessionServiceProvider);
  final repository = ref.read(messageRepositoryProvider);

  return MessageViewModel(
    getConversationsUseCase: getConversationsUseCase,
    getConversationMessagesUseCase: getConversationMessagesUseCase,
    sendMessageUseCase: sendMessageUseCase,
    sessionService: sessionService,
    repository: repository,
  );
});
