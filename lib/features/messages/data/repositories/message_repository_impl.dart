import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/messages/data/datasources/message_remote_datasource.dart';
import 'package:influcollb_app/features/messages/domain/entities/message_entity.dart';
import 'package:influcollb_app/features/messages/domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements IMessageRepository {
  final IMessageRemoteDataSource remoteDataSource;

  MessageRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ConversationEntity>>> getConversations(String currentUserId) async {
    try {
      final conversations = await remoteDataSource.getConversations(currentUserId);
      return Right(conversations);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getConversationMessages(String conversationId) async {
    try {
      final messages = await remoteDataSource.getConversationMessages(conversationId);
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    String? conversationId,
    String? receiverId,
    required String content,
    String? attachmentPath,
  }) async {
    try {
      final message = await remoteDataSource.sendMessage(
        conversationId: conversationId,
        receiverId: receiverId,
        content: content,
        attachmentPath: attachmentPath,
      );
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markConversationAsRead(String conversationId) async {
    try {
      final result = await remoteDataSource.markConversationAsRead(conversationId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserSearchResult>>> searchUsersForMessaging(String query) async {
    try {
      final users = await remoteDataSource.searchUsersForMessaging(query);
      // Convert models to domain entities
      final results = users.map((user) => UserSearchResult(
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        profilePicture: user.profilePicture,
        isInfluencer: user.isInfluencer,
        role: user.role,
      )).toList();
      return Right(results);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
