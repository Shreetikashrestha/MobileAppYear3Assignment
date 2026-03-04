import 'package:influcollb_app/features/messages/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.senderName,
    super.senderAvatar,
    required super.receiverId,
    required super.content,
    super.attachmentUrl,
    required super.isRead,
    required super.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: _extractId(json['sender']),
      senderName: _extractName(json['sender']),
      senderAvatar: _extractAvatar(json['sender']),
      receiverId: _extractId(json['receiver']),
      content: json['content'] ?? '',
      attachmentUrl: json['attachmentUrl'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'conversationId': conversationId,
      'sender': senderId,
      'receiver': receiverId,
      'content': content,
      'attachmentUrl': attachmentUrl,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static String _extractId(dynamic data) {
    if (data is String) return data;
    if (data is Map) return data['_id'] ?? data['id'] ?? '';
    return '';
  }

  static String _extractName(dynamic data) {
    if (data is Map) return data['fullName'] ?? data['name'] ?? 'Unknown';
    return 'Unknown';
  }

  static String? _extractAvatar(dynamic data) {
    if (data is Map) return data['avatar'] ?? data['profilePicture'];
    return null;
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? receiverId,
    String? content,
    String? attachmentUrl,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.participantId,
    required super.participantName,
    super.participantAvatar,
    super.lastMessage,
    super.lastMessageTime,
    required super.unreadCount,
  });

  // Factory method that requires currentUserId to properly extract the other participant
  factory ConversationModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    // Extract the other participant from participants array
    // Backend returns: { participants: [{ user: {...} }, { user: {...} }] }
    final participants = json['participants'] as List?;
    Map<String, dynamic>? otherParticipant;
    
    if (participants != null && participants.isNotEmpty) {
      // Find the participant that is NOT the current user
      for (var p in participants) {
        if (p is Map<String, dynamic>) {
          final user = p['user'];
          if (user is Map<String, dynamic>) {
            final userId = user['_id'] ?? user['id'] ?? '';
            // Skip if this is the current user
            if (userId != currentUserId) {
              otherParticipant = user;
              break;
            }
          }
        }
      }
      
      // Fallback: if we didn't find other participant, take the first one
      if (otherParticipant == null && participants.isNotEmpty) {
        final firstParticipant = participants[0];
        if (firstParticipant is Map<String, dynamic>) {
          otherParticipant = firstParticipant['user'] as Map<String, dynamic>?;
        }
      }
    }
    
    // Extract unread count - backend returns Map<userId, count>
    // We want the count for the CURRENT user
    int unreadCount = 0;
    final unreadCountMap = json['unreadCount'];
    if (unreadCountMap is Map) {
      // Get unread count for current user
      final userUnread = unreadCountMap[currentUserId];
      if (userUnread != null) {
        unreadCount = userUnread is int ? userUnread : int.tryParse(userUnread.toString()) ?? 0;
      }
    }
    
    return ConversationModel(
      id: json['_id'] ?? json['id'] ?? '',
      participantId: otherParticipant?['_id'] ?? otherParticipant?['id'] ?? '',
      participantName: otherParticipant?['fullName'] ?? otherParticipant?['name'] ?? 'Unknown',
      participantAvatar: otherParticipant?['profilePicture'] ?? otherParticipant?['avatar'],
      lastMessage: json['lastMessage']?['content'] ?? json['lastMessage'],
      lastMessageTime: json['lastMessage']?['createdAt'] != null
          ? DateTime.parse(json['lastMessage']['createdAt'])
          : (json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null),
      unreadCount: unreadCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'participant': participantId,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }
}
