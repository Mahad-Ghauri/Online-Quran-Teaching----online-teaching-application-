import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentBookingsPage extends StatelessWidget {
  const StudentBookingsPage({super.key});

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
              const Color(0xFFF39C12).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.book,
                size: 80,
                color: const Color(0xFFF39C12),
              ),
              const SizedBox(height: 20),
              Text(
                'My Bookings',
                style: GoogleFonts.merriweather(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF39C12),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'List of all student\'s bookings\nFilter by status (Upcoming, Completed, Cancelled)\nJoin button for Jitsi session when booking is live\nPayment history and status tracking',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF39C12).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF39C12).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'Booking Management & Payments',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFFF39C12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
