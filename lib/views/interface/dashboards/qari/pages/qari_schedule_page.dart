// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../providers/app_providers.dart';
import '../../../../../models/core_models.dart';
import '../../../../../components/live_session_widget.dart';

class QariSchedulePage extends StatefulWidget {
  const QariSchedulePage({super.key});

  @override
  State<QariSchedulePage> createState() => _QariSchedulePageState();
}

class _QariSchedulePageState extends State<QariSchedulePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Schedule & Availability',
          style: GoogleFonts.merriweather(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Availability'),
            Tab(text: 'Bookings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AvailabilityTab(),
          _BookingsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddAvailabilityDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Slot'),
      ),
    );
  }

  void _showAddAvailabilityDialog() {
    showDialog(
      context: context,
      builder: (context) => const _AddAvailabilityDialog(),
    );
  }
}

class _AvailabilityTab extends StatelessWidget {
  const _AvailabilityTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<QariProvider>(
      builder: (context, qariProvider, child) {
        final qariProfile = qariProvider.currentQariProfile;
        final availableSlots = qariProfile?.availableSlots ?? [];
        
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weekly Overview
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Week\'s Availability',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildWeeklyAvailability(availableSlots),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Available Time Slots
              Text(
                'Available Time Slots',
                style: GoogleFonts.merriweather(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              if (availableSlots.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No availability slots',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your available time slots to receive bookings',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: availableSlots.length,
                    itemBuilder: (context, index) {
                      final slot = availableSlots[index];
                      return _buildAvailabilitySlot(slot);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyAvailability(List<TimeSlot> availableSlots) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    // Calculate slots for each day of the current week
    final availability = List.generate(7, (index) {
      final day = weekStart.add(Duration(days: index));
      return availableSlots.where((slot) {
        return slot.date.day == day.day &&
               slot.date.month == day.month &&
               slot.date.year == day.year;
      }).length;
    });
    
    return Builder(
      builder: (context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final hasSlots = availability[index] > 0;
          return Column(
            children: [
              Text(
                days[index],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: hasSlots 
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasSlots 
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${availability[index]}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: hasSlots 
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAvailabilitySlot(TimeSlot slot) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = days[slot.date.weekday - 1];
    
    String formatTime(DateTime time) {
      final hour = time.hour;
      final minute = time.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${displayHour}:${minute.toString().padLeft(2, '0')} $period';
    }
    
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.green.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                dayName,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[700],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${formatTime(slot.startTime)} - ${formatTime(slot.endTime)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${slot.date.day}/${slot.date.month}/${slot.date.year}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
              onSelected: (value) async {
                if (value == 'delete') {
                  await _deleteAvailabilitySlot(context, slot);
                } else if (value == 'edit') {
                  // TODO: Implement edit functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit functionality coming soon!'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAvailabilitySlot(BuildContext context, TimeSlot slot) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Availability Slot',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you sure you want to delete this availability slot?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Remove the slot using QariProvider
      final qariProvider = Provider.of<QariProvider>(context, listen: false);
      final success = await qariProvider.removeAvailabilitySlot(slot);

      if (context.mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Availability slot deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Show error message
          final error = qariProvider.error ?? 'Failed to delete availability slot';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        // Close loading dialog
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        final bookings = bookingProvider.userBookings;
        final isLoading = bookingProvider.isLoading;
        
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search bookings...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  PopupMenuButton<String>(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.filter_list),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'all', child: Text('All')),
                      const PopupMenuItem(value: 'today', child: Text('Today')),
                      const PopupMenuItem(value: 'week', child: Text('This Week')),
                      const PopupMenuItem(value: 'month', child: Text('This Month')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Bookings List
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : bookings.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: bookings.length,
                            itemBuilder: (context, index) {
                              final booking = bookings[index];
                              return _buildRealTimeBookingCard(booking);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No bookings yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your bookings will appear here',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealTimeBookingCard(Booking booking) {
    Color statusColor;
    IconData statusIcon;
    
    switch (booking.status) {
      case BookingStatus.confirmed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case BookingStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case BookingStatus.completed:
        statusColor = Colors.blue;
        statusIcon = Icons.done_all;
        break;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  booking.status.name.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '${booking.slot.date.day}/${booking.slot.date.month}/${booking.slot.date.year}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Student ID: ${booking.studentId}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Time: ${_formatTime(booking.slot.startTime)} - ${_formatTime(booking.slot.endTime)}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            // Live Session Button for confirmed bookings
            QuickSessionButton(
              booking: booking,
              onSessionStarted: () {
                // Refresh bookings after session
                // The parent widget will handle state refresh
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _AddAvailabilityDialog extends StatefulWidget {
  const _AddAvailabilityDialog();

  @override
  State<_AddAvailabilityDialog> createState() => _AddAvailabilityDialogState();
}

class _AddAvailabilityDialogState extends State<_AddAvailabilityDialog> {
  String? selectedDay;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final List<String> days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 
    'Friday', 'Saturday', 'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add Availability',
        style: GoogleFonts.merriweather(fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedDay,
            decoration: const InputDecoration(
              labelText: 'Day',
              border: OutlineInputBorder(),
            ),
            items: days.map((day) => DropdownMenuItem(
              value: day,
              child: Text(day),
            )).toList(),
            onChanged: (value) {
              setState(() {
                selectedDay = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Start Time',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  controller: TextEditingController(
                    text: startTime?.format(context) ?? '',
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        startTime = time;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'End Time',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  controller: TextEditingController(
                    text: endTime?.format(context) ?? '',
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        endTime = time;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canSave() ? () async {
            await _saveAvailabilitySlot();
          } : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  bool _canSave() {
    return selectedDay != null && startTime != null && endTime != null;
  }

  Future<void> _saveAvailabilitySlot() async {
    if (!_canSave()) return;

    // Calculate the next occurrence of the selected day
    final now = DateTime.now();
    final dayIndex = days.indexOf(selectedDay!) + 1; // Monday = 1, Sunday = 7
    final daysUntilTarget = (dayIndex - now.weekday) % 7;
    final targetDate = now.add(Duration(days: daysUntilTarget));

    // Create DateTime objects for start and end times on the target date
    final startDateTime = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      startTime!.hour,
      startTime!.minute,
    );

    final endDateTime = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      endTime!.hour,
      endTime!.minute,
    );

    // Validate that end time is after start time
    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Create the time slot
    final timeSlot = TimeSlot(
      date: targetDate,
      startTime: startDateTime,
      endTime: endDateTime,
    );

    // Show loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    try {
      // Add the slot using QariProvider
      final qariProvider = Provider.of<QariProvider>(context, listen: false);
      final success = await qariProvider.addAvailabilitySlot(timeSlot);

      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Availability slot added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Close the dialog
          Navigator.of(context).pop();
        } else {
          // Show error message
          final error = qariProvider.error ?? 'Failed to add availability slot';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
