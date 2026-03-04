import 'package:equatable/equatable.dart';

// User participant in a conversation
class Participant extends Equatable {
  final String id;
  final String fullName;
  final String? profilePicture;
  final bool? isOnline;

  const Participant({
    required this.id,
    required this.fullName,
    this.profilePicture,
    this.isOnline,
  });

  @override
  List<Object?> get props => [id, fullName, profilePicture, isOnline];
}

// Message attachment
class MessageAttachment extends Equatable {
  final String url;
  final String type; // 'image', 'file', etc.
  final String? filename;

  const MessageAttachment({
    required this.url,
    required this.type,
    this.filename,
  });

  @override
  List<Object?> get props => [url, type, filename];
}

// Message entity
class Message extends Equatable {
  final String id;
  final String conversationId;
  final Participant sender;
  final String content;
  final List<MessageAttachment> attachments;
  final bool isRead;
  final DateTime createdAt;
  final bool isFromCurrentUser;

  const Message({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.content,
    this.attachments = const [],
    required this.isRead,
    required this.createdAt,
    required this.isFromCurrentUser,
  });

  @override
  List<Object?> get props => [
        id,
        conversationId,
        sender,
        content,
        attachments,
        isRead,
        createdAt,
        isFromCurrentUser,
      ];
}

// Conversation entity
class Conversation extends Equatable {
  final String id;
  final List<Participant> participants;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  // Get the other participant (not the current user)
  Participant get otherParticipant {
    // Assuming the first participant is always the other user
    // This logic might need adjustment based on your backend
    return participants.first;
  }

  @override
  List<Object?> get props => [
        id,
        participants,
        lastMessage,
        unreadCount,
        createdAt,
        updatedAt,
      ];
}

// Legacy entities for backward compatibility
class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String receiverId;
  final String content;
  final String? attachmentUrl;
  final bool isRead;
  final DateTime createdAt;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.receiverId,
    required this.content,
    this.attachmentUrl,
    required this.isRead,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        senderName,
        senderAvatar,
        receiverId,
        content,
        attachmentUrl,
        isRead,
        createdAt,
      ];
}

class ConversationEntity extends Equatable {
  final String id;
  final String participantId;
  final String participantName;
  final String? participantAvatar;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  const ConversationEntity({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantAvatar,
    this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [
        id,
        participantId,
        participantName,
        participantAvatar,
        lastMessage,
        lastMessageTime,
        unreadCount,
      ];
}
