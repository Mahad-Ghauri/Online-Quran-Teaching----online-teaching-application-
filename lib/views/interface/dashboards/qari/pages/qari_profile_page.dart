import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qari_connect/services/auth_service.dart';
import '../../../../../providers/app_providers.dart';
import '../../../../../models/core_models.dart';

class QariProfilePage extends StatefulWidget {
  const QariProfilePage({super.key});

  @override
  State<QariProfilePage> createState() => _QariProfilePageState();
}

class _QariProfilePageState extends State<QariProfilePage> {
  bool _isEditing = false;
  
  // Controllers for editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pricingController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _pricingController.dispose();
    super.dispose();
  }

  void _loadProfileData() {
    // Real-time data loading is handled by providers
    final authProvider = context.read<AuthProvider>();
    final qariProvider = context.read<QariProvider>();
    
    if (authProvider.currentUser != null) {
      // Initialize controllers with current data if available
      final user = authProvider.currentUser!;
      final profile = qariProvider.currentQariProfile;
      
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _bioController.text = profile?.bio ?? '';
      _pricingController.text = profile?.pricing.toString() ?? '50.0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_isEditing) ...[
            TextButton(
              onPressed: _cancelEdit,
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ),
          ] else
            IconButton(
              onPressed: _startEdit,
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 20),
            
            // Verification Status
            _buildVerificationStatus(),
            const SizedBox(height: 20),
            
            // Profile Information
            _buildProfileInfo(),
            const SizedBox(height: 20),
            
            // Subjects & Languages
            _buildSubjectsAndLanguages(),
            const SizedBox(height: 20),
            
            // Statistics
            _buildStatistics(),
            const SizedBox(height: 20),
            
            // Settings
            _buildSettings(),
            
            // Extra bottom padding to ensure scrollability
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _changeProfileImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _isEditing
              ? TextFormField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.merriweather(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Your Name',
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                )
              : Text(
                  _nameController.text,
                  style: GoogleFonts.merriweather(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '4.8 (127 reviews)',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatus() {
    final isVerified = true; // TODO: Get from actual profile data
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVerified 
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified 
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.warning_amber_rounded,
            color: isVerified ? Colors.green : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVerified ? 'Verified Teacher' : 'Verification Pending',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: isVerified ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
                Text(
                  isVerified 
                      ? 'Your profile has been verified by our admin team'
                      : 'Complete your verification to start accepting bookings',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isVerified ? Colors.green[600] : Colors.orange[600],
                  ),
                ),
              ],
            ),
          ),
          if (!isVerified)
            TextButton(
              onPressed: () {
                // TODO: Navigate to verification page
              },
              child: const Text('Complete'),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Information',
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              'Email',
              'ahmed.qari@example.com',
              Icons.email,
              editable: false,
            ),
            const SizedBox(height: 12),
            _buildInfoField(
              'Phone',
              _phoneController.text,
              Icons.phone,
              controller: _phoneController,
            ),
            const SizedBox(height: 12),
            _buildInfoField(
              'Bio',
              _bioController.text,
              Icons.info,
              controller: _bioController,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _buildInfoField(
              'Pricing (R per session)',
              _pricingController.text,
              Icons.monetization_on,
              controller: _pricingController,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(
    String label,
    String value,
    IconData icon, {
    TextEditingController? controller,
    bool editable = true,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        _isEditing && editable && controller != null
            ? TextFormField(
                controller: controller,
                maxLines: maxLines,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  prefixIcon: Icon(icon),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              )
            : Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildSubjectsAndLanguages() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teaching Specialization',
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Subjects
            Text(
              'Subjects',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _mockSubjects.map((subject) => Chip(
                label: Text(subject),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            
            // Languages
            Text(
              'Languages',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _mockLanguages.map((language) => Chip(
                label: Text(language),
                backgroundColor: Colors.green.withOpacity(0.1),
                labelStyle: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
              )).toList(),
            ),
            
            if (_isEditing) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _editSubjectsAndLanguages,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Specialization'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teaching Statistics',
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Total Sessions', '342', Icons.school),
                ),
                Expanded(
                  child: _buildStatItem('Total Students', '89', Icons.people),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Experience', '10+ Years', Icons.workspace_premium),
                ),
                Expanded(
                  child: _buildStatItem('Rating', '4.8/5.0', Icons.star),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Settings',
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingItem(
              'Notifications',
              'Manage your notification preferences',
              Icons.notifications,
              () {
                // TODO: Navigate to notifications settings
              },
            ),
            _buildSettingItem(
              'Privacy',
              'Control your privacy settings',
              Icons.privacy_tip,
              () {
                // TODO: Navigate to privacy settings
              },
            ),
            _buildSettingItem(
              'Help & Support',
              'Get help or contact support',
              Icons.help,
              () {
                // TODO: Navigate to help
              },
            ),
            _buildSettingItem(
              'Terms & Conditions',
              'Read our terms and conditions',
              Icons.description,
              () {
                // TODO: Navigate to terms
              },
            ),
            const Divider(),
            _buildSettingItem(
              'Sign Out',
              'Sign out of your account',
              Icons.logout,
              _signOut,
              textColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? Colors.grey[600],
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  void _startEdit() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
    });
    _loadProfileData(); // Reset to original data
  }

  void _saveProfile() async {
    final authProvider = context.read<AuthProvider>();
    final qariProvider = context.read<QariProvider>();
    
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Create or update QariProfile
      final pricing = double.tryParse(_pricingController.text.trim()) ?? 50.0;
      final qariProfile = QariProfile(
        qariId: authProvider.currentUser!.id,
        bio: _bioController.text.trim(),
        certificates: [], // TODO: Add certificate upload functionality
        availableSlots: [], // TODO: Add slot management
        pricing: pricing,
        rating: 0.0, // Initial rating
      );

      // Save the QariProfile to Firebase
      final success = await qariProvider.saveQariProfile(qariProfile);
      
      if (success) {
        setState(() {
          _isEditing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully! You can now receive bookings.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${qariProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _changeProfileImage() {
    // TODO: Implement image picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile image picker will be implemented'),
      ),
    );
  }

  void _editSubjectsAndLanguages() {
    // TODO: Show subjects and languages editor
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subjects and languages editor will be implemented'),
      ),
    );
  }

  void _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Clear all provider data before signing out
              AuthProvider.clearAllProviders(context);
              await AuthService.signOut();
              if (mounted) {
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

  // Mock data
  static const List<String> _mockSubjects = [
    'Tajweed',
    'Quran Memorization',
    'Arabic Grammar',
    'Islamic Studies',
    'Tafseer',
  ];

  static const List<String> _mockLanguages = [
    'Arabic',
    'English',
    'Urdu',
    'Afrikaans',
  ];
}
