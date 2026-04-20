import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../auth/domain/providers/auth_provider.dart';
import '../../data/models/session_model.dart';
import '../../data/models/message_model.dart';
import '../../data/services/consult_socket_service.dart';

class SessionState {
  final SessionModel? session;
  final bool isTyping;

  SessionState({this.session, this.isTyping = false});

  SessionState copyWith({SessionModel? session, bool? isTyping}) {
    return SessionState(
      session: session ?? this.session,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  final ConsultSocketService _socketService = ConsultSocketService();
  StreamSubscription? _messageSub;
  StreamSubscription? _typingSub;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  SessionNotifier() : super(SessionState());

  Future<void> connectAndJoin(SessionModel session) async {
    state = state.copyWith(session: session);
    
    final token = await _secureStorage.read(key: 'access_token') ?? '';
    _socketService.connect(token);
    
    // Slight delay to ensure connection is established
    Future.delayed(const Duration(milliseconds: 500), () {
      _socketService.joinSession(session.id);
    });

    _messageSub?.cancel();
    _messageSub = _socketService.messageStream.listen((message) {
      if (state.session != null) {
        final messages = [...state.session!.messages, message];
        state = state.copyWith(
          session: state.session!.copyWith(messages: messages),
        );
      }
    });

    Timer? typingResetTimer;
    _typingSub?.cancel();
    _typingSub = _socketService.typingStream.listen((data) {
      state = state.copyWith(isTyping: true);
      
      typingResetTimer?.cancel();
      typingResetTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) state = state.copyWith(isTyping: false);
      });
    });
  }

  void sendMessage(String content, String type) {
    if (state.session != null) {
      _socketService.sendMessage(state.session!.id, content, type);
    }
  }

  void sendTyping() {
    if (state.session != null) {
      _socketService.sendTyping(state.session!.id);
    }
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _typingSub?.cancel();
    _socketService.disconnect();
    super.dispose();
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier();
});
