import 'package:dio/dio.dart';
import 'package:influcollb_app/features/messages/data/models/message_model.dart';
import 'package:influcollb_app/features/messages/data/models/user_search_model.dart';

abstract class IMessageRemoteDataSource {
  Future<List<ConversationModel>> getConversations(String currentUserId);
  Future<List<MessageModel>> getConversationMessages(String conversationId);
  Future<MessageModel> sendMessage({
    String? conversationId,
    String? receiverId,
    required String content,
    String? attachmentPath,
  });
  Future<bool> markConversationAsRead(String conversationId);
  Future<List<UserSearchModel>> searchUsersForMessaging(String query);
}

class MessageRemoteDataSource implements IMessageRemoteDataSource {
  final Dio apiClient;

  MessageRemoteDataSource({required this.apiClient});

  @override
  Future<List<ConversationModel>> getConversations(String currentUserId) async {
    try {
      final response = await apiClient.get('/api/messages/conversations');
      
      if (response.statusCode == 200) {
        final data = response.data;
        // Backend returns 'conversations' field, not 'data'
        final conversations = data['conversations'] ?? data['data'] ?? [];
        return (conversations as List)
            .map((json) => ConversationModel.fromJson(json, currentUserId))
            .toList();
      }
      throw Exception('Failed to fetch conversations');
    } catch (e) {
      throw Exception('Failed to fetch conversations: $e');
    }
  }

  @override
  Future<List<MessageModel>> getConversationMessages(String conversationId) async {
    try {
      final response = await apiClient.get('/api/messages/conversation/$conversationId');
      
      if (response.statusCode == 200) {
        final data = response.data;
        // Backend returns 'messages' field, not 'data'
        final messages = data['messages'] ?? data['data'] ?? [];
        return (messages as List)
            .map((json) => MessageModel.fromJson(json))
            .toList();
      }
      throw Exception('Failed to fetch messages');
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  @override
  Future<MessageModel> sendMessage({
    String? conversationId,
    String? receiverId,
    required String content,
    String? attachmentPath,
  }) async {
    try {
      FormData formData;
      
      if (attachmentPath != null) {
        formData = FormData.fromMap({
          if (conversationId != null) 'conversationId': conversationId,
          if (receiverId != null) 'receiverId': receiverId,
          'content': content,
          'attachment': await MultipartFile.fromFile(attachmentPath),
        });
      } else {
        formData = FormData.fromMap({
          if (conversationId != null) 'conversationId': conversationId,
          if (receiverId != null) 'receiverId': receiverId,
          'content': content,
        });
      }

      final response = await apiClient.post(
        '/api/messages/send',
        data: formData,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Backend returns 'message' field, not 'data'
        final data = response.data['message'] ?? response.data['data'];
        return MessageModel.fromJson(data);
      }
      throw Exception('Failed to send message');
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<bool> markConversationAsRead(String conversationId) async {
    try {
      final response = await apiClient.patch(
        '/api/messages/conversation/$conversationId/read',
      );
      
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      // Silently fail - not critical
      return false;
    }
  }

  @override
  Future<List<UserSearchModel>> searchUsersForMessaging(String query) async {
    try {
      final response = await apiClient.get(
        '/api/users/search-messaging',
        queryParameters: {'q': query},
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final users = data['data'] ?? [];
        return (users as List)
            .map((json) => UserSearchModel.fromJson(json))
            .toList();
      }
      throw Exception('Failed to search users');
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}
