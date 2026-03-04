import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:influcollb_app/features/messages/data/models/message_model.dart';
import 'package:influcollb_app/features/messages/domain/usecases/get_conversations_usecase.dart';
import 'package:influcollb_app/features/messages/domain/usecases/get_conversation_messages_usecase.dart';
import 'package:influcollb_app/features/messages/domain/usecases/send_message_usecase.dart';
import 'package:influcollb_app/core/services/socket/socket_service.dart';
import 'package:influcollb_app/core/services/storage/user_session_service.dart';
import 'package:influcollb_app/features/messages/domain/repositories/message_repository.dart';

class MessageState {
  final List<ConversationModel> conversations;
  final List<MessageModel> messages;
  final bool isLoadingConversations;
  final bool isLoadingMessages;
  final bool isSending;
  final String? error;
  final bool sendSuccess;
  final bool isConnected;
  final bool isLoading; // General loading state
  final List<UserSearchResult> searchResults;
  final bool isSearchingUsers;

  MessageState({
    this.conversations = const [],
    this.messages = const [],
    this.isLoadingConversations = false,
    this.isLoadingMessages = false,
    this.isSending = false,
    this.error,
    this.sendSuccess = false,
    this.isConnected = false,
    this.isLoading = false,
    this.searchResults = const [],
    this.isSearchingUsers = false,
  });

  MessageState copyWith({
    List<ConversationModel>? conversations,
    List<MessageModel>? messages,
    bool? isLoadingConversations,
    bool? isLoadingMessages,
    bool? isSending,
    String? error,
    bool? sendSuccess,
    bool? isConnected,
    bool? isLoading,
    List<UserSearchResult>? searchResults,
    bool? isSearchingUsers,
  }) {
    return MessageState(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      isLoadingConversations: isLoadingConversations ?? this.isLoadingConversations,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isSending: isSending ?? this.isSending,
      error: error,
      sendSuccess: sendSuccess ?? this.sendSuccess,
      isConnected: isConnected ?? this.isConnected,
      isLoading: isLoading ?? this.isLoading,
      searchResults: searchResults ?? this.searchResults,
      isSearchingUsers: isSearchingUsers ?? this.isSearchingUsers,
    );
  }
}

class MessageViewModel extends StateNotifier<MessageState> {
  final GetConversationsUseCase getConversationsUseCase;
  final GetConversationMessagesUseCase getConversationMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final UserSessionService sessionService;
  final IMessageRepository repository;
  final SocketService _socketService = SocketService();

  MessageViewModel({
    required this.getConversationsUseCase,
    required this.getConversationMessagesUseCase,
    required this.sendMessageUseCase,
    required this.sessionService,
    required this.repository,
  }) : super(MessageState()) {
    _initializeSocket();
  }

  void _initializeSocket() {
    _socketService.connect();
    
    // Listen for connection status
    _socketService.connectionStream.listen((isConnected) {
      state = state.copyWith(isConnected: isConnected);
    });
    
    // Listen for new messages
    _socketService.messageStream.listen((messageData) {
      // Handle incoming real-time messages
      _handleIncomingMessage(messageData);
    });
  }

  void _handleIncomingMessage(Map<String, dynamic> messageData) {
    try {
      final newMessage = MessageModel.fromJson(messageData);
      final updatedMessages = [...state.messages, newMessage];
      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      // Ignore invalid messages
    }
  }

  Future<void> loadConversations() async {
    state = state.copyWith(isLoadingConversations: true, error: null);
    
    // Get current user ID from session
    final currentUserId = sessionService.getCurrentUserId() ?? '';
    
    print('📱 Messages: Loading conversations for user ID: $currentUserId');
    
    if (currentUserId.isEmpty) {
      print('❌ Messages: User ID is empty - user not logged in properly');
      state = state.copyWith(
        isLoadingConversations: false,
        error: 'User not logged in',
      );
      return;
    }
    
    final result = await getConversationsUseCase(currentUserId);
    
    result.fold(
      (failure) {
        print('❌ Messages: Failed to load conversations: ${failure.message}');
        state = state.copyWith(
          isLoadingConversations: false,
          error: failure.message,
        );
      },
      (conversations) {
        print('✅ Messages: Loaded ${conversations.length} conversations');
        state = state.copyWith(
          isLoadingConversations: false,
          conversations: conversations as List<ConversationModel>,
          error: null,
        );
      },
    );
  }

  Future<void> loadMessages(String conversationId) async {
    state = state.copyWith(isLoadingMessages: true, error: null);
    
    final result = await getConversationMessagesUseCase(conversationId);
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingMessages: false,
          error: failure.message,
        );
      },
      (messages) {
        state = state.copyWith(
          isLoadingMessages: false,
          messages: messages as List<MessageModel>,
          error: null,
        );
      },
    );
  }

  Future<bool> sendMessage({
    String? conversationId,
    String? receiverId,
    required String content,
    List<XFile>? attachments,
  }) async {
    state = state.copyWith(isSending: true, error: null, sendSuccess: false);
    
    // For now, we'll send without attachments support
    // TODO: Implement file upload for attachments
    final result = await sendMessageUseCase(
      conversationId: conversationId,
      receiverId: receiverId,
      content: content,
      attachmentPath: null,
    );
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isSending: false,
          error: failure.message,
          sendSuccess: false,
        );
        return false;
      },
      (message) {
        // Add the new message to the list
        final updatedMessages = [...state.messages, message as MessageModel];
        state = state.copyWith(
          isSending: false,
          messages: updatedMessages,
          sendSuccess: true,
          error: null,
        );
        // Reload conversations to update last message
        loadConversations();
        return true;
      },
    );
  }

  Future<void> markConversationAsRead(String conversationId) async {
    // Update locally
    final updatedConversations = state.conversations.map((conv) {
      if (conv.id == conversationId) {
        return ConversationModel(
          id: conv.id,
          participantId: conv.participantId,
          participantName: conv.participantName,
          participantAvatar: conv.participantAvatar,
          lastMessage: conv.lastMessage,
          lastMessageTime: conv.lastMessageTime,
          unreadCount: 0,
        );
      }
      return conv;
    }).toList();
    
    state = state.copyWith(conversations: updatedConversations);
  }

  /// Join a conversation for real-time updates
  void joinConversation(String conversationId) {
    _socketService.joinConversation(conversationId, () {
      loadMessages(conversationId);
    });
  }

  /// Leave current conversation
  void leaveConversation() {
    _socketService.leaveConversation();
  }

  void clearMessages() {
    state = state.copyWith(messages: []);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void resetSendSuccess() {
    state = state.copyWith(sendSuccess: false);
  }

  Future<void> searchUsers(String query) async {
    if (query.length < 2) {
      state = state.copyWith(searchResults: [], isSearchingUsers: false);
      return;
    }

    state = state.copyWith(isSearchingUsers: true, error: null);
    
    final result = await repository.searchUsersForMessaging(query);
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isSearchingUsers: false,
          error: failure.message,
          searchResults: [],
        );
      },
      (users) {
        state = state.copyWith(
          isSearchingUsers: false,
          searchResults: users,
          error: null,
        );
      },
    );
  }

  void clearSearchResults() {
    state = state.copyWith(searchResults: []);
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}
