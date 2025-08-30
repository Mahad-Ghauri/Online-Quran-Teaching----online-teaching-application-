// Session Time Management Service
// Handles session timing validation and controls

import '../models/core_models.dart';

class SessionTimeService {
  /// Check if a session can be started based on current time
  static bool canStartSession(Booking booking) {
    if (booking.status != BookingStatus.confirmed) {
      return false;
    }

    final now = DateTime.now();
    final sessionStart = booking.slot.startTime;
    final sessionEnd = booking.slot.endTime;

    // Allow session to start 5 minutes before scheduled time
    final allowedStartTime = sessionStart.subtract(const Duration(minutes: 5));
    
    // Check if current time is within the allowed session window
    return now.isAfter(allowedStartTime) && now.isBefore(sessionEnd);
  }

  /// Check if a session is currently active (within the time window)
  static bool isSessionActive(Booking booking) {
    final now = DateTime.now();
    final sessionStart = booking.slot.startTime;
    final sessionEnd = booking.slot.endTime;

    return now.isAfter(sessionStart) && now.isBefore(sessionEnd);
  }

  /// Check if a session has ended
  static bool hasSessionEnded(Booking booking) {
    final now = DateTime.now();
    return now.isAfter(booking.slot.endTime);
  }

  /// Get time until session can start
  static Duration getTimeUntilStart(Booking booking) {
    final now = DateTime.now();
    final allowedStartTime = booking.slot.startTime.subtract(const Duration(minutes: 5));
    
    if (now.isAfter(allowedStartTime)) {
      return Duration.zero;
    }
    
    return allowedStartTime.difference(now);
  }

  /// Get remaining session time
  static Duration getRemainingTime(Booking booking) {
    final now = DateTime.now();
    final sessionEnd = booking.slot.endTime;
    
    if (now.isAfter(sessionEnd)) {
      return Duration.zero;
    }
    
    return sessionEnd.difference(now);
  }

  /// Get formatted status message for session
  static String getSessionStatusMessage(Booking booking, bool isQari) {
    final now = DateTime.now();
    final sessionStart = booking.slot.startTime;
    final sessionEnd = booking.slot.endTime;
    final allowedStartTime = sessionStart.subtract(const Duration(minutes: 5));

    if (booking.status != BookingStatus.confirmed) {
      return 'Session not confirmed yet';
    }

    if (now.isBefore(allowedStartTime)) {
      final timeUntilStart = allowedStartTime.difference(now);
      if (timeUntilStart.inDays > 0) {
        return 'Session starts in ${timeUntilStart.inDays} day(s)';
      } else if (timeUntilStart.inHours > 0) {
        return 'Session starts in ${timeUntilStart.inHours} hour(s)';
      } else {
        return 'Session starts in ${timeUntilStart.inMinutes} minute(s)';
      }
    }

    if (now.isAfter(sessionEnd)) {
      return 'Session has ended';
    }

    if (now.isAfter(allowedStartTime) && now.isBefore(sessionEnd)) {
      return isQari ? 'Ready to start teaching' : 'Ready to join session';
    }

    return 'Session not available';
  }

  /// Get formatted remaining time string
  static String getFormattedRemainingTime(Booking booking) {
    final remainingTime = getRemainingTime(booking);
    
    if (remainingTime == Duration.zero) {
      return 'Session Ended';
    }
    
    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m remaining';
    } else {
      return '${minutes}m remaining';
    }
  }

  /// Get warning message for time-based alerts
  static String? getWarningMessage(Booking booking) {
    final remainingTime = getRemainingTime(booking);
    
    if (remainingTime.inMinutes == 5) {
      return 'Session will end in 5 minutes';
    } else if (remainingTime.inMinutes == 1) {
      return 'Session will end in 1 minute';
    }
    
    return null;
  }

  /// Validate session timing before starting
  static SessionTimeValidation validateSessionTime(Booking booking) {
    final now = DateTime.now();
    final sessionStart = booking.slot.startTime;
    final sessionEnd = booking.slot.endTime;
    final allowedStartTime = sessionStart.subtract(const Duration(minutes: 5));

    if (booking.status != BookingStatus.confirmed) {
      return SessionTimeValidation(
        canStart: false,
        reason: 'Booking is not confirmed',
        severity: ValidationSeverity.error,
      );
    }

    if (now.isBefore(allowedStartTime)) {
      final timeUntil = allowedStartTime.difference(now);
      return SessionTimeValidation(
        canStart: false,
        reason: 'Session starts in ${_formatDuration(timeUntil)}',
        severity: ValidationSeverity.info,
      );
    }

    if (now.isAfter(sessionEnd)) {
      return SessionTimeValidation(
        canStart: false,
        reason: 'Session time has ended',
        severity: ValidationSeverity.error,
      );
    }

    // Session can start
    final remaining = sessionEnd.difference(now);
    if (remaining.inMinutes <= 5) {
      return SessionTimeValidation(
        canStart: true,
        reason: 'Session ending soon (${remaining.inMinutes}m left)',
        severity: ValidationSeverity.warning,
      );
    }

    return SessionTimeValidation(
      canStart: true,
      reason: 'Session ready to start',
      severity: ValidationSeverity.success,
    );
  }

  static String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day(s)';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour(s)';
    } else {
      return '${duration.inMinutes} minute(s)';
    }
  }
}

/// Session time validation result
class SessionTimeValidation {
  final bool canStart;
  final String reason;
  final ValidationSeverity severity;

  const SessionTimeValidation({
    required this.canStart,
    required this.reason,
    required this.severity,
  });
}

/// Validation severity levels
enum ValidationSeverity {
  success,
  info,
  warning,
  error,
}
