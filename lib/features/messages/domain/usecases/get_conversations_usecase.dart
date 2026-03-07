import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/messages/domain/entities/message_entity.dart';
import 'package:influcollb_app/features/messages/domain/repositories/message_repository.dart';

class GetConversationsUseCase {
  final IMessageRepository repository;

  GetConversationsUseCase({required this.repository});

  Future<Either<Failure, List<ConversationEntity>>> call(String currentUserId) async {
    return await repository.getConversations(currentUserId);
  }
}
