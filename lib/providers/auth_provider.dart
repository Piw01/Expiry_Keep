import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// Mendapatkan status user saat ini (sudah login atau belum)
final authStateProvider = StreamProvider<AuthState>((ref) {
  return supabase.auth.onAuthStateChange;
});

// Fungsi Login
Future<void> signIn(String email, String password) async {
  await supabase.auth.signInWithPassword(email: email, password: password);
}

// Fungsi Register
Future<void> signUp(String email, String password) async {
  await supabase.auth.signUp(email: email, password: password);
}

// Fungsi Logout
Future<void> signOut() async {
  await supabase.auth.signOut();
}