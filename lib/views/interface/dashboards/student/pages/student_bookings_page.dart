// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../providers/app_providers.dart';
import '../../../../../models/core_models.dart';
import '../../../../../components/live_session_widget.dart';

class StudentBookingsPage extends StatefulWidget {
  const StudentBookingsPage({super.key});

  @override
  State<StudentBookingsPage> createState() => _StudentBookingsPageState();
}

class _StudentBookingsPageState extends State<StudentBookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
              const Color.fromARGB(255, 0, 166, 147).withOpacity(0.3),
              const Color.fromARGB(255, 0, 166, 147).withOpacity(0.6),
              const Color.fromARGB(255, 0, 166, 147).withOpacity(0.9),
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
                      _buildBookingsList(
                        bookingProvider.getBookingsByStatus(
                          BookingStatus.pending,
                        ),
                        'No pending bookings',
                        'Your booking requests will appear here',
                      ),
                      _buildBookingsList(
                        bookingProvider.getBookingsByStatus(
                          BookingStatus.confirmed,
                        ),
                        'No confirmed bookings',
                        'Your confirmed sessions will appear here',
                      ),
                      _buildBookingsList(
                        bookingProvider.getBookingsByStatus(
                          BookingStatus.completed,
                        ),
                        'No completed sessions',
                        'Your past sessions will appear here',
                      ),
                      _buildBookingsList(
                        bookingProvider.getBookingsByStatus(
                          BookingStatus.cancelled,
                        ),
                        'No cancelled bookings',
                        'Cancelled sessions will appear here',
                      ),
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
    final totalBookings = bookingProvider.userBookings.length;
    final pendingBookings = bookingProvider
        .getBookingsByStatus(BookingStatus.pending)
        .length;
    final confirmedBookings = bookingProvider
        .getBookingsByStatus(BookingStatus.confirmed)
        .length;

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
          Text(
            'My Bookings',
            style: GoogleFonts.merriweather(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  totalBookings.toString(),
                  const Color(0xFF3498DB),
                  Icons.book,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  pendingBookings.toString(),
                  const Color(0xFFF39C12),
                  Icons.pending_actions,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  'Confirmed',
                  confirmedBookings.toString(),
                  const Color(0xFF27AE60),
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
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
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
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
        indicatorColor: Theme.of(context).primaryColor,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        isScrollable: true,
        tabs: const [
          Tab(text: 'Pending'),
          Tab(text: 'Confirmed'),
          Tab(text: 'Completed'),
          Tab(text: 'Cancelled'),
        ],
      ),
    );
  }

  Widget _buildBookingsList(
    List<Booking> bookings,
    String emptyTitle,
    String emptySubtitle,
  ) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        if (bookingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (bookingProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 15),
                Text(
                  'Error loading bookings',
                  style: GoogleFonts.merriweather(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  bookingProvider.error!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _startRealTimeListening(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 15),
                Text(
                  emptyTitle,
                  style: GoogleFonts.merriweather(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  emptySubtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _startRealTimeListening(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _buildBookingCard(booking);
            },
          ),
        );
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    'Q',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Qari ${booking.qariId.substring(0, 8)}',
                        style: GoogleFonts.merriweather(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getStatusColor(booking.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            booking.status.displayName,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(booking.status),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${booking.price.toStringAsFixed(0)}',
                  style: GoogleFonts.merriweather(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Date and Time
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Date',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(booking.slot.date),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Time',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${booking.slot.startTime.hour.toString().padLeft(2, '0')}:${booking.slot.startTime.minute.toString().padLeft(2, '0')} - ${booking.slot.endTime.hour.toString().padLeft(2, '0')}:${booking.slot.endTime.minute.toString().padLeft(2, '0')}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Booking Info
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Booked on ${_formatDate(booking.createdAt)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Action Buttons
<<<<<<< HEAD
            if (booking.status == BookingStatus.pending || booking.status == BookingStatus.confirmed)
              Column(
                children: [
                  if (booking.status == BookingStatus.confirmed) ...[
                    // Live Session Widget
                    QuickSessionButton(
                      booking: booking,
                      onSessionStarted: () {
                        // Refresh bookings after session
                        if (mounted) {
                          setState(() {});
                        }
                      },
=======
            if (booking.status == BookingStatus.pending ||
                booking.status == BookingStatus.confirmed)
              Row(
                children: [
                  if (booking.status == BookingStatus.confirmed) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _joinSession(booking);
                        },
                        icon: const Icon(Icons.videocam, size: 18),
                        label: Text(
                          'Join Session',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF27AE60),
                          side: const BorderSide(color: Color(0xFF27AE60)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
>>>>>>> fb349743c1f2ec560d721b014649db437c290cb7
                    ),
                    const SizedBox(height: 10),
                  ],
                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _cancelBooking(booking);
                      },
                      icon: const Icon(Icons.cancel, size: 18),
                      label: Text(
                        'Cancel Booking',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE74C3C),
                        side: const BorderSide(color: Color(0xFFE74C3C)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return const Color(0xFF27AE60);
      case BookingStatus.pending:
        return const Color(0xFFF39C12);
      case BookingStatus.completed:
        return const Color(0xFF3498DB);
      case BookingStatus.cancelled:
        return const Color(0xFFE74C3C);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

<<<<<<< HEAD
=======
  void _joinSession(Booking booking) {
    // Navigate to live session page
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.videocam, color: const Color(0xFF27AE60), size: 28),
            const SizedBox(width: 12),
            Text(
              'Join Session',
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'You will be connected to your Qari for the scheduled session.',
          style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
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
              // Navigate to live page
              DefaultTabController.of(context).animateTo(3);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
            ),
            child: Text(
              'Join Now',
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

>>>>>>> fb349743c1f2ec560d721b014649db437c290cb7
  void _cancelBooking(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.warning, color: const Color(0xFFE74C3C), size: 28),
            const SizedBox(width: 12),
            Text(
              'Cancel Booking',
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep Booking',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final bookingProvider = context.read<BookingProvider>();
              final success = await bookingProvider.updateBookingStatus(
                booking.id,
                BookingStatus.cancelled,
              );

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Booking cancelled successfully',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: const Color(0xFF27AE60),
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to cancel booking',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: const Color(0xFFE74C3C),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
            ),
            child: Text(
              'Cancel Booking',
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
}
