import 'package:dartz/dartz.dart';
import 'package:influcollb_app/core/error/failures.dart';
import 'package:influcollb_app/features/messages/domain/entities/message_entity.dart';
import 'package:influcollb_app/features/messages/domain/repositories/message_repository.dart';

class SendMessageUseCase {
  final IMessageRepository repository;

  SendMessageUseCase({required this.repository});

  Future<Either<Failure, MessageEntity>> call({
    String? conversationId,
    String? receiverId,
    required String content,
    String? attachmentPath,
  }) async {
    return await repository.sendMessage(
      conversationId: conversationId,
      receiverId: receiverId,
      content: content,
      attachmentPath: attachmentPath,
    );
  }
}
