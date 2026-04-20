import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../core/constants/api_constants.dart';
import '../models/message_model.dart';
import 'package:flutter/foundation.dart';

class ConsultSocketService {
  static final ConsultSocketService _instance = ConsultSocketService._internal();
  factory ConsultSocketService() => _instance;
  ConsultSocketService._internal();

  IO.Socket? _socket;
  final _messageController = StreamController<MessageModel>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  
  Timer? _debounceTimer;

  Stream<MessageModel> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;

  void connect(String token) {
    // Determine base url from ApiConstants and form socket url
    // Ex. 'http://10.0.2.2:5000/api' -> 'http://10.0.2.2:5000/consult'
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');
    
    _socket = IO.io('$baseUrl/consult', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': token},
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('Socket Connected: ${_socket!.id}');
    });

    _socket!.onDisconnect((_) {
      debugPrint('Socket Disconnected');
    });

    _socket!.on('new_message', (data) {
      if (!_messageController.isClosed) {
        _messageController.sink.add(MessageModel.fromJson(data));
      }
    });

    _socket!.on('user_typing', (data) {
      if (!_typingController.isClosed) {
        _typingController.sink.add(data);
      }
    });
    
    // For initializing message history
    _socket!.on('session_history', (data) {
       // if backend emits session history on join
       if (data is List) {
          for (var msg in data.reversed) { // Ensure correct order if backend sends newest first
            _messageController.sink.add(MessageModel.fromJson(msg));
          }
       }
    });
  }

  void joinSession(String sessionId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join_session', sessionId);
    }
  }

  void sendMessage(String sessionId, String content, String type) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('send_message', {
        'session_id': sessionId,
        'content': content,
        'type': type,
      });
    }
  }

  void sendTyping(String sessionId) {
    if (_socket != null && _socket!.connected) {
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      
      _socket!.emit('typing', {'session_id': sessionId});
      
      // Debounce logic if backend requires "stop typing" event (optional in UI)
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
         // Some backends expect stop typing emitting, not strictly required
      });
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
