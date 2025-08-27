// Agora RTC service for live video/audio sessions
// Uses Agora SDK for reliable video calling

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgoraService {
  // Testing App ID configured for Testing Mode (no token required)
  static const String appId = "7ac5ea876975400ca1b76b3a242002b6"; 
  
  // Set to true if your Agora project is in Testing Mode (no token required)
  // Set to false if using Secured Mode (token required)
  static const bool useTestingMode = true;
  
  // Temporary token for testing - only used if useTestingMode is false
  static const String tempToken = "007eJxTYMjV2e/6pSS2OP5aTAlXH/NCr/drmJtO8DR8njHx2rKH6k0KDElmhmZJaUnGZsYWiSbG5mmJJklpBpYWKZam5qYGBobJkyXWZzQEMjK8meHLzMgAgSA+D0NhaVFiXnJ+Xl5qcgkDAwBtoSMk";
  
  RtcEngine? _engine;
  bool _isInitialized = false;
  bool _isJoined = false;
  bool _localUserJoined = false;
  bool _remoteUserJoined = false;
  int? _remoteUid;
  bool _isVideoMuted = false;
  bool _isAudioMuted = false;
  
  // Callbacks
  Function(bool)? onLocalUserJoined;
  Function(int, bool)? onRemoteUserJoined;
  Function()? onConnectionLost;
  Function(String)? onError;

  Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      // Check if we have a valid App ID
      if (appId.isEmpty) {
        onError?.call('Agora App ID not configured. Please add your Agora App ID to use video calling.');
        return false;
      }

      await _requestPermissions();
      
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print('Agora: Successfully joined channel');
            _isJoined = true;
            _localUserJoined = true;
            onLocalUserJoined?.call(true);
          },
          onUserJoined: (RtcConnection connection, int uid, int elapsed) {
            print('Agora: User $uid joined');
            _remoteUid = uid;
            _remoteUserJoined = true;
            onRemoteUserJoined?.call(uid, true);
          },
          onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
            print('Agora: User $uid left');
            _remoteUid = null;
            _remoteUserJoined = false;
            onRemoteUserJoined?.call(uid, false);
          },
          onConnectionLost: (RtcConnection connection) {
            print('Agora: Connection lost');
            onConnectionLost?.call();
          },
          onError: (ErrorCodeType error, String msg) {
            print('Agora Error: ${error.name} - $msg');
            onError?.call('Agora Error: ${error.name} - $msg');
          },
          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
            print('Agora: Token will expire');
            onError?.call('Token will expire soon');
          },
        ),
      );

      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await _engine!.enableVideo();
      await _engine!.enableAudio();
      
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Agora initialization error: $e');
      onError?.call('Failed to initialize Agora: $e');
      return false;
    }
  }

  Future<void> _requestPermissions() async {
    await [Permission.microphone, Permission.camera].request();
  }

  Future<String> startQariSession(String bookingId) async {
    try {
      final initialized = await initialize();
      if (!initialized) {
        throw Exception('Failed to initialize Agora SDK');
      }

      // Create a unique channel name
      final channelName = 'session_$bookingId';
      print('Agora: Starting Qari session with channel: $channelName');
      
      // Store session info in Firestore for student to find
      await FirebaseFirestore.instance
          .collection('live_sessions')
          .doc(bookingId)
          .set({
        'channelName': channelName,
        'qariId': FirebaseAuth.instance.currentUser?.uid,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Try joining with empty token first (for testing mode)
      try {
        print('Agora: Attempting to join channel with empty token');
        await _engine!.joinChannel(
          token: "",
          channelId: channelName,
          uid: 0,
          options: const ChannelMediaOptions(),
        );
      } catch (e) {
        print('Agora: Failed with empty token, trying with temp token: $e');
        // If empty token fails, try with temp token
        await _engine!.joinChannel(
          token: tempToken,
          channelId: channelName,
          uid: 0,
          options: const ChannelMediaOptions(),
        );
      }

      return channelName;
    } catch (e) {
      print('Agora: startQariSession error: $e');
      throw Exception('Failed to start Qari session: $e');
    }
  }

  Future<void> joinStudentSession(String bookingId) async {
    try {
      final initialized = await initialize();
      if (!initialized) {
        throw Exception('Failed to initialize Agora SDK');
      }

      // Get session info from Firestore
      final sessionDoc = await FirebaseFirestore.instance
          .collection('live_sessions')
          .doc(bookingId)
          .get();
      
      if (!sessionDoc.exists) {
        throw Exception('Session not found');
      }

      final sessionData = sessionDoc.data()!;
      final channelName = sessionData['channelName'] as String;
      print('Agora: Student joining channel: $channelName');

      // Try joining with empty token first (for testing mode)
      try {
        print('Agora: Attempting to join channel with empty token');
        await _engine!.joinChannel(
          token: "",
          channelId: channelName,
          uid: 0,
          options: const ChannelMediaOptions(),
        );
      } catch (e) {
        print('Agora: Failed with empty token, trying with temp token: $e');
        // If empty token fails, try with temp token
        await _engine!.joinChannel(
          token: tempToken,
          channelId: channelName,
          uid: 0,
          options: const ChannelMediaOptions(),
        );
      }

    } catch (e) {
      print('Agora: joinStudentSession error: $e');
      throw Exception('Failed to join student session: $e');
    }
  }

  Future<void> toggleVideo() async {
    if (_engine != null) {
      _isVideoMuted = !_isVideoMuted;
      if (_isVideoMuted) {
        // Turn off video completely
        await _engine!.disableVideo();
        print('Agora: Video disabled');
      } else {
        // Turn on video
        await _engine!.enableVideo();
        print('Agora: Video enabled');
      }
    }
  }

  Future<void> toggleAudio() async {
    if (_engine != null) {
      _isAudioMuted = !_isAudioMuted;
      await _engine!.muteLocalAudioStream(_isAudioMuted);
    }
  }

  Future<void> switchCamera() async {
    if (_engine != null) {
      await _engine!.switchCamera();
    }
  }

  Future<void> leaveSession(String bookingId) async {
    try {
      if (_engine != null) {
        await _engine!.leaveChannel();
        
        // Clean up session in Firestore
        await FirebaseFirestore.instance
            .collection('live_sessions')
            .doc(bookingId)
            .delete();
      }
    } catch (e) {
      print('Error leaving session: $e');
    }
  }

  Future<void> dispose() async {
    try {
      if (_engine != null && _isJoined) {
        await _engine!.leaveChannel();
      }
      if (_engine != null) {
        await _engine!.release();
        _engine = null;
      }
      _isInitialized = false;
      _isJoined = false;
      _localUserJoined = false;
      _remoteUserJoined = false;
    } catch (e) {
      print('Error disposing Agora service: $e');
    }
  }

  // Getters
  bool get isJoined => _isJoined;
  bool get localUserJoined => _localUserJoined;
  bool get remoteUserJoined => _remoteUserJoined;
  int? get remoteUid => _remoteUid;
  bool get isVideoMuted => _isVideoMuted;
  bool get isAudioMuted => _isAudioMuted;
  RtcEngine? get engine => _engine;
}
