import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- SETTING SUPABASE ---
  // Ganti string di bawah ini dengan Project URL & Anon Key dari Supabase kamu
  await Supabase.initialize(
    url: 'https://wprqvmbyjjpsnwkgtmsx.supabase.co', 
    anonKey: 'sb_publishable_1VV11DWTrUQqEWYBVsmgkA_FPu5cBBQ', 
  );

  // Jalankan aplikasi dibungkus ProviderScope (Wajib untuk Riverpod)
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FreshKeep',
      theme: ThemeData(
        // Biar warnanya hijau seger
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

