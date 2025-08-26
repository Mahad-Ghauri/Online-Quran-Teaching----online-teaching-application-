// Firebase Firestore service for QariConnect app
// Handles all CRUD operations for core models

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/core_models.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  static const String _usersCollection = 'users';
  static const String _qariProfilesCollection = 'qariProfiles';
  static const String _bookingsCollection = 'bookings';
  static const String _reviewsCollection = 'reviews';
  static const String _adminLogsCollection = 'adminLogs';

  // User operations
  static CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(_usersCollection);

  /// Create user profile in Firestore after Firebase Auth signup
  static Future<void> createUserProfile(UserModel user) async {
    try {
      final userData = user.toFirestore();
      
      // Ensure isVerified field is explicitly included
      userData['isVerified'] = user.isVerified;
      
      await _users.doc(user.id).set(userData);
      
      // Verify the document was created correctly
      final createdDoc = await _users.doc(user.id).get();
      if (!createdDoc.exists) {
        throw Exception('User document was not created');
      }
      
      final data = createdDoc.data() as Map<String, dynamic>;
      if (!data.containsKey('isVerified')) {
        // Force add isVerified field if somehow missing
        await _users.doc(user.id).update({'isVerified': user.isVerified});
      }
      
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Get user profile by ID
  static Future<UserModel?> getUserProfile(String userId) async {
    try {
      print('DEBUG: FirestoreService - Getting user profile for ID: $userId');
      final doc = await _users.doc(userId).get();
      if (doc.exists) {
        final userData = doc.data() as Map<String, dynamic>;
        print('DEBUG: FirestoreService - Found user document: ${userData['name']} (${userData['role']})');
        return UserModel.fromFirestore(doc);
      } else {
        print('DEBUG: FirestoreService - No document found for user ID: $userId');
      }
      return null;
    } catch (e) {
      print('DEBUG: FirestoreService - Error getting user profile: $e');
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Get all users (Admin only)
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _users.get();
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all users: $e');
    }
  }

  /// Get current user profile
  static Future<UserModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await getUserProfile(user.uid);
    }
    return null;
  }

  /// Update user profile
  static Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      await _users.doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Verify a Qari (Admin only)
  static Future<void> verifyQari(String qariId) async {
    try {
      await _users.doc(qariId).update({'isVerified': true});
      
      // Log admin action
      await createAdminLog(AdminLog(
        id: '',
        action: 'verifyQari',
        performedBy: _auth.currentUser?.uid ?? '',
        timestamp: DateTime.now(),
        metadata: {'qariId': qariId},
      ));
    } catch (e) {
      throw Exception('Failed to verify Qari: $e');
    }
  }

  // QariProfile operations
  static CollectionReference<Map<String, dynamic>> get _qariProfiles =>
      _firestore.collection(_qariProfilesCollection);

  /// Create Qari profile
  static Future<void> createQariProfile(QariProfile profile) async {
    try {
      await _qariProfiles.doc(profile.qariId).set(profile.toFirestore());
    } catch (e) {
      throw Exception('Failed to create Qari profile: $e');
    }
  }

  /// Get Qari profile by ID
  static Future<QariProfile?> getQariProfile(String qariId) async {
    try {
      final doc = await _qariProfiles.doc(qariId).get();
      if (doc.exists) {
        return QariProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get Qari profile: $e');
    }
  }

  /// Get all verified Qaris for students
  static Future<List<QariProfile>> getVerifiedQaris() async {
    try {
      // First get all verified users with role=qari
      final verifiedQariUsers = await _users
          .where('role', isEqualTo: 'qari')
          .where('isVerified', isEqualTo: true)
          .get();

      final List<QariProfile> qariProfiles = [];
      
      for (final userDoc in verifiedQariUsers.docs) {
        final qariProfile = await getQariProfile(userDoc.id);
        if (qariProfile != null) {
          qariProfiles.add(qariProfile);
        }
      }

      return qariProfiles;
    } catch (e) {
      throw Exception('Failed to get verified Qaris: $e');
    }
  }

  /// Update Qari profile
  static Future<void> updateQariProfile(String qariId, Map<String, dynamic> updates) async {
    try {
      await _qariProfiles.doc(qariId).update(updates);
    } catch (e) {
      throw Exception('Failed to update Qari profile: $e');
    }
  }

  /// Update Qari rating after new review
  static Future<void> updateQariRating(String qariId) async {
    try {
      final reviews = await getQariReviews(qariId);
      if (reviews.isNotEmpty) {
        final averageRating = reviews
            .map((review) => review.rating)
            .reduce((a, b) => a + b) / reviews.length;
        
        await updateQariProfile(qariId, {'rating': averageRating});
      }
    } catch (e) {
      throw Exception('Failed to update Qari rating: $e');
    }
  }

  // Booking operations
  static CollectionReference<Map<String, dynamic>> get _bookings =>
      _firestore.collection(_bookingsCollection);

  /// Create a new booking
  static Future<String> createBooking(Booking booking) async {
    try {
      final docRef = await _bookings.add(booking.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  /// Get booking by ID
  static Future<Booking?> getBooking(String bookingId) async {
    try {
      final doc = await _bookings.doc(bookingId).get();
      if (doc.exists) {
        return Booking.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }

  /// Get bookings for a student
  static Future<List<Booking>> getStudentBookings(String studentId) async {
    try {
      final querySnapshot = await _bookings
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Booking.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get student bookings: $e');
    }
  }

  /// Get bookings for a Qari
  static Future<List<Booking>> getQariBookings(String qariId) async {
    try {
      final querySnapshot = await _bookings
          .where('qariId', isEqualTo: qariId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Booking.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get Qari bookings: $e');
    }
  }

  /// Update booking status
  static Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      await _bookings.doc(bookingId).update({
        'status': status.name.toLowerCase(),
      });
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  /// Get upcoming bookings for a user
  static Future<List<Booking>> getUpcomingBookings(String userId, UserRole role) async {
    try {
      final field = role.isStudent ? 'studentId' : 'qariId';
      final querySnapshot = await _bookings
          .where(field, isEqualTo: userId)
          .where('status', isEqualTo: 'confirmed')
          .get();

      final bookings = querySnapshot.docs
          .map((doc) => Booking.fromFirestore(doc))
          .where((booking) => booking.slot.startTime.isAfter(DateTime.now()))
          .toList();

      bookings.sort((a, b) => a.slot.startTime.compareTo(b.slot.startTime));
      return bookings;
    } catch (e) {
      throw Exception('Failed to get upcoming bookings: $e');
    }
  }

  // Review operations
  static CollectionReference<Map<String, dynamic>> get _reviews =>
      _firestore.collection(_reviewsCollection);

  /// Create a review (only for completed bookings)
  static Future<void> createReview(Review review) async {
    try {
      // Verify the booking exists and is completed
      final bookings = await _bookings
          .where('studentId', isEqualTo: review.studentId)
          .where('qariId', isEqualTo: review.qariId)
          .where('status', isEqualTo: 'completed')
          .get();

      if (bookings.docs.isEmpty) {
        throw Exception('No completed booking found between student and Qari');
      }

      await _reviews.add(review.toFirestore());
      
      // Update Qari's average rating
      await updateQariRating(review.qariId);
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  /// Get reviews for a Qari
  static Future<List<Review>> getQariReviews(String qariId) async {
    try {
      final querySnapshot = await _reviews
          .where('qariId', isEqualTo: qariId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Review.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get Qari reviews: $e');
    }
  }

  /// Get reviews by a student
  static Future<List<Review>> getStudentReviews(String studentId) async {
    try {
      final querySnapshot = await _reviews
          .where('studentId', isEqualTo: studentId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Review.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get student reviews: $e');
    }
  }

  // Admin operations
  static CollectionReference<Map<String, dynamic>> get _adminLogs =>
      _firestore.collection(_adminLogsCollection);

  /// Create admin log entry
  static Future<void> createAdminLog(AdminLog log) async {
    try {
      await _adminLogs.add(log.toFirestore());
    } catch (e) {
      throw Exception('Failed to create admin log: $e');
    }
  }

  /// Get admin logs
  static Future<List<AdminLog>> getAdminLogs({int limit = 50}) async {
    try {
      final querySnapshot = await _adminLogs
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => AdminLog.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get admin logs: $e');
    }
  }

  /// Get unverified Qaris (Admin only)
  static Future<List<UserModel>> getUnverifiedQaris() async {
    try {
      final querySnapshot = await _users
          .where('role', isEqualTo: 'qari')
          .where('isVerified', isEqualTo: false)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get unverified Qaris: $e');
    }
  }

  // Real-time listeners
  /// Listen to user profile changes
  static Stream<UserModel?> listenToUserProfile(String userId) {
    return _users.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromFirestore(snapshot);
      }
      return null;
    });
  }

  /// Listen to Qari profile changes
  static Stream<QariProfile?> listenToQariProfile(String qariId) {
    print('DEBUG: FirestoreService.listenToQariProfile - Looking for qariId: $qariId');
    return _qariProfiles.doc(qariId).snapshots().map((snapshot) {
      print('DEBUG: FirestoreService.listenToQariProfile - Snapshot exists: ${snapshot.exists} for qariId: $qariId');
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        print('DEBUG: FirestoreService.listenToQariProfile - Found qari profile data: $data');
        return QariProfile.fromFirestore(snapshot);
      }
      print('DEBUG: FirestoreService.listenToQariProfile - No qari profile found for qariId: $qariId');
      return null;
    });
  }

  /// Listen to booking changes for a user
  static Stream<List<Booking>> listenToUserBookings(String userId, UserRole role) {
    final field = role.isStudent ? 'studentId' : 'qariId';
    return _bookings
        .where(field, isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromFirestore(doc))
            .toList());
  }

  /// Listen to verified Qaris
  static Stream<List<QariProfile>> listenToVerifiedQaris() {
    print('DEBUG: Starting listenToVerifiedQaris');
    print('DEBUG: Querying collection: $_qariProfilesCollection');
    
    // First, let's also check what users exist
    _users.get().then((snapshot) {
      print('DEBUG: Found ${snapshot.docs.length} users total');
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('DEBUG: User ${doc.id}: role=${data['role']}, isVerified=${data['isVerified']}, name=${data['name'] ?? 'unnamed'}');
      }
    });
    
    return _qariProfiles.snapshots().asyncMap((snapshot) async {
      print('DEBUG: QariProfiles snapshot received - ${snapshot.docs.length} documents');
      final List<QariProfile> verifiedProfiles = [];
      
      for (final doc in snapshot.docs) {
        print('DEBUG: Processing QariProfile document: ${doc.id}');
        final profile = QariProfile.fromFirestore(doc);
        
        // Check if the Qari is verified
        final userDoc = await _users.doc(profile.qariId).get();
        if (userDoc.exists) {
          final user = UserModel.fromFirestore(userDoc);
          print('DEBUG: User ${user.name} - isVerified: ${user.isVerified}, role: ${user.role}');
          if (user.isVerified && user.role.isQari) {
            verifiedProfiles.add(profile);
            print('DEBUG: Added verified Qari: ${user.name}');
          }
        } else {
          print('DEBUG: User document not found for qariId: ${profile.qariId}');
        }
      }
      
      print('DEBUG: Returning ${verifiedProfiles.length} verified Qaris');
      return verifiedProfiles;
    });
  }

  // Utility methods
  /// Check if a time slot is available for a Qari
  static Future<bool> isSlotAvailable(String qariId, TimeSlot slot) async {
    try {
      final existingBookings = await _bookings
          .where('qariId', isEqualTo: qariId)
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      for (final doc in existingBookings.docs) {
        final booking = Booking.fromFirestore(doc);
        if (booking.slot.overlapsWith(slot)) {
          return false;
        }
      }
      return true;
    } catch (e) {
      throw Exception('Failed to check slot availability: $e');
    }
  }

  /// Delete user account and all related data
  static Future<void> deleteUserAccount(String userId) async {
    final batch = _firestore.batch();

    try {
      // Delete user profile
      batch.delete(_users.doc(userId));

      // Delete Qari profile if exists
      final qariProfile = await _qariProfiles.doc(userId).get();
      if (qariProfile.exists) {
        batch.delete(_qariProfiles.doc(userId));
      }

      // Cancel all bookings
      final userBookings = await _bookings
          .where('studentId', isEqualTo: userId)
          .get();
      
      final qariBookings = await _bookings
          .where('qariId', isEqualTo: userId)
          .get();

      for (final doc in [...userBookings.docs, ...qariBookings.docs]) {
        batch.update(doc.reference, {'status': 'cancelled'});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete user account: $e');
    }
  }
}
