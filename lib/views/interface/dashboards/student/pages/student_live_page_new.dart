import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../providers/app_providers.dart';
import '../../../../../models/core_models.dart';

class StudentLivePage extends StatefulWidget {
  const StudentLivePage({super.key});

  @override
  State<StudentLivePage> createState() => _StudentLivePageState();
}

class _StudentLivePageState extends State<StudentLivePage> {
  bool _isInSession = false;
  bool _isMicOn = true;
  bool _isCameraOn = true;
  bool _isFullScreen = false;
  String? _sessionId;
  Booking? _currentBooking;

  @override
  void initState() {
    super.initState();
    _checkForActiveSession();
  }

  Future<void> _checkForActiveSession() async {
    final authProvider = context.read<AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();

    if (authProvider.currentUser != null) {
      await bookingProvider.loadUserBookings(
        authProvider.currentUser!.id,
        authProvider.currentUser!.role,
      );

      // Check for any confirmed booking that should be live now
      final now = DateTime.now();
      final liveBookings = bookingProvider.userBookings.where((booking) {
        if (booking.status != BookingStatus.confirmed) return false;
        
        final sessionStart = DateTime(
          booking.slot.date.year,
          booking.slot.date.month,
          booking.slot.date.day,
          booking.slot.startTime.hour,
          booking.slot.startTime.minute,
        );
        
        final sessionEnd = DateTime(
          booking.slot.date.year,
          booking.slot.date.month,
          booking.slot.date.day,
          booking.slot.endTime.hour,
          booking.slot.endTime.minute,
        );
        
        return now.isAfter(sessionStart) && now.isBefore(sessionEnd);
      }).toList();

      if (liveBookings.isNotEmpty && mounted) {
        setState(() {
          _currentBooking = liveBookings.first;
          _sessionId = _currentBooking!.id;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer2<AuthProvider, BookingProvider>(
        builder: (context, authProvider, bookingProvider, child) {
          if (authProvider.currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_isInSession && _currentBooking != null) {
            return _buildLiveSessionView();
          }

          return _buildWaitingView(bookingProvider);
        },
      ),
    );
  }

  Widget _buildWaitingView(BookingProvider bookingProvider) {
    // Check for upcoming sessions today
    final today = DateTime.now();
    final upcomingToday = bookingProvider.userBookings.where((booking) {
      if (booking.status != BookingStatus.confirmed) return false;
      
      return booking.slot.date.year == today.year &&
             booking.slot.date.month == today.month &&
             booking.slot.date.day == today.day;
    }).toList();

    upcomingToday.sort((a, b) => a.slot.startTime.hour.compareTo(b.slot.startTime.hour));

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF3B82F6),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Live Session Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'LIVE SESSION',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Main Content
              if (upcomingToday.isEmpty) ...[
                Icon(
                  Icons.videocam_off,
                  size: 80,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(height: 30),
                Text(
                  'No Live Sessions Today',
                  style: GoogleFonts.merriweather(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'You do not have any confirmed sessions scheduled for today.\nCheck your bookings to see upcoming sessions.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    DefaultTabController.of(context).animateTo(1);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    'View Bookings',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.access_time,
                  size: 80,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(height: 30),
                Text(
                  'Sessions Today',
                  style: GoogleFonts.merriweather(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Your confirmed sessions for today will appear here when it is time to join.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Today's Sessions
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    itemCount: upcomingToday.length,
                    itemBuilder: (context, index) {
                      final booking = upcomingToday[index];
                      return _buildSessionCard(booking);
                    },
                  ),
                ),
              ],

              const Spacer(),

              // System Check Button
              OutlinedButton.icon(
                onPressed: _performSystemCheck,
                icon: const Icon(Icons.settings),
                label: Text(
                  'Test Camera & Microphone',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard(Booking booking) {
    final now = DateTime.now();
    final sessionStart = DateTime(
      booking.slot.date.year,
      booking.slot.date.month,
      booking.slot.date.day,
      booking.slot.startTime.hour,
      booking.slot.startTime.minute,
    );
    
    final canJoin = now.isAfter(sessionStart.subtract(const Duration(minutes: 5)));
    final isLive = now.isAfter(sessionStart) && 
                   now.isBefore(DateTime(
                     booking.slot.date.year,
                     booking.slot.date.month,
                     booking.slot.date.day,
                     booking.slot.endTime.hour,
                     booking.slot.endTime.minute,
                   ));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isLive ? Colors.green : Colors.white.withOpacity(0.2),
          width: isLive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Text(
                  'Q',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Qari ${booking.qariId.substring(0, 8)}',
                      style: GoogleFonts.merriweather(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${booking.slot.startTime.hour.toString().padLeft(2, '0')}:${booking.slot.startTime.minute.toString().padLeft(2, '0')} - ${booking.slot.endTime.hour.toString().padLeft(2, '0')}:${booking.slot.endTime.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (isLive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'LIVE',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 15),
          
          ElevatedButton.icon(
            onPressed: canJoin ? () => _joinSession(booking) : null,
            icon: Icon(
              isLive ? Icons.videocam : Icons.access_time,
              size: 18,
            ),
            label: Text(
              isLive ? 'Join Now' : canJoin ? 'Ready to Join' : 'Not Ready',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isLive ? Colors.green : canJoin ? Colors.blue : Colors.grey,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveSessionView() {
    return Stack(
      children: [
        // Video Feed (Placeholder)
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Stack(
            children: [
              // Main video (Qari's video)
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 60,
                        backgroundColor: Color(0xFF3498DB),
                        child: Text(
                          'Q',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Qari ${_currentBooking?.qariId.substring(0, 8) ?? ''}',
                        style: GoogleFonts.merriweather(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Connected',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Student's video (Picture-in-picture)
              Positioned(
                top: 60,
                right: 20,
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[600],
                        child: Icon(
                          _isCameraOn ? Icons.person : Icons.videocam_off,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Session Info Header
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
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
                        const SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '45:30', // Timer would be dynamic
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Microphone
                  _buildControlButton(
                    icon: _isMicOn ? Icons.mic : Icons.mic_off,
                    isActive: _isMicOn,
                    onTap: () {
                      setState(() {
                        _isMicOn = !_isMicOn;
                      });
                    },
                  ),

                  // Camera
                  _buildControlButton(
                    icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                    isActive: _isCameraOn,
                    onTap: () {
                      setState(() {
                        _isCameraOn = !_isCameraOn;
                      });
                    },
                  ),

                  // End Call
                  _buildControlButton(
                    icon: Icons.call_end,
                    isActive: false,
                    isEndCall: true,
                    onTap: _endSession,
                  ),

                  // Fullscreen
                  _buildControlButton(
                    icon: _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    isActive: _isFullScreen,
                    onTap: () {
                      setState(() {
                        _isFullScreen = !_isFullScreen;
                      });
                    },
                  ),

                  // Settings
                  _buildControlButton(
                    icon: Icons.settings,
                    isActive: false,
                    onTap: _showSessionSettings,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    bool isEndCall = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isEndCall
              ? Colors.red
              : isActive
                  ? Colors.white
                  : Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: isEndCall
              ? Colors.white
              : isActive
                  ? Colors.black
                  : Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _joinSession(Booking booking) {
    setState(() {
      _isInSession = true;
      _currentBooking = booking;
      _sessionId = booking.id;
    });
  }

  void _endSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.call_end,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'End Session',
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to end this session?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isInSession = false;
                _currentBooking = null;
                _sessionId = null;
              });
              
              // Update booking status to completed
              if (_currentBooking != null) {
                context.read<BookingProvider>().updateBookingStatus(
                  _currentBooking!.id,
                  BookingStatus.completed,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'End Session',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performSystemCheck() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.settings,
              color: Color(0xFF3498DB),
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'System Check',
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSystemCheckItem('Camera', true),
            _buildSystemCheckItem('Microphone', true),
            _buildSystemCheckItem('Internet Connection', true),
            _buildSystemCheckItem('Audio Output', true),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'All Good!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemCheckItem(String name, bool isWorking) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isWorking ? Icons.check_circle : Icons.error,
            color: isWorking ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            isWorking ? 'Working' : 'Error',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isWorking ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Session Settings',
          style: GoogleFonts.merriweather(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.volume_up),
              title: Text(
                'Audio Settings',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                // Audio settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_settings),
              title: Text(
                'Video Settings',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                // Video settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.record_voice_over),
              title: Text(
                'Recording',
                style: GoogleFonts.poppins(),
              ),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // Toggle recording
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
