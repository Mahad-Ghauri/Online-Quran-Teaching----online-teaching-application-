// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qari_connect/providers/app_providers.dart';
import 'package:qari_connect/views/interface/dashboards/qari/pages/qari_home_page.dart';
import 'package:qari_connect/views/interface/dashboards/qari/pages/qari_schedule_page.dart';
import 'package:qari_connect/views/interface/dashboards/qari/pages/qari_live_page.dart';
import 'package:qari_connect/views/interface/dashboards/qari/pages/qari_earnings_page.dart';
import 'package:qari_connect/views/interface/dashboards/qari/pages/qari_profile_page.dart';
import 'package:qari_connect/views/interface/dashboards/qari/widgets/qari_drawer.dart';

class QariMainDashboard extends StatefulWidget {
  const QariMainDashboard({super.key});

  @override
  State<QariMainDashboard> createState() => _QariMainDashboardState();
}

class _QariMainDashboardState extends State<QariMainDashboard> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _initializeRealTimeData();
  }

  void _initializeRealTimeData() {
    final authProvider = context.read<AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();
    final qariProvider = context.read<QariProvider>();

    if (authProvider.currentUser != null) {
      // Start listening to Qari's bookings in real-time
      bookingProvider.startListeningToUserBookings(
        authProvider.currentUser!.id,
        authProvider.currentUser!.role,
      );
      
      // Start listening to current Qari's profile in real-time
      qariProvider.startListeningToCurrentQariProfile(
        authProvider.currentUser!.id,
      );
    }
  }

  final List<Widget> _pages = const [
    QariHomePage(),
    QariSchedulePage(),
    QariLivePage(),
    QariEarningsPage(),
    QariProfilePage(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today_outlined),
      activeIcon: Icon(Icons.calendar_today),
      label: 'Schedule',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.videocam_outlined),
      activeIcon: Icon(Icons.videocam),
      label: 'Go Live',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.account_balance_wallet_outlined),
      activeIcon: Icon(Icons.account_balance_wallet),
      label: 'Earnings',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
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
      drawer: const QariDrawer(),
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
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Theme.of(context).cardColor,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: _bottomNavItems,
        ),
      ),
    );
  }
}
