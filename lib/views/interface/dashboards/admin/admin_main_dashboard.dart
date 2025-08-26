import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../providers/app_providers.dart';
import '../../../../components/gradient_background.dart';
import 'pages/admin_home_page.dart';
import 'pages/admin_users_page.dart';
import 'pages/admin_qari_verification_page.dart';
import 'pages/admin_payments_page.dart';
import 'widgets/admin_drawer.dart';

class AdminMainDashboard extends StatefulWidget {
  const AdminMainDashboard({super.key});

  @override
  State<AdminMainDashboard> createState() => _AdminMainDashboardState();
}

class _AdminMainDashboardState extends State<AdminMainDashboard> {
  int _currentIndex = 0;
  bool _isInitialized = false;
  
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const AdminHomePage(),
      const AdminUsersPage(),
      const AdminQariVerificationPage(), 
      const AdminPaymentsPage(),
    ];
    // Use addPostFrameCallback to ensure initialization happens after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAdminData();
    });
  }

  void _initializeAdminData() {
    // Initialize real-time data for admin dashboard
    try {
      final qariProvider = context.read<QariProvider>();
      // final bookingProvider = context.read<BookingProvider>();
      
      // Start listening to all data for admin oversight
      qariProvider.startListeningToVerifiedQaris();
      // Note: We'll add startListeningToAllBookings method to BookingProvider
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      // Handle initialization errors gracefully
      debugPrint('Admin data initialization error: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true; // Still show content even if initialization fails
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: const AdminDrawer(),
        body: SafeArea(
          child: _isInitialized 
            ? IndexedStack(
                index: _currentIndex,
                children: _pages,
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.6),
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Users',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.verified_user),
                label: 'Verify Qaris',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.payment),
                label: 'Payments',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Stop listening when admin dashboard is disposed
    if (mounted) {
      try {
        final qariProvider = context.read<QariProvider>();
        // final bookingProvider = context.read<BookingProvider>();
        
        qariProvider.stopListening();
        // bookingProvider.stopListening();
      } catch (e) {
        debugPrint('Error during admin dashboard disposal: $e');
      }
    }
    super.dispose();
  }
}
