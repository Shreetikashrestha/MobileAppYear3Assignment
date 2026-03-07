import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/messages/domain/entities/message_entity.dart';

abstract class IMessageRepository {
  Future<Either<Failure, List<ConversationEntity>>> getConversations(String currentUserId);
  Future<Either<Failure, List<MessageEntity>>> getConversationMessages(String conversationId);
  Future<Either<Failure, MessageEntity>> sendMessage({
    String? conversationId,
    String? receiverId,
    required String content,
    String? attachmentPath,
  });
  Future<Either<Failure, bool>> markConversationAsRead(String conversationId);
  Future<Either<Failure, List<UserSearchResult>>> searchUsersForMessaging(String query);
}

// Simple user search result class
class UserSearchResult {
  final String id;
  final String fullName;
  final String email;
  final String? profilePicture;
  final bool isInfluencer;
  final String role;

  const UserSearchResult({
    required this.id,
    required this.fullName,
    required this.email,
    this.profilePicture,
    required this.isInfluencer,
    required this.role,
  });
}
