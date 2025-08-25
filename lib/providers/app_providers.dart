// State management providers for QariConnect app
// Uses Provider pattern for reactive state management

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/core_models.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Authentication state provider
class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isQari => _currentUser?.role.isQari ?? false;
  bool get isStudent => _currentUser?.role.isStudent ?? false;
  bool get isAdmin => _currentUser?.role.isAdmin ?? false;
  bool get isVerified => _currentUser?.isVerified ?? false;

  /// Initialize auth state
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        _currentUser = await AuthService.getCurrentUserProfile();
      }
      _clearError();
    } catch (e) {
      _setError('Failed to initialize auth: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sign up new user
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await AuthService.signUpWithModel(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in existing user
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await AuthService.signInWithModel(
        email: email,
        password: password,
      );
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await AuthService.signOut();
      _currentUser = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await AuthService.sendPasswordResetEmail(email);
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    if (_currentUser == null) return false;
    
    _setLoading(true);
    try {
      await FirestoreService.updateUserProfile(_currentUser!.id, updates);
      
      // Update local user model
      if (updates.containsKey('name')) {
        _currentUser = _currentUser!.copyWith(name: updates['name']);
      }
      if (updates.containsKey('isVerified')) {
        _currentUser = _currentUser!.copyWith(isVerified: updates['isVerified']);
      }
      
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all state
  void clear() {
    _currentUser = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}

/// Qari profiles state provider
class QariProvider extends ChangeNotifier {
  List<QariProfile> _verifiedQaris = [];
  QariProfile? _currentQariProfile;
  bool _isLoading = false;
  String? _error;
  
  // Stream subscriptions for real-time updates
  StreamSubscription<List<QariProfile>>? _verifiedQarisSubscription;
  StreamSubscription<QariProfile?>? _currentQariProfileSubscription;

  List<QariProfile> get verifiedQaris => _verifiedQaris;
  QariProfile? get currentQariProfile => _currentQariProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Start listening to verified Qaris in real-time
  void startListeningToVerifiedQaris() {
    print('DEBUG: QariProvider - startListeningToVerifiedQaris called');
    _setLoading(true);
    _verifiedQarisSubscription?.cancel();
    
    _verifiedQarisSubscription = FirestoreService.listenToVerifiedQaris().listen(
      (qaris) {
        print('DEBUG: QariProvider - Received ${qaris.length} qaris from stream');
        _verifiedQaris = qaris;
        _clearError();
        _setLoading(false);
        notifyListeners();
      },
      onError: (error) {
        print('DEBUG: QariProvider - Stream error: $error');
        _setError('Failed to load Qaris: $error');
        _setLoading(false);
      },
    );
  }

  /// Start listening to current Qari profile in real-time
  void startListeningToCurrentQariProfile(String qariId) {
    _currentQariProfileSubscription?.cancel();
    
    _currentQariProfileSubscription = FirestoreService.listenToQariProfile(qariId).listen(
      (profile) {
        _currentQariProfile = profile;
        _clearError();
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to load Qari profile: $error');
      },
    );
  }

  /// Stop listening to real-time updates
  void stopListening() {
    _verifiedQarisSubscription?.cancel();
    _currentQariProfileSubscription?.cancel();
    _verifiedQarisSubscription = null;
    _currentQariProfileSubscription = null;
  }

  /// Load all verified Qaris for students (fallback method)
  Future<void> loadVerifiedQaris() async {
    _setLoading(true);
    try {
      _verifiedQaris = await FirestoreService.getVerifiedQaris();
      _clearError();
    } catch (e) {
      _setError('Failed to load Qaris: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load current user's Qari profile (fallback method)
  Future<void> loadCurrentQariProfile(String qariId) async {
    _setLoading(true);
    try {
      _currentQariProfile = await FirestoreService.getQariProfile(qariId);
      _clearError();
    } catch (e) {
      _setError('Failed to load Qari profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }

  /// Create or update Qari profile
  Future<bool> saveQariProfile(QariProfile profile) async {
    _setLoading(true);
    try {
      final existingProfile = await FirestoreService.getQariProfile(profile.qariId);
      
      if (existingProfile == null) {
        await FirestoreService.createQariProfile(profile);
      } else {
        await FirestoreService.updateQariProfile(profile.qariId, profile.toFirestore());
      }
      
      _currentQariProfile = profile;
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get Qari by ID
  QariProfile? getQariById(String qariId) {
    try {
      return _verifiedQaris.firstWhere((qari) => qari.qariId == qariId);
    } catch (e) {
      return null;
    }
  }

  /// Search Qaris by name or bio
  List<QariProfile> searchQaris(String query) {
    if (query.isEmpty) return _verifiedQaris;
    
    final lowerQuery = query.toLowerCase();
    return _verifiedQaris.where((qari) {
      return qari.bio.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filter Qaris by rating
  List<QariProfile> filterByRating(double minRating) {
    return _verifiedQaris.where((qari) => qari.rating >= minRating).toList();
  }

  /// Filter Qaris by price range
  List<QariProfile> filterByPriceRange(double minPrice, double maxPrice) {
    return _verifiedQaris.where((qari) {
      return qari.pricing >= minPrice && qari.pricing <= maxPrice;
    }).toList();
  }

  /// Sort Qaris by different criteria
  List<QariProfile> sortQaris(QariSortOption sortOption) {
    final List<QariProfile> sortedList = List.from(_verifiedQaris);
    
    switch (sortOption) {
      case QariSortOption.rating:
        sortedList.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case QariSortOption.priceLowToHigh:
        sortedList.sort((a, b) => a.pricing.compareTo(b.pricing));
        break;
      case QariSortOption.priceHighToLow:
        sortedList.sort((a, b) => b.pricing.compareTo(a.pricing));
        break;
    }
    
    return sortedList;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Bookings state provider
class BookingProvider extends ChangeNotifier {
  List<Booking> _userBookings = [];
  List<Booking> _upcomingBookings = [];
  bool _isLoading = false;
  String? _error;
  
  // Stream subscriptions for real-time updates
  StreamSubscription<List<Booking>>? _userBookingsSubscription;

  List<Booking> get userBookings => _userBookings;
  List<Booking> get upcomingBookings => _upcomingBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Start listening to user bookings in real-time
  void startListeningToUserBookings(String userId, UserRole role) {
    _setLoading(true);
    _userBookingsSubscription?.cancel();
    
    _userBookingsSubscription = FirestoreService.listenToUserBookings(userId, role).listen(
      (bookings) {
        _userBookings = bookings;
        _upcomingBookings = bookings.where((booking) {
          return booking.slot.startTime.isAfter(DateTime.now()) && 
                 booking.status == BookingStatus.confirmed;
        }).toList();
        _clearError();
        _setLoading(false);
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to load bookings: $error');
        _setLoading(false);
      },
    );
  }

  /// Stop listening to real-time updates
  void stopListening() {
    _userBookingsSubscription?.cancel();
    _userBookingsSubscription = null;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }

  /// Load bookings for current user
  Future<void> loadUserBookings(String userId, UserRole role) async {
    _setLoading(true);
    try {
      if (role.isStudent) {
        _userBookings = await FirestoreService.getStudentBookings(userId);
      } else if (role.isQari) {
        _userBookings = await FirestoreService.getQariBookings(userId);
      }
      _clearError();
    } catch (e) {
      _setError('Failed to load bookings: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load upcoming bookings
  Future<void> loadUpcomingBookings(String userId, UserRole role) async {
    _setLoading(true);
    try {
      _upcomingBookings = await FirestoreService.getUpcomingBookings(userId, role);
      _clearError();
    } catch (e) {
      _setError('Failed to load upcoming bookings: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create new booking
  Future<bool> createBooking(Booking booking) async {
    _setLoading(true);
    try {
      // Check slot availability
      final isAvailable = await FirestoreService.isSlotAvailable(
        booking.qariId,
        booking.slot,
      );
      
      if (!isAvailable) {
        _setError('This time slot is no longer available');
        return false;
      }

      final bookingId = await FirestoreService.createBooking(booking);
      
      // Add to local list
      final newBooking = booking.copyWith(id: bookingId);
      _userBookings.insert(0, newBooking);
      
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update booking status
  Future<bool> updateBookingStatus(String bookingId, BookingStatus status) async {
    _setLoading(true);
    try {
      await FirestoreService.updateBookingStatus(bookingId, status);
      
      // Update local list
      final index = _userBookings.indexWhere((booking) => booking.id == bookingId);
      if (index != -1) {
        _userBookings[index] = _userBookings[index].copyWith(status: status);
      }
      
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get bookings by status
  List<Booking> getBookingsByStatus(BookingStatus status) {
    return _userBookings.where((booking) => booking.status == status).toList();
  }

  /// Get booking by ID
  Booking? getBookingById(String bookingId) {
    try {
      return _userBookings.firstWhere((booking) => booking.id == bookingId);
    } catch (e) {
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Reviews state provider
class ReviewProvider extends ChangeNotifier {
  List<Review> _qariReviews = [];
  List<Review> _userReviews = [];
  bool _isLoading = false;
  String? _error;

  List<Review> get qariReviews => _qariReviews;
  List<Review> get userReviews => _userReviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load reviews for a Qari
  Future<void> loadQariReviews(String qariId) async {
    _setLoading(true);
    try {
      _qariReviews = await FirestoreService.getQariReviews(qariId);
      _clearError();
    } catch (e) {
      _setError('Failed to load reviews: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load reviews by current user
  Future<void> loadUserReviews(String userId) async {
    _setLoading(true);
    try {
      _userReviews = await FirestoreService.getStudentReviews(userId);
      _clearError();
    } catch (e) {
      _setError('Failed to load user reviews: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create new review
  Future<bool> createReview(Review review) async {
    _setLoading(true);
    try {
      await FirestoreService.createReview(review);
      
      // Add to local lists
      _qariReviews.insert(0, review);
      _userReviews.insert(0, review);
      
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Calculate average rating for a Qari
  double getAverageRating(String qariId) {
    final reviews = _qariReviews.where((review) => review.qariId == qariId).toList();
    if (reviews.isEmpty) return 0.0;
    
    final totalRating = reviews.map((review) => review.rating).reduce((a, b) => a + b);
    return totalRating / reviews.length;
  }

  /// Get rating distribution for a Qari
  Map<int, int> getRatingDistribution(String qariId) {
    final reviews = _qariReviews.where((review) => review.qariId == qariId).toList();
    final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    
    for (final review in reviews) {
      distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
    }
    
    return distribution;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Enum for Qari sorting options
enum QariSortOption {
  rating,
  priceLowToHigh,
  priceHighToLow,
}
