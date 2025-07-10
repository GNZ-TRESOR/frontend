import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Real-time messaging service using WebSockets
/// Handles live chat, notifications, and real-time updates
class RealtimeMessagingService extends ChangeNotifier {
  static final RealtimeMessagingService _instance =
      RealtimeMessagingService._internal();
  factory RealtimeMessagingService() => _instance;
  RealtimeMessagingService._internal();

  // WebSocket configuration
  static const String wsUrl = 'ws://10.0.2.2:8080/ws';

  // Connection state
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _lastError;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;

  // Message handling
  final StreamController<RealtimeMessage> _messageController =
      StreamController<RealtimeMessage>.broadcast();
  final List<RealtimeMessage> _messageQueue = [];
  String? _userId;

  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get lastError => _lastError;
  Stream<RealtimeMessage> get messageStream => _messageController.stream;

  /// Initialize real-time messaging service
  Future<void> initialize({required String userId}) async {
    try {
      _userId = userId;
      debugPrint(
        '🔌 Initializing real-time messaging service for user: $userId',
      );

      await _loadQueuedMessages();
      await connect();

      debugPrint('✅ Real-time messaging service initialized');
    } catch (e) {
      debugPrint('❌ Real-time messaging service initialization failed: $e');
      _lastError = e.toString();
      notifyListeners();
    }
  }

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_isConnected || _isConnecting) return;

    try {
      _isConnecting = true;
      _lastError = null;
      notifyListeners();

      debugPrint('🔌 Connecting to WebSocket: $wsUrl');

      // Get auth token
      final token = await _getAuthToken();
      final uri = Uri.parse('$wsUrl?token=$token&userId=$_userId');

      // Create WebSocket connection
      _channel = WebSocketChannel.connect(uri);

      // Listen for connection
      await _channel!.ready;

      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;

      // Set up message listener
      _setupMessageListener();

      // Start heartbeat
      _startHeartbeat();

      // Send queued messages
      await _sendQueuedMessages();

      debugPrint('✅ WebSocket connected successfully');
      notifyListeners();
    } catch (e) {
      _isConnected = false;
      _isConnecting = false;
      _lastError = e.toString();

      debugPrint('❌ WebSocket connection failed: $e');

      // Schedule reconnection
      _scheduleReconnect();

      notifyListeners();
    }
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    try {
      debugPrint('🔌 Disconnecting from WebSocket...');

      _heartbeatTimer?.cancel();
      _reconnectTimer?.cancel();

      if (_channel != null) {
        await _channel!.sink.close();
        _channel = null;
      }

      _isConnected = false;
      _isConnecting = false;

      debugPrint('✅ WebSocket disconnected');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ WebSocket disconnection error: $e');
    }
  }

  /// Send message
  Future<void> sendMessage({
    required String recipientId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final message = RealtimeMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: _userId!,
        recipientId: recipientId,
        content: content,
        type: type,
        timestamp: DateTime.now(),
        metadata: metadata,
      );

      if (_isConnected && _channel != null) {
        // Send immediately
        _channel!.sink.add(json.encode(message.toJson()));
        debugPrint('📤 Message sent: ${message.id}');
      } else {
        // Queue for later
        _messageQueue.add(message);
        await _saveQueuedMessages();
        debugPrint('📥 Message queued: ${message.id}');
      }
    } catch (e) {
      debugPrint('❌ Failed to send message: $e');
      _lastError = e.toString();
      notifyListeners();
    }
  }

  /// Send typing indicator
  Future<void> sendTypingIndicator({
    required String recipientId,
    required bool isTyping,
  }) async {
    try {
      if (!_isConnected || _channel == null) return;

      final typingMessage = {
        'type': 'typing_indicator',
        'senderId': _userId,
        'recipientId': recipientId,
        'isTyping': isTyping,
        'timestamp': DateTime.now().toIso8601String(),
      };

      _channel!.sink.add(json.encode(typingMessage));
      debugPrint('⌨️ Typing indicator sent: $isTyping');
    } catch (e) {
      debugPrint('❌ Failed to send typing indicator: $e');
    }
  }

  /// Send read receipt
  Future<void> sendReadReceipt({
    required String messageId,
    required String senderId,
  }) async {
    try {
      if (!_isConnected || _channel == null) return;

      final readReceipt = {
        'type': 'read_receipt',
        'messageId': messageId,
        'readerId': _userId,
        'senderId': senderId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      _channel!.sink.add(json.encode(readReceipt));
      debugPrint('✅ Read receipt sent for message: $messageId');
    } catch (e) {
      debugPrint('❌ Failed to send read receipt: $e');
    }
  }

  /// Join chat room
  Future<void> joinRoom(String roomId) async {
    try {
      if (!_isConnected || _channel == null) return;

      final joinMessage = {
        'type': 'join_room',
        'roomId': roomId,
        'userId': _userId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      _channel!.sink.add(json.encode(joinMessage));
      debugPrint('🏠 Joined room: $roomId');
    } catch (e) {
      debugPrint('❌ Failed to join room: $e');
    }
  }

  /// Leave chat room
  Future<void> leaveRoom(String roomId) async {
    try {
      if (!_isConnected || _channel == null) return;

      final leaveMessage = {
        'type': 'leave_room',
        'roomId': roomId,
        'userId': _userId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      _channel!.sink.add(json.encode(leaveMessage));
      debugPrint('🚪 Left room: $roomId');
    } catch (e) {
      debugPrint('❌ Failed to leave room: $e');
    }
  }

  /// Setup message listener
  void _setupMessageListener() {
    _channel!.stream.listen(
      (data) {
        try {
          final messageData = json.decode(data);
          _handleIncomingMessage(messageData);
        } catch (e) {
          debugPrint('❌ Failed to parse incoming message: $e');
        }
      },
      onError: (error) {
        debugPrint('❌ WebSocket stream error: $error');
        _handleConnectionError(error);
      },
      onDone: () {
        debugPrint('🔌 WebSocket stream closed');
        _handleConnectionClosed();
      },
    );
  }

  /// Handle incoming message
  void _handleIncomingMessage(Map<String, dynamic> data) {
    try {
      final messageType = data['type'] as String?;

      switch (messageType) {
        case 'message':
          final message = RealtimeMessage.fromJson(data);
          _messageController.add(message);
          debugPrint('📨 Message received: ${message.id}');
          break;

        case 'typing_indicator':
          _handleTypingIndicator(data);
          break;

        case 'read_receipt':
          _handleReadReceipt(data);
          break;

        case 'user_status':
          _handleUserStatus(data);
          break;

        case 'heartbeat_response':
          debugPrint('💓 Heartbeat response received');
          break;

        default:
          debugPrint('❓ Unknown message type: $messageType');
      }
    } catch (e) {
      debugPrint('❌ Failed to handle incoming message: $e');
    }
  }

  /// Handle typing indicator
  void _handleTypingIndicator(Map<String, dynamic> data) {
    final typingMessage = TypingIndicator.fromJson(data);
    _messageController.add(
      RealtimeMessage(
        id: 'typing_${DateTime.now().millisecondsSinceEpoch}',
        senderId: typingMessage.senderId,
        recipientId: typingMessage.recipientId,
        content: '',
        type: MessageType.typing,
        timestamp: typingMessage.timestamp,
        metadata: {'isTyping': typingMessage.isTyping},
      ),
    );
  }

  /// Handle read receipt
  void _handleReadReceipt(Map<String, dynamic> data) {
    final readReceipt = ReadReceipt.fromJson(data);
    _messageController.add(
      RealtimeMessage(
        id: 'read_${DateTime.now().millisecondsSinceEpoch}',
        senderId: readReceipt.readerId,
        recipientId: readReceipt.senderId,
        content: '',
        type: MessageType.readReceipt,
        timestamp: readReceipt.timestamp,
        metadata: {'messageId': readReceipt.messageId},
      ),
    );
  }

  /// Handle user status
  void _handleUserStatus(Map<String, dynamic> data) {
    final userStatus = UserStatus.fromJson(data);
    _messageController.add(
      RealtimeMessage(
        id: 'status_${DateTime.now().millisecondsSinceEpoch}',
        senderId: userStatus.userId,
        recipientId: '',
        content: '',
        type: MessageType.userStatus,
        timestamp: userStatus.timestamp,
        metadata: {
          'status': userStatus.status,
          'lastSeen': userStatus.lastSeen?.toIso8601String(),
        },
      ),
    );
  }

  /// Start heartbeat
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        try {
          final heartbeat = {
            'type': 'heartbeat',
            'userId': _userId,
            'timestamp': DateTime.now().toIso8601String(),
          };
          _channel!.sink.add(json.encode(heartbeat));
          debugPrint('💓 Heartbeat sent');
        } catch (e) {
          debugPrint('❌ Heartbeat failed: $e');
        }
      }
    });
  }

  /// Handle connection error
  void _handleConnectionError(dynamic error) {
    _isConnected = false;
    _lastError = error.toString();
    notifyListeners();
    _scheduleReconnect();
  }

  /// Handle connection closed
  void _handleConnectionClosed() {
    _isConnected = false;
    notifyListeners();
    _scheduleReconnect();
  }

  /// Schedule reconnection
  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      debugPrint('❌ Max reconnection attempts reached');
      return;
    }

    _reconnectTimer?.cancel();
    final delay = Duration(seconds: (2 << _reconnectAttempts).clamp(1, 30));

    debugPrint(
      '🔄 Scheduling reconnection in ${delay.inSeconds}s (attempt ${_reconnectAttempts + 1})',
    );

    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      connect();
    });
  }

  /// Send queued messages
  Future<void> _sendQueuedMessages() async {
    if (_messageQueue.isEmpty) return;

    try {
      for (final message in List.from(_messageQueue)) {
        _channel!.sink.add(json.encode(message.toJson()));
        _messageQueue.remove(message);
        debugPrint('📤 Queued message sent: ${message.id}');
      }

      await _saveQueuedMessages();
    } catch (e) {
      debugPrint('❌ Failed to send queued messages: $e');
    }
  }

  /// Save queued messages
  Future<void> _saveQueuedMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = _messageQueue.map((m) => m.toJson()).toList();
      await prefs.setString('queued_messages', json.encode(messagesJson));
    } catch (e) {
      debugPrint('❌ Failed to save queued messages: $e');
    }
  }

  /// Load queued messages
  Future<void> _loadQueuedMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesString = prefs.getString('queued_messages');

      if (messagesString != null) {
        final List<dynamic> messagesJson = json.decode(messagesString);
        _messageQueue.clear();
        _messageQueue.addAll(
          messagesJson.map((json) => RealtimeMessage.fromJson(json)),
        );
      }

      debugPrint('✅ Loaded ${_messageQueue.length} queued messages');
    } catch (e) {
      debugPrint('❌ Failed to load queued messages: $e');
    }
  }

  /// Get auth token
  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token') ?? 'demo_token';
    } catch (e) {
      debugPrint('❌ Failed to get auth token: $e');
      return 'demo_token';
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _messageController.close();
    disconnect();
    super.dispose();
  }
}

/// Real-time message model
class RealtimeMessage {
  final String id;
  final String senderId;
  final String recipientId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const RealtimeMessage({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'recipientId': recipientId,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory RealtimeMessage.fromJson(Map<String, dynamic> json) {
    return RealtimeMessage(
      id: json['id'],
      senderId: json['senderId'],
      recipientId: json['recipientId'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'],
    );
  }
}

/// Message types
enum MessageType {
  text,
  image,
  audio,
  video,
  file,
  typing,
  readReceipt,
  userStatus,
}

/// Typing indicator model
class TypingIndicator {
  final String senderId;
  final String recipientId;
  final bool isTyping;
  final DateTime timestamp;

  const TypingIndicator({
    required this.senderId,
    required this.recipientId,
    required this.isTyping,
    required this.timestamp,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    return TypingIndicator(
      senderId: json['senderId'],
      recipientId: json['recipientId'],
      isTyping: json['isTyping'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// Read receipt model
class ReadReceipt {
  final String messageId;
  final String readerId;
  final String senderId;
  final DateTime timestamp;

  const ReadReceipt({
    required this.messageId,
    required this.readerId,
    required this.senderId,
    required this.timestamp,
  });

  factory ReadReceipt.fromJson(Map<String, dynamic> json) {
    return ReadReceipt(
      messageId: json['messageId'],
      readerId: json['readerId'],
      senderId: json['senderId'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// User status model
class UserStatus {
  final String userId;
  final String status;
  final DateTime? lastSeen;
  final DateTime timestamp;

  const UserStatus({
    required this.userId,
    required this.status,
    this.lastSeen,
    required this.timestamp,
  });

  factory UserStatus.fromJson(Map<String, dynamic> json) {
    return UserStatus(
      userId: json['userId'],
      status: json['status'],
      lastSeen:
          json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
