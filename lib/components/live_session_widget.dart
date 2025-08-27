// Live Session UI widget for starting/joining Agora video sessions
// Integrates with booking system for seamless experience

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import '../models/core_models.dart';
import 'agora_video_call_page.dart';

class LiveSessionWidget extends StatelessWidget {
  final Booking booking;
  final bool showJoinButton;
  final VoidCallback? onSessionStarted;

  const LiveSessionWidget({
    super.key,
    required this.booking,
    this.showJoinButton = true,
    this.onSessionStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.currentUser;
        if (currentUser == null) return const SizedBox.shrink();

        final bool isQari = currentUser.role == UserRole.qari;
        final bool canStartSession = _canStartSession(isQari);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade600, Colors.green.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 8,
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
                    Icons.video_call,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Live Session',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isQari 
                  ? 'Start a live teaching session'
                  : 'Join your scheduled session',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              if (showJoinButton && canStartSession)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _startSession(context, isQari),
                    icon: Icon(
                      isQari ? Icons.play_arrow : Icons.video_call,
                      color: Colors.green.shade800,
                    ),
                    label: Text(
                      isQari ? 'Start Teaching' : 'Join Session',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  bool _canStartSession(bool isQari) {
    // For now, allow sessions if booking is confirmed
    return booking.status == BookingStatus.confirmed;
  }

  void _startSession(BuildContext context, bool isQari) {
    try {
      // Navigate to Agora video call page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AgoraVideoCallPage(
            bookingId: booking.id,
            isQari: isQari,
            booking: booking,
          ),
        ),
      );

      // Call callback if provided
      onSessionStarted?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start session: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Simplified Quick Session Button for easy integration
class QuickSessionButton extends StatelessWidget {
  final Booking booking;
  final String label;
  final IconData? icon;
  final VoidCallback? onSessionStarted;

  const QuickSessionButton({
    super.key,
    required this.booking,
    this.label = 'Start Session',
    this.icon,
    this.onSessionStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.currentUser;
        if (currentUser == null) return const SizedBox.shrink();

        final bool isQari = currentUser.role == UserRole.qari;
        
        return ElevatedButton.icon(
          onPressed: booking.status == BookingStatus.confirmed 
            ? () => _startQuickSession(context, isQari)
            : null,
          icon: Icon(icon ?? Icons.video_call),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      },
    );
  }

  void _startQuickSession(BuildContext context, bool isQari) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgoraVideoCallPage(
          bookingId: booking.id,
          isQari: isQari,
          booking: booking,
        ),
      ),
    );
    
    // Call callback if provided
    onSessionStarted?.call();
  }
}
