
// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../providers/app_providers.dart';
import '../../../../../models/core_models.dart';
import '../../../../../components/live_session_widget.dart';

class QariLivePage extends StatefulWidget {
  const QariLivePage({super.key});

  @override
  State<QariLivePage> createState() => _QariLivePageState();
}

class _QariLivePageState extends State<QariLivePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _startRealTimeListening();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _startRealTimeListening() {
    final authProvider = context.read<AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();

    if (authProvider.currentUser != null) {
      bookingProvider.startListeningToUserBookings(
        authProvider.currentUser!.id,
        authProvider.currentUser!.role,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF27AE60).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Consumer2<AuthProvider, BookingProvider>(
          builder: (context, authProvider, bookingProvider, child) {
            if (authProvider.currentUser == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                const SizedBox(height: 40),
                
                // Header
                _buildHeader(bookingProvider),
                
                // Tab Bar
                _buildTabBar(),
                
                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTodaySessionsList(bookingProvider),
                      _buildUpcomingSessionsList(bookingProvider),
                      _buildLiveSessionHistory(bookingProvider),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BookingProvider bookingProvider) {
    final todaySessions = _getTodaySessions(bookingProvider);
    final upcomingSessions = _getUpcomingSessions(bookingProvider);
    final confirmedBookings = bookingProvider.getBookingsByStatus(BookingStatus.confirmed).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.live_tv,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Live Sessions',
                style: GoogleFonts.merriweather(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Today',
                  todaySessions.length.toString(),
                  const Color(0xFF27AE60),
                  Icons.today,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  'Upcoming',
                  upcomingSessions.length.toString(),
                  const Color(0xFF3498DB),
                  Icons.upcoming,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  'Total',
                  confirmedBookings.toString(),
                  const Color(0xFFF39C12),
                  Icons.video_call,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.merriweather(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF27AE60),
        labelColor: const Color(0xFF27AE60),
        unselectedLabelColor: Colors.grey[600],
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Today\'s Sessions'),
          Tab(text: 'Upcoming'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  Widget _buildTodaySessionsList(BookingProvider bookingProvider) {
    final todaySessions = _getTodaySessions(bookingProvider);
    
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        if (bookingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (bookingProvider.error != null) {
          return _buildErrorState('Error loading today\'s sessions');
        }

        if (todaySessions.isEmpty) {
          return _buildEmptyState(
            'No sessions today',
            'Your confirmed sessions for today will appear here',
            Icons.today,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: todaySessions.length,
          itemBuilder: (context, index) {
            final booking = todaySessions[index];
            return _buildSessionCard(booking, isToday: true);
          },
        );
      },
    );
  }

  Widget _buildUpcomingSessionsList(BookingProvider bookingProvider) {
    final upcomingSessions = _getUpcomingSessions(bookingProvider);
    
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        if (bookingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (bookingProvider.error != null) {
          return _buildErrorState('Error loading upcoming sessions');
        }

        if (upcomingSessions.isEmpty) {
          return _buildEmptyState(
            'No upcoming sessions',
            'Your future confirmed sessions will appear here',
            Icons.upcoming,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: upcomingSessions.length,
          itemBuilder: (context, index) {
            final booking = upcomingSessions[index];
            return _buildSessionCard(booking, isToday: false);
          },
        );
      },
    );
  }

  Widget _buildLiveSessionHistory(BookingProvider bookingProvider) {
    final completedSessions = bookingProvider.getBookingsByStatus(BookingStatus.completed);
    
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        if (bookingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (bookingProvider.error != null) {
          return _buildErrorState('Error loading session history');
        }

        if (completedSessions.isEmpty) {
          return _buildEmptyState(
            'No session history',
            'Your completed sessions will appear here',
            Icons.history,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completedSessions.length,
          itemBuilder: (context, index) {
            final booking = completedSessions[index];
            return _buildHistoryCard(booking);
          },
        );
      },
    );
  }

  Widget _buildSessionCard(Booking booking, {required bool isToday}) {
    final now = DateTime.now();
    final sessionTime = booking.slot.startTime;
    final canStart = isToday && 
                    sessionTime.isBefore(now.add(const Duration(minutes: 15))) &&
                    sessionTime.isAfter(now.subtract(const Duration(minutes: 5)));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canStart 
              ? Colors.green.withOpacity(0.5)
              : Colors.grey.withOpacity(0.2),
          width: canStart ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Quran Session',
                  style: GoogleFonts.merriweather(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              if (canStart)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'READY TO START',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                _formatSessionTime(booking.slot),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.timer, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                _getSessionDuration(booking.slot),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                '\$${booking.price.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Live Session Widget
          LiveSessionWidget(
            booking: booking,
            showJoinButton: canStart || !isToday,
            onSessionStarted: () {
              // Optional: Show a success message or update UI
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session started successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Completed Session',
                style: GoogleFonts.merriweather(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'COMPLETED',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                _formatSessionDate(booking.slot.startTime),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                _formatSessionTime(booking.slot),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                '\$${booking.price.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.merriweather(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 15),
          Text(
            message,
            style: GoogleFonts.merriweather(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              _startRealTimeListening();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  List<Booking> _getTodaySessions(BookingProvider bookingProvider) {
    final today = DateTime.now();
    final confirmedBookings = bookingProvider.getBookingsByStatus(BookingStatus.confirmed);
    
    return confirmedBookings.where((booking) {
      final sessionDate = booking.slot.startTime;
      return sessionDate.year == today.year &&
             sessionDate.month == today.month &&
             sessionDate.day == today.day;
    }).toList();
  }

  List<Booking> _getUpcomingSessions(BookingProvider bookingProvider) {
    final today = DateTime.now();
    final confirmedBookings = bookingProvider.getBookingsByStatus(BookingStatus.confirmed);
    
    return confirmedBookings.where((booking) {
      final sessionDate = booking.slot.startTime;
      return sessionDate.isAfter(DateTime(today.year, today.month, today.day + 1));
    }).toList();
  }

  String _formatSessionTime(TimeSlot slot) {
    final startTime = slot.startTime;
    final endTime = slot.endTime;
    final startFormatted = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endFormatted = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$startFormatted - $endFormatted';
  }

  String _formatSessionDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getSessionDuration(TimeSlot slot) {
    final duration = slot.endTime.difference(slot.startTime);
    final minutes = duration.inMinutes;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    } else {
      return '${minutes}m';
    }
  }
}
