import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../services/agora_service.dart';
import '../models/core_models.dart';

class AgoraVideoCallPage extends StatefulWidget {
  final String bookingId;
  final bool isQari;
  final Booking booking;

  const AgoraVideoCallPage({
    Key? key,
    required this.bookingId,
    required this.isQari,
    required this.booking,
  }) : super(key: key);

  @override
  State<AgoraVideoCallPage> createState() => _AgoraVideoCallPageState();
}

class _AgoraVideoCallPageState extends State<AgoraVideoCallPage> {
  final AgoraService _agoraService = AgoraService();
  bool _isLoading = true;
  bool _isConnected = false;
  bool _remoteUserJoined = false;
  int? _remoteUid;
  String? _errorMessage;
  String? _channelName; // Store the channel name for video rendering

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    try {
      // Set up callbacks
      _agoraService.onLocalUserJoined = (joined) {
        setState(() {
          _isConnected = joined;
          _isLoading = false;
        });
      };

      _agoraService.onRemoteUserJoined = (uid, joined) {
        setState(() {
          _remoteUid = uid;
          _remoteUserJoined = joined;
        });
      };

      _agoraService.onError = (error) {
        setState(() {
          _errorMessage = error;
          _isLoading = false;
        });
      };

      // Add connection timeout
      Future.delayed(const Duration(seconds: 30), () {
        if (_isLoading) {
          setState(() {
            _errorMessage = 'Connection timeout. Please check your internet connection and try again.';
            _isLoading = false;
          });
        }
      });

      // Start or join session based on role and store channel name
      if (widget.isQari) {
        _channelName = await _agoraService.startQariSession(widget.bookingId);
      } else {
        await _agoraService.joinStudentSession(widget.bookingId);
        _channelName = 'session_${widget.bookingId}'; // Set the expected channel name
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.isQari 
            ? 'Teaching Student'
            : 'Learning Session',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildControlBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Connecting to session...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Remote video (full screen)
        if (_remoteUserJoined && _remoteUid != null && _channelName != null)
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _agoraService.engine!,
              canvas: VideoCanvas(uid: _remoteUid),
              connection: RtcConnection(channelId: _channelName),
            ),
          )
        else
          Container(
            color: Colors.grey[900],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, color: Colors.white54, size: 80),
                  SizedBox(height: 16),
                  Text(
                    'Waiting for other participant...',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        
        // Local video (picture-in-picture)
        if (_isConnected && _channelName != null && !_agoraService.isVideoMuted)
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _agoraService.engine!,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
              ),
            ),
          ),

        // Video off indicator for local user
        if (_isConnected && _agoraService.isVideoMuted)
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.black54,
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_off, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Camera Off',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        // Session info overlay
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Session',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Booking ID: ${widget.bookingId}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                if (_isConnected)
                  const Row(
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 8),
                      SizedBox(width: 4),
                      Text(
                        'Connected',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlBar() {
    return Container(
      height: 100,
      color: Colors.black87,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Microphone toggle
          _buildControlButton(
            icon: _agoraService.isAudioMuted ? Icons.mic_off : Icons.mic,
            isActive: !_agoraService.isAudioMuted,
            onPressed: () {
              _agoraService.toggleAudio();
              setState(() {});
            },
          ),
          
          // Camera toggle
          _buildControlButton(
            icon: _agoraService.isVideoMuted ? Icons.videocam_off : Icons.videocam,
            isActive: !_agoraService.isVideoMuted,
            onPressed: () {
              _agoraService.toggleVideo();
              setState(() {});
            },
          ),
          
          // Switch camera
          _buildControlButton(
            icon: Icons.flip_camera_ios,
            isActive: true,
            onPressed: () => _agoraService.switchCamera(),
          ),
          
          // End call
          _buildControlButton(
            icon: Icons.call_end,
            isActive: true,
            backgroundColor: Colors.red,
            onPressed: () => _endCall(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isActive ? Colors.white : Colors.grey),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: backgroundColor != null ? Colors.white : Colors.black,
          size: 28,
        ),
      ),
    );
  }

  Future<void> _endCall() async {
    try {
      await _agoraService.leaveSession(widget.bookingId);
      await _agoraService.dispose();
    } catch (e) {
      print('Error ending call: $e');
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _agoraService.dispose();
    super.dispose();
  }
}
