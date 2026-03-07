import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Real-time messaging service using Socket.io
class SocketIOService {
  static final SocketIOService _instance = SocketIOService._internal();
  factory SocketIOService() => _instance;
  SocketIOService._internal();

  IO.Socket? _socket;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _onlineStatusController = StreamController<Map<String, dynamic>>.broadcast();
  final _readReceiptController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get onlineStatusStream => _onlineStatusController.stream;
  Stream<Map<String, dynamic>> get readReceiptStream => _readReceiptController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isConnected => _socket?.connected ?? false;
  String? _currentConversationId;

  /// Connect to Socket.io server
  void connect(String backendUrl, String token) {
    if (_socket?.connected == true) {
      debugPrint('SocketIOService: Already connected');
      return;
    }

    try {
      _socket = IO.io(
        backendUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .setAuth({'token': token})
            .build(),
      );

      _setupListeners();
      _socket?.connect();
      
      debugPrint('SocketIOService: Connecting to $backendUrl');
    } catch (e) {
      debugPrint('SocketIOService: Connection error: $e');
    }
  }

  /// Setup event listeners
  void _setupListeners() {
    _socket?.onConnect((_) {
      debugPrint('SocketIOService: Connected');
      _connectionController.add(true);
    });

    _socket?.onDisconnect((_) {
      debugPrint('SocketIOService: Disconnected');
      _connectionController.add(false);
    });

    _socket?.onConnectError((error) {
      debugPrint('SocketIOService: Connection error: $error');
      _connectionController.add(false);
    });

    _socket?.onError((error) {
      debugPrint('SocketIOService: Error: $error');
    });

    // Listen for new messages
    _socket?.on('new_message', (data) {
      debugPrint('SocketIOService: New message received');
      _messageController.add(Map<String, dynamic>.from(data));
    });

    // Listen for messages read
    _socket?.on('messages_read', (data) {
      debugPrint('SocketIOService: Messages read');
      _readReceiptController.add(Map<String, dynamic>.from(data));
    });

    // Listen for typing events
    _socket?.on('user_typing', (data) {
      debugPrint('SocketIOService: User typing');
      _typingController.add(Map<String, dynamic>.from(data));
    });

    // Listen for online status
    _socket?.on('user_online', (data) {
      debugPrint('SocketIOService: User online status changed');
      _onlineStatusController.add(Map<String, dynamic>.from(data));
    });

    // Listen for user offline
    _socket?.on('user_offline', (data) {
      debugPrint('SocketIOService: User went offline');
      _onlineStatusController.add(Map<String, dynamic>.from(data));
    });
  }

  /// Join a conversation room
  void joinConversation(String conversationId) {
    if (_socket?.connected != true) {
      debugPrint('SocketIOService: Cannot join conversation - not connected');
      return;
    }

    _currentConversationId = conversationId;
    _socket?.emit('join_conversation', conversationId);
    debugPrint('SocketIOService: Joined conversation $conversationId');
  }

  /// Leave current conversation
  void leaveConversation() {
    if (_currentConversationId != null && _socket?.connected == true) {
      _socket?.emit('leave_conversation', _currentConversationId);
      debugPrint('SocketIOService: Left conversation $_currentConversationId');
      _currentConversationId = null;
    }
  }

  /// Emit typing event
  void emitTyping(String conversationId, bool isTyping) {
    if (_socket?.connected != true) return;

    _socket?.emit('typing', {
      'conversationId': conversationId,
      'isTyping': isTyping,
    });
    debugPrint('SocketIOService: Emitted typing: $isTyping');
  }

  /// Mark messages as read
  void markAsRead(String conversationId) {
    if (_socket?.connected != true) return;

    _socket?.emit('mark_read', {
      'conversationId': conversationId,
    });
    debugPrint('SocketIOService: Marked conversation as read');
  }

  /// Send online status
  void sendOnlineStatus(bool isOnline) {
    if (_socket?.connected != true) return;

    _socket?.emit('user_status', {
      'isOnline': isOnline,
    });
    debugPrint('SocketIOService: Sent online status: $isOnline');
  }

  /// Disconnect from Socket.io server
  void disconnect() {
    leaveConversation();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentConversationId = null;
    debugPrint('SocketIOService: Disconnected and disposed');
  }

  /// Dispose all resources
  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _onlineStatusController.close();
    _readReceiptController.close();
    _connectionController.close();
  }
}
