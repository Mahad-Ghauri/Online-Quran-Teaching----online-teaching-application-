// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:qari_connect/providers/app_providers.dart';
import 'package:qari_connect/views/interface/dashboards/student/pages/student_home_page.dart';
import 'package:qari_connect/views/interface/dashboards/student/pages/student_qaris_page.dart';
import 'package:qari_connect/views/interface/dashboards/student/pages/student_bookings_page.dart';
import 'package:qari_connect/views/interface/dashboards/student/pages/student_live_page.dart';
import 'package:qari_connect/views/interface/dashboards/student/pages/student_profile_page.dart';
import 'package:qari_connect/views/interface/dashboards/student/widgets/student_drawer.dart';

class StudentMainDashboard extends StatefulWidget {
  const StudentMainDashboard({super.key});

  @override
  State<StudentMainDashboard> createState() => _StudentMainDashboardState();
}

class _StudentMainDashboardState extends State<StudentMainDashboard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: 5, vsync: this);
    
    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final qariProvider = context.read<QariProvider>();
      final bookingProvider = context.read<BookingProvider>();
      
      authProvider.initializeAuth().then((_) {
        if (authProvider.currentUser != null) {
          // Start real-time listeners
          qariProvider.startListeningToVerifiedQaris();
          bookingProvider.startListeningToUserBookings(
            authProvider.currentUser!.id,
            authProvider.currentUser!.role,
          );
        }
      });
    });
  }

  final List<Widget> _pages = [
    const StudentHomePage(),
    const StudentQarisPage(),
    const StudentBookingsPage(),
    const StudentLivePage(),
    const StudentProfilePage(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.school_outlined),
      activeIcon: Icon(Icons.school),
      label: 'Qaris',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.book_outlined),
      activeIcon: Icon(Icons.book),
      label: 'Bookings',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.videocam_outlined),
      activeIcon: Icon(Icons.videocam),
      label: 'Live',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'QariConnect',
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      drawer: const StudentDrawer(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: _bottomNavItems,
        ),
      ),
    );
  }
}
