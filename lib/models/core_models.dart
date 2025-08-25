// Core data models for QariConnect app
// Based on Firebase Firestore structure

import 'package:cloud_firestore/cloud_firestore.dart';

/// User model - corresponds to Firebase Auth + Firestore users collection
class UserModel {
  final String id; // Firebase Auth UID
  final String name;
  final String email;
  final String? phone; // Optional phone number
  final UserRole role;
  final bool isVerified;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.isVerified,
    required this.createdAt,
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'], // Optional field
      role: UserRole.values.firstWhere(
        (role) => role.name.toLowerCase() == (data['role'] ?? '').toLowerCase(),
        orElse: () => UserRole.student,
      ),
      isVerified: data['isVerified'] ?? false, // Default to false if missing
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert UserModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone, // Include phone if provided
      'role': role.name.toLowerCase(),
      'isVerified': isVerified, // Always include this field
      'createdAt': Timestamp.fromDate(createdAt),
      'uid': id, // Include uid field as you mentioned seeing it
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Qari Profile model - corresponds to qariProfiles collection
class QariProfile {
  final String qariId; // Reference to User.id
  final String bio;
  final List<String> certificates; // URLs to certificate documents
  final List<TimeSlot> availableSlots;
  final double pricing; // Per-session fee
  final double rating; // Average rating from reviews

  const QariProfile({
    required this.qariId,
    required this.bio,
    required this.certificates,
    required this.availableSlots,
    required this.pricing,
    required this.rating,
  });

  /// Create QariProfile from Firestore document
  factory QariProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QariProfile(
      qariId: doc.id,
      bio: data['bio'] ?? '',
      certificates: List<String>.from(data['certificates'] ?? []),
      availableSlots: (data['availableSlots'] as List<dynamic>?)
          ?.map((slot) => TimeSlot.fromMap(slot as Map<String, dynamic>))
          .toList() ?? [],
      pricing: (data['pricing'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0.0).toDouble(),
    );
  }

  /// Convert QariProfile to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'bio': bio,
      'certificates': certificates,
      'availableSlots': availableSlots.map((slot) => slot.toMap()).toList(),
      'pricing': pricing,
      'rating': rating,
    };
  }

  /// Create a copy with updated fields
  QariProfile copyWith({
    String? qariId,
    String? bio,
    List<String>? certificates,
    List<TimeSlot>? availableSlots,
    double? pricing,
    double? rating,
  }) {
    return QariProfile(
      qariId: qariId ?? this.qariId,
      bio: bio ?? this.bio,
      certificates: certificates ?? this.certificates,
      availableSlots: availableSlots ?? this.availableSlots,
      pricing: pricing ?? this.pricing,
      rating: rating ?? this.rating,
    );
  }
}

/// Booking model - corresponds to bookings collection
class Booking {
  final String id;
  final String studentId; // Reference to User.id
  final String qariId; // Reference to User.id
  final TimeSlot slot;
  final BookingStatus status;
  final double price; // Fetched from QariProfile.pricing at booking time
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.studentId,
    required this.qariId,
    required this.slot,
    required this.status,
    required this.price,
    required this.createdAt,
  });

  /// Create Booking from Firestore document
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      qariId: data['qariId'] ?? '',
      slot: TimeSlot.fromMap(data['slot'] as Map<String, dynamic>),
      status: BookingStatus.values.firstWhere(
        (status) => status.name.toLowerCase() == (data['status'] ?? '').toLowerCase(),
        orElse: () => BookingStatus.pending,
      ),
      price: (data['price'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert Booking to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'qariId': qariId,
      'slot': slot.toMap(),
      'status': status.name.toLowerCase(),
      'price': price,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with updated fields
  Booking copyWith({
    String? id,
    String? studentId,
    String? qariId,
    TimeSlot? slot,
    BookingStatus? status,
    double? price,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      qariId: qariId ?? this.qariId,
      slot: slot ?? this.slot,
      status: status ?? this.status,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Review model - corresponds to reviews collection
class Review {
  final String id;
  final String studentId; // Reference to User.id
  final String qariId; // Reference to User.id
  final int rating; // 1-5 stars
  final String comment;
  final DateTime timestamp;

  const Review({
    required this.id,
    required this.studentId,
    required this.qariId,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  /// Create Review from Firestore document
  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      qariId: data['qariId'] ?? '',
      rating: data['rating'] ?? 1,
      comment: data['comment'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert Review to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'qariId': qariId,
      'rating': rating,
      'comment': comment,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Create a copy with updated fields
  Review copyWith({
    String? id,
    String? studentId,
    String? qariId,
    int? rating,
    String? comment,
    DateTime? timestamp,
  }) {
    return Review(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      qariId: qariId ?? this.qariId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// AdminLog model - corresponds to adminLogs collection
class AdminLog {
  final String id;
  final String action; // verifyQari, suspendUser, etc.
  final String performedBy; // Admin User ID
  final DateTime timestamp;
  final Map<String, dynamic>? metadata; // Additional context data

  const AdminLog({
    required this.id,
    required this.action,
    required this.performedBy,
    required this.timestamp,
    this.metadata,
  });

  /// Create AdminLog from Firestore document
  factory AdminLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminLog(
      id: doc.id,
      action: data['action'] ?? '',
      performedBy: data['performedBy'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert AdminLog to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'action': action,
      'performedBy': performedBy,
      'timestamp': Timestamp.fromDate(timestamp),
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Time slot helper class
class TimeSlot {
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;

  const TimeSlot({
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  /// Create TimeSlot from Map
  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      date: (map['date'] as Timestamp).toDate(),
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
    );
  }

  /// Convert TimeSlot to Map
  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
    };
  }

  /// Check if this slot overlaps with another
  bool overlapsWith(TimeSlot other) {
    return startTime.isBefore(other.endTime) && endTime.isAfter(other.startTime);
  }

  /// Duration of the slot
  Duration get duration => endTime.difference(startTime);
}

/// Enums
enum UserRole {
  student,
  qari,
  admin,
}

enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

/// Extension methods for enums
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.qari:
        return 'Qari';
      case UserRole.admin:
        return 'Admin';
    }
  }

  bool get isQari => this == UserRole.qari;
  bool get isStudent => this == UserRole.student;
  bool get isAdmin => this == UserRole.admin;
}

extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isActive => this == BookingStatus.confirmed;
  bool get isPending => this == BookingStatus.pending;
  bool get isCompleted => this == BookingStatus.completed;
  bool get isCancelled => this == BookingStatus.cancelled;
}
