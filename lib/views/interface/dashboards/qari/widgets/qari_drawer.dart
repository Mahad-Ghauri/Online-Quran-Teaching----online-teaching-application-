import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:qari_connect/services/auth_service.dart';

class QariDrawer extends StatelessWidget {
  const QariDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          _buildDrawerHeader(context),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  subtitle: 'Overview & quick actions',
                  onTap: () {
                    Navigator.pop(context);
                    // Already on dashboard
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.verified_user,
                  title: 'Verification Status',
                  subtitle: 'Check your verification progress',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToVerification(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.upload_file,
                  title: 'Upload Documents',
                  subtitle: 'Submit verification documents',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToDocumentUpload(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.star_rate,
                  title: 'Reviews & Ratings',
                  subtitle: 'View student feedback',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToReviews(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.analytics,
                  title: 'Teaching Analytics',
                  subtitle: 'Performance insights',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToAnalytics(context);
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_center,
                  title: 'Help & Support',
                  subtitle: 'Get assistance',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToSupport(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'App preferences',
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToSettings(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info,
                  title: 'About QariConnect',
                  subtitle: 'App information',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: 'Sign Out',
                  subtitle: 'Exit your account',
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _showSignOutDialog(context);
                  },
                ),
              ],
            ),
          ),
          
          // Footer
          _buildDrawerFooter(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      height: 180,
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile Image
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              
              // Name
              Flexible(
                child: Text(
                  'Ustadh Ahmed Al-Rashid', // TODO: Get from user profile
                  style: GoogleFonts.merriweather(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              
              // Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 10,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Verified',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '4.8',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Theme.of(context).primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Column(
        children: [
          Text(
            'QariConnect',
            style: GoogleFonts.merriweather(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Connecting Hearts Through Learning',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Version 1.0.0',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Navigation Methods
  void _navigateToVerification(BuildContext context) {
    // TODO: Navigate to verification status page
    _showComingSoon(context, 'Verification Status');
  }

  void _navigateToDocumentUpload(BuildContext context) {
    // TODO: Navigate to document upload page
    _showComingSoon(context, 'Document Upload');
  }

  void _navigateToReviews(BuildContext context) {
    // TODO: Navigate to reviews page
    _showComingSoon(context, 'Reviews & Ratings');
  }

  void _navigateToAnalytics(BuildContext context) {
    // TODO: Navigate to analytics page
    _showComingSoon(context, 'Teaching Analytics');
  }

  void _navigateToSupport(BuildContext context) {
    // TODO: Navigate to support page
    _showComingSoon(context, 'Help & Support');
  }

  void _navigateToSettings(BuildContext context) {
    // TODO: Navigate to settings page
    _showComingSoon(context, 'Settings');
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'About QariConnect',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QariConnect bridges the gap between students seeking Quranic education and qualified, verified Qaris.',
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 16),
            Text(
              'Features:',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '• Verified teacher network\n'
              '• Flexible scheduling system\n'
              '• Secure payment processing\n'
              '• High-quality live sessions\n'
              '• Comprehensive learning platform',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              'Version: 1.0.0\n'
              'Built with ❤️ for the Islamic community',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out',
          style: GoogleFonts.merriweather(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to sign out of your account?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.signOut();
              if (context.mounted) {
                context.go('/sign-in');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
