import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/messages/domain/entities/message_entity.dart';
import 'package:influcollb_app/features/messages/domain/repositories/message_repository.dart';

class GetConversationMessagesUseCase {
  final IMessageRepository repository;

  GetConversationMessagesUseCase({required this.repository});

  Future<Either<Failure, List<MessageEntity>>> call(String conversationId) async {
    return await repository.getConversationMessages(conversationId);
  }
}
