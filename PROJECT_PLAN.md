# Qari Learning App — Step-by-Step Implementation Plan

This plan operationalizes the full flow (student booking, Qari verification, payments with commission, and in-app admin panel) with two dashboards (Student, Qari) and separate signup pages.

## 0) Key Decisions (confirm before proceeding)
- [ ] **Backend platform**: Firebase (Auth + Firestore + Storage + Functions) OR Supabase (Auth + Postgres + Storage + Edge Functions)
- [ ] **State management**: Riverpod / Bloc / Provider
- [ ] **Navigation**: go_router / Navigator 2.0
- [ ] **Live audio**: WebRTC / Jitsi SDK / Agora (free tier)
- [ ] **Payments**: PayFast Split Payments API vs single merchant + manual payouts
- [ ] **Target platforms**: Android, iOS, Web, Desktop (Linux/Mac/Windows)

## 1) Project Setup
- [ ] Initialize Flutter project configs (flavors if needed: dev/stage/prod)
- [ ] Add dependencies (example for Firebase stack):
  - [ ] firebase_core, firebase_auth, cloud_firestore, firebase_storage
  - [ ] cloud_functions (for server-validated tasks)
  - [ ] go_router or auto_route
  - [ ] state management (Riverpod/Bloc)
  - [ ] file_picker / image_picker for document uploads
  - [ ] http/dio for PayFast integration
  - [ ] webrtc/jitsi_meet_wrapper/agora_rtc_engine (one)
  - [ ] intl (time formatting), timezone handling if needed
- [ ] Configure platforms (Android/iOS) for Auth, deep links/redirects (PayFast return/cancel), permissions (mic for audio)

## 2) Auth + Role Selection + Routing
- [ ] Splash → RoleSelection: Student | Qari
- [ ] Separate signup pages:
  - [ ] StudentSignup: name, email, phone, optional profile image
  - [ ] QariSignup: name, email, phone, subjects, languages, bio; then DocumentUpload
- [ ] On signup, create profile in DB with `role` and metadata
- [ ] Post-signup routing:
  - Student → StudentDashboard
  - Qari → if NOT verified → VerificationPending → limited features; if verified → QariDashboard
- [ ] Admin role recognized via DB flag/claim → AdminPanel entry point

### Suggested Routes/Screens
- Shared: Splash, RoleSelection, Login/Signup, Profile
- Student: StudentDashboard, QariSearch, QariDetail, BookingCreate, BookingList
- Qari: QariDashboard, AvailabilityEditor, VerificationPending, Payouts
- Admin: AdminDashboard, QariVerificationQueue, Payments, Reports, Bookings

## 3) Data Models (reference)
```json
{
  "Student": {
    "studentId": "string",
    "name": "string",
    "email": "string",
    "phone": "string",
    "profileImageUrl": "string?",
    "createdAt": "timestamp",
    "updatedAt": "timestamp"
  },
  "Qari": {
    "qariId": "string",
    "name": "string",
    "email": "string",
    "phone": "string",
    "profileImageUrl": "string?",
    "bio": "string",
    "subjects": ["string"],
    "languages": ["string"],
    "availability": [
      { "day": "string", "startTime": "HH:mm", "endTime": "HH:mm" }
    ],
    "verified": "boolean",
    "verificationDocs": ["string"],
    "paymentInfo": {
      "bankAccount": "string?",
      "payfastMerchantId": "string?"
    },
    "createdAt": "timestamp",
    "updatedAt": "timestamp"
  },
  "Admin": {
    "adminId": "string",
    "name": "string",
    "email": "string",
    "role": "super|moderator",
    "createdAt": "timestamp"
  },
  "Booking": {
    "bookingId": "string",
    "studentId": "string",
    "qariId": "string",
    "subject": "string",
    "timeSlot": { "day": "string", "startTime": "HH:mm", "endTime": "HH:mm" },
    "status": "pending|confirmed|completed|cancelled",
    "createdAt": "timestamp",
    "updatedAt": "timestamp"
  },
  "Payment": {
    "paymentId": "string",
    "bookingId": "string",
    "studentId": "string",
    "qariId": "string",
    "amount": 0,
    "currency": "string",
    "status": "success|failed|pending",
    "provider": "PayFast",
    "transactionRef": "string",
    "commissionRate": 0.1,
    "appEarnings": 0,
    "qariEarnings": 0,
    "payoutStatus": "pending|processed",
    "payoutMethod": "split|manual",
    "createdAt": "timestamp"
  },
  "AdminReport": {
    "reportId": "string",
    "dateRange": { "start": "timestamp", "end": "timestamp" },
    "totalRevenue": 0,
    "totalAppEarnings": 0,
    "totalQariEarnings": 0,
    "payoutSummary": [ { "qariId": "string", "amountDue": 0, "payoutStatus": "string" } ]
  }
}
```

## 4) Suggested DB Structure (Firestore example)
- Collections:
  - `students/{studentId}`
  - `qari/{qariId}`
  - `admins/{adminId}`
  - `bookings/{bookingId}`
  - `payments/{paymentId}`
  - `adminReports/{reportId}` (optional, can be computed)
  - `qari_verifications/{qariId}` (queue with docs/status/notes)
- Indexes:
  - `qari` composite on `verified == true`, `subjects` array-contains, `languages` array-contains
  - `bookings` on `qariId`, `status`; on `studentId`, `status`

## 5) Security Rules (Firestore sketch)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() { return request.auth != null; }
    function isAdmin() { return request.auth.token.role in ['super','moderator']; }
    function isStudent(uid) { return request.auth.uid == uid; }
    function isQari(uid) { return request.auth.uid == uid; }

    match /students/{uid} {
      allow read: if isSignedIn() && (isStudent(uid) || isAdmin());
      allow write: if isStudent(uid) || isAdmin();
    }

    match /qari/{uid} {
      allow read: if resource.data.verified == true || isAdmin() || isQari(uid);
      allow write: if isQari(uid) || isAdmin();
    }

    match /bookings/{id} {
      allow read, write: if isSignedIn(); // refine per role ownership
    }

    match /payments/{id} {
      allow read: if isAdmin() || request.auth.uid in [resource.data.studentId, resource.data.qariId];
      allow write: if isAdmin(); // or via Cloud Functions only
    }

    match /qari_verifications/{uid} {
      allow read: if isAdmin() || isQari(uid);
      allow write: if isQari(uid) || isAdmin();
    }
  }
}
```

## 6) Qari Verification Flow
- [ ] Qari uploads `verificationDocs` and `paymentInfo`
- [ ] Create/Update `qari_verifications/{qariId}` with `status: submitted`
- [ ] Admin reviews in-app → approve/reject with notes
- [ ] On approve: set `qari.verified = true`
- [ ] Gate search/listing and bookings behind `verified == true`

## 7) Discovering Qaris
- [ ] Search filters: subjects, languages, availability
- [ ] Availability editor for Qari; client-side conflict validation
- [ ] Student sees available slots; select to initiate booking

## 8) Booking Flow
- [ ] Create `Booking` with `status = pending`
- [ ] Reserve timeslot (optional: optimistic lock via subcollection `reserved_slots` with TTL)
- [ ] Redirect to payment (PayFast)
- [ ] On success webhook/callback → confirm booking (`status = confirmed`)
- [ ] Post-session → mark `completed`, collect review (optional future feature)

## 9) Payments + Commission (PayFast)
- [ ] Configure PayFast credentials (sandbox first)
- [ ] If Split Payments available:
  - [ ] Build payload with app merchant + Qari sub-merchant and `commissionRate`
  - [ ] Funds split instantly → set `payoutStatus = processed`
- [ ] If single merchant flow:
  - [ ] Receive full amount → compute `appEarnings`, `qariEarnings`
  - [ ] Set `payoutStatus = pending` → Admin manual payout tracking
- [ ] Persist `Payment` linked to `Booking`
- [ ] Handle IPN/webhook verification server-side (Cloud Function/Edge Function)

### PayFast Integration Tasks
- [ ] Create order session (amount, item_name, return_url, cancel_url, notify_url)
- [ ] Validate IPN signature on server
- [ ] Update `Payment.status` and `Booking.status` atomically on success

## 10) Live Session
- [ ] At scheduled time: join room (WebRTC/Jitsi/Agora)
- [ ] Permissions: microphone
- [ ] End session → update booking to `completed`

## 11) Admin Panel (in-app)
- [ ] Qari Verification Queue: list, view docs, approve/reject
- [ ] Entities: Students, Qaris, Bookings
- [ ] Payments & Commission: filter by date/status, export CSV
- [ ] Payout management (if not split)
- [ ] Reports: totals, per-Qari earnings, outstanding payouts

## 12) UX Notes
- [ ] RoleSelection persists chosen role until logout
- [ ] Empty states for dashboards
- [ ] Error handling + snackbars
- [ ] Loading skeletons

## 13) Testing & QA
- [ ] Unit tests: models, utils (commission calc, availability overlap)
- [ ] Widget tests: major screens
- [ ] Integration tests: booking + payment success path (mock PayFast)

## 14) Deployment
- [ ] App icons/splash
- [ ] Android signing, iOS provisioning
- [ ] Environment configs (prod keys)
- [ ] Crashlytics/Analytics (optional)

## 15) Immediate Next Steps (Today)
1. [ ] Confirm Section 0 decisions (Firebase vs Supabase; state management; router; live audio; PayFast mode)
2. [ ] Scaffold routes + role-based navigation guards
3. [ ] Implement separate signup pages and profile creation (Student, Qari)
4. [ ] Build Qari VerificationPending + DocumentUpload screens
5. [ ] Create QariDashboard with AvailabilityEditor
6. [ ] Implement Student flow: Search → QariDetail → BookingCreate (pending)
7. [ ] Stub PayFast service + return/cancel handlers (UI only) and data models

---

## Code Stubs (Dart models)
```dart
// Minimal models for early compile
class TimeSlot {
  final String day; // Monday, Tuesday
  final String startTime; // "08:00"
  final String endTime; // "10:00"
  const TimeSlot({required this.day, required this.startTime, required this.endTime});
}

class Student {
  final String studentId;
  final String name;
  final String email;
  final String phone;
  final String? profileImageUrl;
  const Student({
    required this.studentId,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl,
  });
}

class Qari {
  final String qariId;
  final String name;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final String bio;
  final List<String> subjects;
  final List<String> languages;
  final List<TimeSlot> availability;
  final bool verified;
  final List<String> verificationDocs;
  const Qari({
    required this.qariId,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    required this.bio,
    required this.subjects,
    required this.languages,
    required this.availability,
    required this.verified,
    required this.verificationDocs,
  });
}

class Booking {
  final String bookingId;
  final String studentId;
  final String qariId;
  final String subject;
  final TimeSlot timeSlot;
  final String status; // pending | confirmed | completed | cancelled
  const Booking({
    required this.bookingId,
    required this.studentId,
    required this.qariId,
    required this.subject,
    required this.timeSlot,
    required this.status,
  });
}

class Payment {
  final String paymentId;
  final String bookingId;
  final String studentId;
  final String qariId;
  final double amount;
  final String currency;
  final String status; // success | failed | pending
  final String provider; // PayFast
  final String transactionRef;
  final double commissionRate; // e.g. 0.10
  final double appEarnings;
  final double qariEarnings;
  final String payoutStatus; // pending | processed
  final String payoutMethod; // split | manual
  const Payment({
    required this.paymentId,
    required this.bookingId,
    required this.studentId,
    required this.qariId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.provider,
    required this.transactionRef,
    required this.commissionRate,
    required this.appEarnings,
    required this.qariEarnings,
    required this.payoutStatus,
    required this.payoutMethod,
  });
}
```

---

## Notes
- If helpful, I can also create a `/docs/` folder and split this plan into smaller focused docs (auth, payments, admin). Let me know your choices in Section 0, and I’ll start implementing the first screens.