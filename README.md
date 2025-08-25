# QariConnect

A mobile app that connects verified Qaris (Quran teachers) with students for online Quran classes. Students can book time slots, pay via PayFast, and join live audio/video sessions using Jitsi integration. The platform ensures Qari verification and revenue sharing.

## 🎯 Project Overview

QariConnect is a comprehensive educational platform designed to bridge the gap between students seeking Quranic education and qualified, verified Qaris. The app provides a seamless experience for booking, payment, and conducting live online classes.

### Key Features

- **Verified Teacher Network**: All Qaris go through admin verification before offering classes
- **Flexible Scheduling**: Students can view and book available time slots with their preferred Qari
- **Secure Payments**: Integrated PayFast payment system with automatic commission splitting
- **Live Classes**: High-quality audio/video sessions powered by Jitsi Meet SDK
- **Multi-Role Platform**: Supports Students, Qaris, and Admins with role-specific features

## 👥 User Roles & Capabilities

### 📚 Student Features
- Sign up and log in securely
- Browse verified Qaris with detailed profiles
- View real-time availability and time slots
- Book sessions with preferred teachers
- Make secure payments via PayFast
- Join live audio/video classes using Jitsi
- Rate and review Qaris after sessions
- Track booking history and progress

### 🎓 Qari (Teacher) Features
- Apply for platform verification
- Submit payment details (bank info, PayFast integration)
- Get approved by admin before offering classes
- Set and manage available time slots
- Host Jitsi-based live classes
- Receive payments automatically (minus platform commission)
- View student feedback and ratings
- Track earnings and session history

### 👨‍💼 Admin Features
- Verify Qaris before they can host classes
- Review and approve teacher applications
- Manage user accounts and platform settings
- Track all payments and commission distribution
- View comprehensive transaction history
- Monitor platform performance and analytics
- Suspend or remove accounts when necessary

## 💰 Payment System

### PayFast Integration
- **Processor**: PayFast (South African payment gateway)
- **Model**: Commission-based revenue sharing
- **Flow**: Automatic payment splitting upon successful transaction
  - Majority share goes to the Qari
  - Platform commission retained by admin
- **Security**: PCI-compliant payment processing
- **Transparency**: Clear transaction history for all parties

## 🎥 Live Class System

### Jitsi Meet Integration
- **Platform**: Jitsi Meet SDK for reliable video conferencing
- **Session Creation**: Qari creates unique room ID for each class
- **Student Access**: One-click join using provided room ID
- **Features**:
  - High-quality audio and optional video
  - Mute/unmute controls for participants
  - Screen sharing capabilities
  - End class control for Qari
  - Automatic session recording (optional)

## 🏗️ Technical Architecture

### Frontend
- **Framework**: Flutter (Cross-platform: iOS, Android, Web)
- **State Management**: Provider pattern
- **Navigation**: go_router for declarative routing
- **UI/UX**: Custom glassmorphism design with animations

### Backend & Services
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage for documents and media
- **Live Classes**: Jitsi Meet SDK integration
- **Payments**: PayFast API integration
- **Push Notifications**: Firebase Cloud Messaging

### Data Models

```dart
// Core user model
User {
  id: UUID
  name: String
  email: String
  role: Enum(Student, Qari, Admin)
  isVerified: Boolean
  createdAt: DateTime
}

// Qari profile with teaching details
QariProfile {
  qariId: UUID
  bio: Text
  subjects: List<String>
  languages: List<String>
  availableSlots: List<TimeSlot>
  paymentInfo: PaymentDetails
  rating: Float
  totalSessions: Integer
  verificationStatus: Enum
}

// Booking system
Booking {
  id: UUID
  studentId: UUID
  qariId: UUID
  timeSlot: TimeSlot
  subject: String
  status: Enum(Pending, Confirmed, Completed, Cancelled)
  sessionLink: String
  createdAt: DateTime
}

// Payment tracking
Payment {
  id: UUID
  bookingId: UUID
  amount: Decimal
  qariShare: Decimal
  adminCommission: Decimal
  paymentMethod: String
  status: Enum(Pending, Success, Failed, Refunded)
  transactionId: String
  processedAt: DateTime
}
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1+)
- Firebase project setup
- PayFast merchant account
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Mahad-Ghauri/qari_connect.git
   cd qari_connect
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add your `google-services.json` (Android)
   - Add your `GoogleService-Info.plist` (iOS)
   - Update Firebase configuration in `lib/firebase_options.dart`

4. **Configure PayFast**
   - Set up PayFast merchant credentials
   - Configure webhook endpoints
   - Update payment configuration

5. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Current Implementation Status

### ✅ Completed Features (25%)
- **Authentication System**: Complete signup/signin with role-based navigation
- **UI/UX Framework**: Professional glassmorphism design with animations
- **Firebase Integration**: Auth, Firestore, and Storage configured
- **Routing System**: go_router implementation with navigation guards
- **Component Library**: Reusable UI components and forms

### 🚧 In Development (Planned)
- **Core Data Models**: User profiles, bookings, payments
- **Dashboard Interfaces**: Role-specific dashboards with full functionality
- **Qari Discovery**: Search, filter, and browse verified teachers
- **Booking System**: Time slot management and reservation system
- **PayFast Integration**: Payment processing and commission splitting
- **Jitsi Integration**: Live video/audio session management
- **Admin Panel**: Verification workflow and platform management

### 📋 Upcoming Features
- **Rating & Review System**: Post-session feedback mechanism
- **Notification System**: Real-time updates and reminders
- **Analytics Dashboard**: Performance insights and reporting
- **Multi-language Support**: Arabic, English, Urdu interface
- **Offline Capabilities**: Basic functionality without internet

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on how to submit pull requests, report issues, and suggest improvements.

### Development Workflow
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support & Contact

For support, questions, or business inquiries:

- **Email**: support@qariconnect.com
- **GitHub Issues**: [Report a bug or request a feature](https://github.com/Mahad-Ghauri/qari_connect/issues)
- **Documentation**: [Full API Documentation](docs/api.md)

## 🙏 Acknowledgments

- **Flutter Team** for the excellent cross-platform framework
- **Firebase** for reliable backend services
- **Jitsi** for open-source video conferencing solutions
- **PayFast** for secure payment processing
- **Islamic Community** for inspiration and guidance

---

**Made with ❤️ for the Islamic education community**
