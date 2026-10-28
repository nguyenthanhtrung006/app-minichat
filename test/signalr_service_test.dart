import 'package:flutter_test/flutter_test.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:minichatapp/core/constants/api_constants.dart';
import 'package:minichatapp/core/network/signalr_service.dart';

void main() {
  group('SignalRService Unit Tests', () {
    test('SignalRService singleton instance returns same instance', () {
      final s1 = SignalRService.instance;
      final s2 = SignalRService();
      final s3 = ChatSignalRService.instance;

      expect(identical(s1, s2), isTrue);
      expect(identical(s1, s3), isTrue);
    });

    test('ApiConstants provides chatHubEndpoint and chatHubUrl', () {
      expect(ApiConstants.chatHubEndpoint, equals('/chatHub'));
      expect(ApiConstants.chatHubUrl, contains('/chatHub'));
      expect(ApiConstants.chatHubUrl, startsWith('https://'));
    });

    test('Initial connection state is Disconnected', () {
      final service = SignalRService.instance;
      expect(service.isConnected, isFalse);
      expect(service.connectionState, equals(HubConnectionState.Disconnected));
    });

    test('Stream controllers are accessible and broadcast-ready', () async {
      final service = SignalRService.instance;

      expect(service.messageStream, isNotNull);
      expect(service.typingStream, isNotNull);
      expect(service.onlineStatusStream, isNotNull);
      expect(service.connectionStateStream, isNotNull);
    });

    test('Callbacks can be registered on SignalRService', () {
      final service = SignalRService.instance;

      dynamic receivedMsg;
      dynamic typingData;
      dynamic onlineData;
      HubConnectionState? stateData;

      service.onMessageReceived = (msg) => receivedMsg = msg;
      service.onUserTyping = (data) => typingData = data;
      service.onUserOnlineStatus = (data) => onlineData = data;
      service.onConnectionStateChanged = (state) => stateData = state;

      service.onMessageReceived?.call({'text': 'Hello'});
      service.onUserTyping?.call({'conversationId': 1, 'isTyping': true});
      service.onUserOnlineStatus?.call({'userId': 12, 'isOnline': true});
      service.onConnectionStateChanged?.call(HubConnectionState.Connected);

      expect(receivedMsg, equals({'text': 'Hello'}));
      expect(typingData, equals({'conversationId': 1, 'isTyping': true}));
      expect(onlineData, equals({'userId': 12, 'isOnline': true}));
      expect(stateData, equals(HubConnectionState.Connected));
    });
  });
}
