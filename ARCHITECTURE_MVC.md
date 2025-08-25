# Qari Learning App — MVC Architectural Plan

This document defines a pragmatic MVC architecture for the app using Flutter + Firebase + Provider + go_router.

- **Model**: Pure data classes + repositories (data access) + services (external integrations)
- **View**: Flutter UI widgets (screens), listens to Controllers via Provider
- **Controller**: ChangeNotifier classes holding UI state & orchestration logic; they invoke repositories/services and update state

## 1) Folder Structure
```
lib/
  app/
    app.dart            // MaterialApp + GoRouter bootstrap
    router.dart         // Routes + redirection guards
    di.dart             // Provider wiring (dependency injection)
  core/
    constants/          // strings, styles, keys
    errors/             // AppException, failures
    utils/              // formatters, validators
    widgets/            // reusable UI components
  domain/
    models/             // Student, Qari, Booking, Payment, TimeSlot
    value_objects/      // (optional) strongly-typed small objects
  data/
    datasources/
      firebase/         // firestore.dart, storage.dart, functions.dart
    repositories/
      interfaces/       // IAuthRepository, IBookingRepository, etc.
      impl/             // FirebaseAuthRepository, FirestoreBookingRepository...
    services/           // PayFastService, LiveSessionService (WebRTC/Jitsi/Agora)
  controllers/
    auth_controller.dart
    student_controller.dart
    qari_controller.dart
    availability_controller.dart
    booking_controller.dart
    payment_controller.dart
    admin_controller.dart
  presentation/         // Views (Widgets)
    shared/
      splash_page.dart
      role_selection_page.dart
      login_page.dart
      profile_page.dart
    student/
      dashboard_page.dart
      qari_search_page.dart
      qari_detail_page.dart
      booking_create_page.dart
      bookings_list_page.dart
    qari/
      dashboard_page.dart
      verification_pending_page.dart
      availability_editor_page.dart
      payouts_page.dart
    admin/
      dashboard_page.dart
      verification_queue_page.dart
      payments_page.dart
      reports_page.dart
      bookings_page.dart
```

## 2) Responsibilities
- **Models (domain/models)**: Immutable data, serialization (from/to Firestore JSON)
- **Repositories (data/repositories)**: CRUD to Firestore/Storage/Functions; return domain models
- **Services (data/services)**: External systems (PayFast, WebRTC/Jitsi/Agora)
- **Controllers**: Orchestrate flows, manage UI state, call repositories/services, expose state to Views
- **Views (presentation)**: Render UI, dispatch user intents to Controllers, observe state via Provider

## 3) Key Controllers and Their Duties
- **AuthController**: login/signup, role resolution, user profile bootstrap
- **StudentController**: browse Qaris, filters, student profile updates
- **QariController**: Qari profile, verification docs upload, verified flag handling
- **AvailabilityController**: CRUD availability TimeSlots, conflict checks
- **BookingController**: create/confirm/cancel/complete bookings, session lifecycle hooks
- **PaymentController**: initiate PayFast, compute commission, handle IPN notifications (via Functions), payout status
- **AdminController**: verify/reject Qaris, view entities, reports, payouts

## 4) Data Flow (Typical Use Cases)
1) Student books session
- View → BookingController.createPendingBooking()
- Controller → BookingRepository.createPending()
- Controller → PaymentController.startPayment()
- PayFast callback/IPN → Cloud Function → PaymentsRepository.updateSuccess() + BookingRepository.confirm()
- Controller notifies View → show confirmation

2) Qari verification
- Qari View → QariController.submitDocs()
- Controller → Storage upload, VerificationsRepository.submit()
- Admin View → AdminController.approve(qariId)
- Controller → QariRepository.setVerified(true) → Qari becomes searchable

## 5) Interfaces (Repositories) — Sketch
```dart
abstract class IAuthRepository {
  Future<String?> currentUserId();
  Future<void> signOut();
  Future<String> signInWithEmail(String email, String password);
  Future<String> signUpWithEmail(String email, String password);
}

abstract class IProfileRepository {
  Future<Student?> getStudent(String id);
  Future<Qari?> getQari(String id);
  Future<void> saveStudent(Student s);
  Future<void> saveQari(Qari q);
}

abstract class IBookingRepository {
  Future<Booking> createPending(Booking booking);
  Future<void> confirm(String bookingId);
  Future<void> cancel(String bookingId);
  Stream<List<Booking>> watchByUser(String userId, {required bool isQari});
}

abstract class IPaymentsRepository {
  Future<Payment> createPayment(Payment p);
  Future<void> updateStatus(String paymentId, String status);
  Stream<List<Payment>> watchByUser(String userId);
}

abstract class IQariRepository {
  Future<List<Qari>> search({List<String>? subjects, List<String>? languages});
  Future<void> setVerified(String qariId, bool verified);
  Future<void> updateAvailability(String qariId, List<TimeSlot> slots);
}
```

## 6) Controllers (ChangeNotifier) — Sketch
```dart
import 'package:flutter/foundation.dart';
import '../domain/models/booking.dart';
import '../domain/models/qari.dart';
import '../data/repositories/interfaces/booking_repository.dart';

class BookingController extends ChangeNotifier {
  final IBookingRepository bookingRepo;
  bool loading = false;
  String? error;

  BookingController(this.bookingRepo);

  Future<void> createPendingBooking(Booking booking) async {
    loading = true; error = null; notifyListeners();
    try {
      await bookingRepo.createPending(booking);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false; notifyListeners();
    }
  }
}
```

## 7) Provider Wiring (DI)
```dart
// lib/app/di.dart
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import '../controllers/booking_controller.dart';
import '../data/repositories/impl/firestore_booking_repository.dart';

List<SingleChildWidget> buildProviders() => [
  Provider(create: (_) => FirestoreBookingRepository()),
  ChangeNotifierProvider(create: (ctx) => BookingController(ctx.read<FirestoreBookingRepository>())),
  // ... other repositories + controllers
];
```

## 8) Router and Guards (go_router)
```dart
// lib/app/router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../presentation/shared/splash_page.dart';

GoRouter buildRouter(BuildContext context) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (ctx, state) {
      final auth = ctx.read<AuthController>();
      // Example: route based on role & verification
      // return '/role' or '/student/dashboard' etc.
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      // Student
      // Qari
      // Admin
    ],
  );
}
```

## 9) View Usage Example
```dart
// presentation/student/booking_create_page.dart
class BookingCreatePage extends StatelessWidget {
  const BookingCreatePage({super.key});
  @override
  Widget build(BuildContext context) {
    final bookingCtrl = context.watch<BookingController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create Booking')),
      body: Column(
        children: [
          if (bookingCtrl.loading) const LinearProgressIndicator(),
          if (bookingCtrl.error != null) Text(bookingCtrl.error!, style: const TextStyle(color: Colors.red)),
          ElevatedButton(
            onPressed: () {
              // collect form data → build Booking
              // bookingCtrl.createPendingBooking(booking);
            },
            child: const Text('Create & Pay'),
          ),
        ],
      ),
    );
  }
}
```

## 10) Cross-Cutting Concerns
- **Validation**: core/utils/validators.dart (emails, phone, time slot overlap)
- **Errors**: core/errors with typed exceptions; map to user messages in Controllers
- **Logging**: lightweight logger wrapper
- **Config**: env keys for Firebase/PayFast; flavors for dev/prod
- **Security**: use Cloud Functions for IPN verification and sensitive updates

## 11) Testing Strategy
- Unit: repositories (with Firebase emulator/mocks), controllers logic (commission calc, slot conflicts)
- Widget: screens for booking, verification flow
- Integration: booking→payment happy path with mocked PayFast

## 12) Implementation Order (MVC-first)
1. Domain models + repository interfaces
2. Firebase impls for Auth/Profile/Booking/Qari
3. Controllers: Auth, Qari, Student, Booking, Payment, Admin
4. Router + guards (role/verified)
5. Views: minimal dashboards + separate signup pages (Student/Qari)
6. Availability editor; search; booking create
7. PayFast start-to-finish; session join (WebRTC/Jitsi/Agora)

---
This plan keeps UI thin (Views), logic centralized (Controllers), and data access isolated (Repositories/Services) while aligning with Provider and Firebase choices.