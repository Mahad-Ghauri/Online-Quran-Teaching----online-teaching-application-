// Utility functions for managing user verification field in Firestore
// Run this once to fix existing users without isVerified field

// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/core_models.dart';

class UserFieldMigration {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  /// Fix all existing users to have isVerified field
  static Future<void> addIsVerifiedFieldToAllUsers() async {
    try {
      print('🔧 Starting migration: Adding isVerified field to all users...');
      
      // Get all users from Firestore
      final QuerySnapshot usersSnapshot = await _firestore
          .collection(_usersCollection)
          .get();

      final batch = _firestore.batch();
      int updatedCount = 0;

      for (final doc in usersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Check if isVerified field is missing
        if (!data.containsKey('isVerified')) {
          print('📝 Adding isVerified field to user: ${doc.id}');
          
          // Add isVerified field with default value
          batch.update(doc.reference, {
            'isVerified': false, // Default to false for all users
          });
          updatedCount++;
        }
      }

      if (updatedCount > 0) {
        await batch.commit();
        print('✅ Migration complete: Updated $updatedCount users');
      } else {
        print('✅ No users needed updating - all have isVerified field');
      }
      
    } catch (e) {
      print('❌ Migration failed: $e');
      throw Exception('Failed to migrate users: $e');
    }
  }

  /// Force add isVerified field to ALL users (even if they have other fields)
  static Future<void> forceAddIsVerifiedToAllUsers() async {
    try {
      print('🔧 Force adding isVerified field to ALL users...');
      
      final QuerySnapshot usersSnapshot = await _firestore
          .collection(_usersCollection)
          .get();

      final batch = _firestore.batch();
      int totalUsers = 0;

      for (final doc in usersSnapshot.docs) {
        print('📝 Force updating user: ${doc.id}');
        
        // Force add/update isVerified field
        batch.update(doc.reference, {
          'isVerified': false, // Set to false for all users
        });
        totalUsers++;
      }

      if (totalUsers > 0) {
        await batch.commit();
        print('✅ Force migration complete: Updated $totalUsers users');
      } else {
        print('ℹ️ No users found in Firestore');
      }
      
    } catch (e) {
      print('❌ Force migration failed: $e');
      throw Exception('Failed to force migrate users: $e');
    }
  }

  /// Verify a specific Qari (set isVerified to true)
  static Future<void> verifySpecificQari(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'isVerified': true,
      });
      print('✅ Verified Qari: $userId');
    } catch (e) {
      print('❌ Failed to verify Qari $userId: $e');
      throw Exception('Failed to verify Qari: $e');
    }
  }

  /// Check if a user has the isVerified field
  static Future<bool> userHasIsVerifiedField(String userId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data.containsKey('isVerified');
      }
      return false;
    } catch (e) {
      print('❌ Error checking user field: $e');
      return false;
    }
  }

  /// List all users and their verification status
  static Future<void> listAllUsersWithVerificationStatus() async {
    try {
      final QuerySnapshot usersSnapshot = await _firestore
          .collection(_usersCollection)
          .get();

      print('📋 All users in Firestore:');
      print('=' * 50);

      for (final doc in usersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'Unknown';
        final email = data['email'] ?? 'Unknown';
        final role = data['role'] ?? 'Unknown';
        final isVerified = data['isVerified'] ?? 'MISSING FIELD';
        
        print('👤 User ID: ${doc.id}');
        print('   Name: $name');
        print('   Email: $email');
        print('   Role: $role');
        print('   isVerified: $isVerified');
        print('   hasField: ${data.containsKey('isVerified')}');
        print('-' * 30);
      }
    } catch (e) {
      print('❌ Error listing users: $e');
    }
  }

  /// Create user with guaranteed isVerified field
  static Future<void> createUserWithVerificationField({
    required String userId,
    required String name,
    required String email,
    required UserRole role,
    bool isVerified = false,
  }) async {
    try {
      final userData = {
        'name': name,
        'email': email,
        'role': role.name.toLowerCase(),
        'isVerified': isVerified, // Explicitly set this field
        'createdAt': Timestamp.fromDate(DateTime.now()),
      };

      await _firestore.collection(_usersCollection).doc(userId).set(userData);
      print('✅ Created user with isVerified field: $userId');
    } catch (e) {
      print('❌ Failed to create user: $e');
      throw Exception('Failed to create user: $e');
    }
  }

  /// Force update existing user to include isVerified field
  static Future<void> forceUpdateUserWithVerificationField(String userId) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(userId).get();
      
      if (!doc.exists) {
        throw Exception('User $userId does not exist');
      }

      final data = doc.data() as Map<String, dynamic>;
      
      // Force add isVerified field if missing
      if (!data.containsKey('isVerified')) {
        await _firestore.collection(_usersCollection).doc(userId).update({
          'isVerified': false,
        });
        print('✅ Added isVerified field to user: $userId');
      } else {
        print('ℹ️ User $userId already has isVerified field: ${data['isVerified']}');
      }
    } catch (e) {
      print('❌ Failed to update user $userId: $e');
      throw Exception('Failed to update user: $e');
    }
  }
}
