import 'dart:async';
import 'package:flutter/foundation.dart';

/// Real-time messaging service using polling
/// For production, replace with socket.io or WebSocket implementation
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  bool _isConnected = false;
  Timer? _pollingTimer;
  // ignore: unused_field
  String? _currentConversationId;
  Function? _fetchMessagesCallback;

  bool get isConnected => _isConnected;

  /// Connect to real-time messaging
  void connect() {
    if (_isConnected) return;

    _isConnected = true;
    _connectionController.add(true);
    debugPrint('SocketService: Connected');
  }

  /// Disconnect from real-time messaging
  void disconnect() {
    _isConnected = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _currentConversationId = null;
    _fetchMessagesCallback = null;
    _connectionController.add(false);
    debugPrint('SocketService: Disconnected');
  }

  /// Join a conversation room for real-time updates
  void joinConversation(String conversationId, Function fetchMessages) {
    _currentConversationId = conversationId;
    _fetchMessagesCallback = fetchMessages;

    // Start polling for new messages every 3 seconds
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_fetchMessagesCallback != null) {
        _fetchMessagesCallback!();
      }
    });

    debugPrint('SocketService: Joined conversation $conversationId');
  }

  /// Leave current conversation
  void leaveConversation() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _currentConversationId = null;
    _fetchMessagesCallback = null;
    debugPrint('SocketService: Left conversation');
  }

  /// Emit a new message event
  void emitMessage(Map<String, dynamic> message) {
    if (_isConnected) {
      _messageController.add(message);
    }
  }

  /// Listen for typing events
  void emitTyping(String conversationId, bool isTyping) {
    debugPrint(
        'SocketService: User ${isTyping ? "started" : "stopped"} typing in $conversationId');
  }

  void dispose() {
    _pollingTimer?.cancel();
    _messageController.close();
    _connectionController.close();
  }
}
