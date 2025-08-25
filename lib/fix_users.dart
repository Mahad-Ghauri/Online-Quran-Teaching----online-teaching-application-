// Quick fix for existing users missing isVerified field
// Run this to update all existing users in Firestore

import 'package:cloud_firestore/cloud_firestore.dart';

class QuickUserFix {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Force add isVerified field to ALL users in Firestore
  static Future<void> fixAllUsers() async {
    try {
      print('🔧 Starting quick fix: Adding isVerified to all users...');
      
      final QuerySnapshot usersSnapshot = await _firestore
          .collection('users')
          .get();

      final batch = _firestore.batch();
      int count = 0;

      for (final doc in usersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('📝 Fixing user: ${doc.id} (${data['name'] ?? 'Unknown'})');
        
        // Force add isVerified field
        batch.update(doc.reference, {
          'isVerified': false,
        });
        count++;
      }

      if (count > 0) {
        await batch.commit();
        print('✅ Quick fix complete: Fixed $count users');
      } else {
        print('ℹ️ No users found');
      }
      
    } catch (e) {
      print('❌ Quick fix failed: $e');
    }
  }

  /// List all users and show their fields
  static Future<void> checkAllUsers() async {
    try {
      final QuerySnapshot usersSnapshot = await _firestore
          .collection('users')
          .get();

      print('📋 Checking all users:');
      print('=' * 60);

      for (final doc in usersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        print('👤 User: ${doc.id}');
        print('   Name: ${data['name'] ?? 'N/A'}');
        print('   Email: ${data['email'] ?? 'N/A'}');
        print('   Phone: ${data['phone'] ?? 'N/A'}');
        print('   Role: ${data['role'] ?? 'N/A'}');
        print('   UID: ${data['uid'] ?? 'N/A'}');
        print('   isVerified: ${data['isVerified'] ?? 'MISSING'}');
        print('   CreatedAt: ${data['createdAt'] ?? 'N/A'}');
        print('   Has isVerified field: ${data.containsKey('isVerified')}');
        print('-' * 40);
      }
    } catch (e) {
      print('❌ Check failed: $e');
    }
  }
}

// You can call this from anywhere in your app to fix users
// Example: await QuickUserFix.fixAllUsers();
