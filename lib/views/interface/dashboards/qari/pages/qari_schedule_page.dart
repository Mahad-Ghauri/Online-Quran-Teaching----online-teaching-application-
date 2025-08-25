import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
                  _buildWeeklyAvailability(),
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
          Expanded(
            child: ListView.builder(
              itemCount: _mockAvailableSlots.length,
              itemBuilder: (context, index) {
                final slot = _mockAvailableSlots[index];
                return _buildAvailabilitySlot(slot);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyAvailability() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final availability = [3, 2, 4, 1, 3, 2, 0]; // Number of slots per day
    
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

  Widget _buildAvailabilitySlot(Map<String, dynamic> slot) {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: slot['isBooked'] 
                ? Colors.orange.withOpacity(0.3)
                : Colors.green.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: slot['isBooked'] 
                    ? Colors.orange.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                slot['day'],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: slot['isBooked'] ? Colors.orange[700] : Colors.green[700],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${slot['startTime']} - ${slot['endTime']}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (slot['isBooked']) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Booked by ${slot['studentName']}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
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
              onSelected: (value) {
                // TODO: Handle edit/delete
              },
            ),
          ],
        ),
      ),
    );
  }

  // Mock data
  static const List<Map<String, dynamic>> _mockAvailableSlots = [
    {
      'day': 'Monday',
      'startTime': '9:00 AM',
      'endTime': '10:00 AM',
      'isBooked': false,
    },
    {
      'day': 'Monday',
      'startTime': '2:00 PM',
      'endTime': '3:00 PM',
      'isBooked': true,
      'studentName': 'Ahmed Al-Rashid',
    },
    {
      'day': 'Tuesday',
      'startTime': '10:00 AM',
      'endTime': '11:00 AM',
      'isBooked': false,
    },
    {
      'day': 'Wednesday',
      'startTime': '4:00 PM',
      'endTime': '5:00 PM',
      'isBooked': true,
      'studentName': 'Fatima Khan',
    },
  ];
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab();

  @override
  Widget build(BuildContext context) {
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
            child: ListView.builder(
              itemCount: _mockBookings.length,
              itemBuilder: (context, index) {
                final booking = _mockBookings[index];
                return _buildBookingCard(booking);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Builder(
      builder: (context) {
        Color statusColor;
        switch (booking['status']) {
          case 'confirmed':
            statusColor = Colors.green;
            break;
          case 'pending':
            statusColor = Colors.orange;
            break;
          case 'completed':
            statusColor = Colors.blue;
            break;
          default:
            statusColor = Colors.grey;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: statusColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    booking['subject'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      booking['status'].toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
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
                    booking['studentName'],
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
                    '${booking['date']} • ${booking['time']}',
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
                  if (booking['status'] == 'confirmed') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Start session
                        },
                        icon: const Icon(Icons.videocam),
                        label: const Text('Start Session'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  OutlinedButton(
                    onPressed: () {
                      // TODO: View details
                    },
                    child: const Text('Details'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Mock data
  static const List<Map<String, dynamic>> _mockBookings = [
    {
      'subject': 'Tajweed Basics',
      'studentName': 'Ahmed Al-Rashid',
      'date': 'Today',
      'time': '2:00 PM - 3:00 PM',
      'status': 'confirmed',
    },
    {
      'subject': 'Quran Memorization',
      'studentName': 'Fatima Khan',
      'date': 'Today',
      'time': '4:00 PM - 5:00 PM',
      'status': 'confirmed',
    },
    {
      'subject': 'Arabic Grammar',
      'studentName': 'Omar Hassan',
      'date': 'Tomorrow',
      'time': '10:00 AM - 11:00 AM',
      'status': 'pending',
    },
    {
      'subject': 'Quran Reading',
      'studentName': 'Aisha Mohamed',
      'date': 'Yesterday',
      'time': '3:00 PM - 4:00 PM',
      'status': 'completed',
    },
  ];
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
          onPressed: _canSave() ? () {
            // TODO: Save availability
            Navigator.of(context).pop();
          } : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  bool _canSave() {
    return selectedDay != null && startTime != null && endTime != null;
  }
}
