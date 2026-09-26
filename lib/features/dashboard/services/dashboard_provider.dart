import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model Sederhana
class UserProfile {
  final String name;
  final String avatarUrl;
  
  UserProfile({required this.name, required this.avatarUrl});
}

// Data Dummy Provider untuk State Management (Hooks/Services)
final userProfileProvider = Provider<UserProfile>((ref) {
  return UserProfile(
    name: 'Rownok', 
    avatarUrl: 'https://i.pravatar.cc/150?img=11',
  );
});

// Contoh Data Provider lainnya
final todayCaloriesProvider = Provider<int>((ref) => 350);
