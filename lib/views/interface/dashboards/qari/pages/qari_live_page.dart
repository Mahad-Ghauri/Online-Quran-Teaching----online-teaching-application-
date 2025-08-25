import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QariLivePage extends StatefulWidget {
  const QariLivePage({super.key});

  @override
  State<QariLivePage> createState() => _QariLivePageState();
}

class _QariLivePageState extends State<QariLivePage> {
  bool _isInSession = false;
  bool _isMicMuted = false;
  bool _isVideoOff = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Live Sessions',
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_isInSession)
            IconButton(
              onPressed: _endSession,
              icon: const Icon(Icons.call_end),
              color: Colors.red,
            ),
        ],
      ),
      body: _isInSession ? _buildActiveSession() : _buildSessionOptions(),
    );
  }

  Widget _buildSessionOptions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Start Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.videocam,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Instant Session',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create a room for immediate teaching',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _startInstantSession,
                      icon: const Icon(Icons.videocam),
                      label: const Text('Go Live Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Scheduled Sessions
          Text(
            'Scheduled Sessions',
            style: GoogleFonts.merriweather(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: _mockScheduledSessions.length,
              itemBuilder: (context, index) {
                final session = _mockScheduledSessions[index];
                return _buildScheduledSessionCard(session);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledSessionCard(Map<String, dynamic> session) {
    final now = DateTime.now();
    final sessionTime = DateTime.parse(session['datetime']);
    final canStart = sessionTime.isBefore(now.add(const Duration(minutes: 15))) &&
                    sessionTime.isAfter(now.subtract(const Duration(minutes: 5)));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canStart 
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                session['subject'],
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              if (canStart)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'READY',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                session['studentName'],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                session['time'],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: canStart ? () => _startScheduledSession(session) : null,
                  icon: const Icon(Icons.videocam),
                  label: Text(canStart ? 'Start Session' : 'Not Ready'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canStart ? Colors.green : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  _showSessionDetails(session);
                },
                child: const Text('Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSession() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black87,
            Colors.black54,
          ],
        ),
      ),
      child: Column(
        children: [
          // Session Info
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tajweed Basics Session',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Student: Ahmed Al-Rashid',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '23:45', // Session timer
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Video Area (Placeholder)
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isVideoOff ? Icons.videocam_off : Icons.videocam,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isVideoOff ? 'Camera Off' : 'Live Video',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Session Controls
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: _isMicMuted ? Icons.mic_off : Icons.mic,
                  label: _isMicMuted ? 'Unmute' : 'Mute',
                  color: _isMicMuted ? Colors.red : Colors.green,
                  onPressed: () {
                    setState(() {
                      _isMicMuted = !_isMicMuted;
                    });
                  },
                ),
                _buildControlButton(
                  icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                  label: _isVideoOff ? 'Camera On' : 'Camera Off',
                  color: _isVideoOff ? Colors.red : Colors.green,
                  onPressed: () {
                    setState(() {
                      _isVideoOff = !_isVideoOff;
                    });
                  },
                ),
                _buildControlButton(
                  icon: Icons.screen_share,
                  label: 'Share',
                  color: Colors.blue,
                  onPressed: () {
                    // TODO: Implement screen sharing
                  },
                ),
                _buildControlButton(
                  icon: Icons.call_end,
                  label: 'End',
                  color: Colors.red,
                  onPressed: _endSession,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _startInstantSession() {
    // TODO: Create instant Jitsi room
    setState(() {
      _isInSession = true;
    });
  }

  void _startScheduledSession(Map<String, dynamic> session) {
    // TODO: Join scheduled Jitsi room
    setState(() {
      _isInSession = true;
    });
  }

  void _endSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session'),
        content: const Text('Are you sure you want to end this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isInSession = false;
                _isMicMuted = false;
                _isVideoOff = false;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  void _showSessionDetails(Map<String, dynamic> session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session['subject']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student: ${session['studentName']}'),
            const SizedBox(height: 8),
            Text('Time: ${session['time']}'),
            const SizedBox(height: 8),
            Text('Duration: ${session['duration']}'),
            const SizedBox(height: 8),
            Text('Room ID: ${session['roomId']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Mock data
  static const List<Map<String, dynamic>> _mockScheduledSessions = [
    {
      'subject': 'Tajweed Basics',
      'studentName': 'Ahmed Al-Rashid',
      'time': '2:00 PM - 3:00 PM',
      'datetime': '2025-08-25T14:00:00Z',
      'duration': '60 minutes',
      'roomId': 'qari-ahmed-20250825-1400',
    },
    {
      'subject': 'Quran Memorization',
      'studentName': 'Fatima Khan',
      'time': '4:00 PM - 5:00 PM',
      'datetime': '2025-08-25T16:00:00Z',
      'duration': '60 minutes',
      'roomId': 'qari-fatima-20250825-1600',
    },
    {
      'subject': 'Arabic Grammar',
      'studentName': 'Omar Hassan',
      'time': '10:00 AM - 11:00 AM',
      'datetime': '2025-08-26T10:00:00Z',
      'duration': '60 minutes',
      'roomId': 'qari-omar-20250826-1000',
    },
  ];
}
