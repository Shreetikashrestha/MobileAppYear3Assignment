import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/messages/domain/entities/message_entity.dart';
import 'package:influcollb_app/features/messages/presentation/view_model/message_view_model.dart';
import 'package:influcollb_app/features/messages/presentation/view_model/message_providers.dart';
import 'package:influcollb_app/features/messages/presentation/widgets/message_bubble.dart';
import 'package:influcollb_app/features/messages/presentation/widgets/message_input.dart';
import 'package:influcollb_app/features/messages/presentation/pages/call_screen.dart';
import 'package:influcollb_app/core/providers/core_providers.dart';
import 'package:influcollb_app/features/influencer/presentation/pages/influencer_profile_screen.dart';
import 'package:influcollb_app/core/services/permission/video_call_permission_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? conversationId;
  final Conversation? conversation;
  final String? receiverId;
  final String? receiverName;
  final String? receiverAvatar;

  const ChatScreen({
    super.key,
    this.conversationId,
    this.conversation,
    this.receiverId,
    this.receiverName,
    this.receiverAvatar,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load messages when screen opens (only if conversationId exists)
    if (widget.conversationId != null) {
      Future.microtask(() {
        ref.read(messageViewModelProvider.notifier).loadMessages(widget.conversationId!);
        ref.read(messageViewModelProvider.notifier).markConversationAsRead(widget.conversationId!);
        // Join conversation for real-time updates
        ref.read(messageViewModelProvider.notifier).joinConversation(widget.conversationId!);
      });
    } else {
      // Clear messages for new conversation
      Future.microtask(() {
        ref.read(messageViewModelProvider.notifier).clearMessages();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Leave conversation when screen closes
    ref.read(messageViewModelProvider.notifier).leaveConversation();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messageViewModelProvider);
    
    // Determine participant info (from conversation or from new chat params)
    final String participantId;
    final String participantName;
    final String? participantAvatar;
    
    if (widget.conversation != null) {
      final otherParticipant = widget.conversation!.otherParticipant;
      participantId = otherParticipant.id;
      participantName = otherParticipant.fullName;
      participantAvatar = otherParticipant.profilePicture;
    } else {
      participantId = widget.receiverId!;
      participantName = widget.receiverName!;
      participantAvatar = widget.receiverAvatar;
    }

    // Scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.messages.isNotEmpty) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () {
            // Navigate to user profile when tapping on avatar/name
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InfluencerProfileScreen(
                  influencerId: participantId,
                ),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[100],
                backgroundImage: participantAvatar != null
                    ? NetworkImage(participantAvatar)
                    : null,
                child: participantAvatar == null
                    ? Text(
                        participantName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participantName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (widget.conversation != null) ...[
            IconButton(
              icon: const Icon(Icons.call, color: Colors.black),
              onPressed: () {
                final otherParticipant = widget.conversation!.otherParticipant;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallScreen(
                      conversationId: widget.conversationId!,
                      receiverId: otherParticipant.id,
                      receiverName: otherParticipant.fullName,
                      receiverAvatar: otherParticipant.profilePicture,
                      isVideoCall: false,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.videocam, color: Colors.black),
              onPressed: () async {
                // Show permission explanation first
                final shouldContinue = await VideoCallPermissionService.showPermissionExplanation(context);
                
                if (shouldContinue == true && mounted) {
                  // Request permissions
                  final hasPermissions = await VideoCallPermissionService.requestVideoCallPermissions(context);
                  
                  if (hasPermissions && mounted) {
                    final otherParticipant = widget.conversation!.otherParticipant;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CallScreen(
                          conversationId: widget.conversationId!,
                          receiverId: otherParticipant.id,
                          receiverName: otherParticipant.fullName,
                          receiverAvatar: otherParticipant.profilePicture,
                          isVideoCall: true,
                        ),
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Camera and microphone permissions are required for video calls'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _buildMessagesList(state),
          ),
          // Message input
          MessageInput(
            onSendMessage: (content, attachments) async {
              final success = await ref
                  .read(messageViewModelProvider.notifier)
                  .sendMessage(
                    conversationId: widget.conversationId,
                    receiverId: widget.receiverId,
                    content: content,
                    attachments: attachments,
                  );

              if (success) {
                _scrollToBottom();
                // If this was a new conversation, navigate back to reload conversations
                if (widget.conversationId == null) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(MessageState state) {
    if (state.isLoadingMessages && state.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null && state.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (widget.conversationId != null) {
                  ref.read(messageViewModelProvider.notifier).loadMessages(widget.conversationId!);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        // Determine if message is from current user
        final currentUserId = ref.read(userSessionServiceProvider).getCurrentUserId();
        final isMe = message.senderId == currentUserId;
        
        // Convert MessageModel to Message entity for the widget
        final messageEntity = Message(
          id: message.id,
          conversationId: message.conversationId,
          sender: Participant(
            id: message.senderId,
            fullName: message.senderName,
            profilePicture: message.senderAvatar,
          ),
          content: message.content,
          attachments: message.attachmentUrl != null
              ? [
                  MessageAttachment(
                    url: message.attachmentUrl!,
                    type: 'file',
                  )
                ]
              : [],
          isRead: message.isRead,
          createdAt: message.createdAt,
          isFromCurrentUser: isMe,
        );
        
        // Show date separator if needed
        bool showDateSeparator = false;
        if (index == 0) {
          showDateSeparator = true;
        } else {
          final prevMessage = state.messages[index - 1];
          final prevDate = DateTime(
            prevMessage.createdAt.year,
            prevMessage.createdAt.month,
            prevMessage.createdAt.day,
          );
          final currentDate = DateTime(
            message.createdAt.year,
            message.createdAt.month,
            message.createdAt.day,
          );
          showDateSeparator = !prevDate.isAtSameMomentAs(currentDate);
        }

        return Column(
          children: [
            if (showDateSeparator) _buildDateSeparator(message.createdAt),
            MessageBubble(
              message: messageEntity,
              isMe: isMe,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);
    
    String dateText;
    if (messageDate.isAtSameMomentAs(today)) {
      dateText = 'Today';
    } else if (messageDate.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      dateText = 'Yesterday';
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
