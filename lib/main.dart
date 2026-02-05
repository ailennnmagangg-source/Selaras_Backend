import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import Constants & Config
import 'core/network/supabase_config.dart';
import 'core/constants/app_colors.dart';

// Import Features
import 'features/auth/ui/splash_screen.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/auth/logic/role_wrapper.dart';

// Import Dashboards (Sesuaikan path dengan struktur folder baru)
import 'features/admin/dashboard/ui/admin_home_screen.dart';
// import 'features/petugas/dashboard/ui/petugas_home_screen.dart';
// import 'features/peminjam/katalog/ui/katalog_peminjam_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Selaras',
      
      // 2. Tema Global (Opsional: Agar font konsisten)
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Poppins', // Pastikan sudah daftar di pubspec.yaml
      ),

      // 3. Titik Awal: SplashScreen
      // Splash akan muncul 3 detik, lalu pindah ke LoginScreen
      home: SplashScreen(), 

      // 4. Routes untuk navigasi antar role
      routes: {
        '/login': (context) => const LoginScreen(),
        '/role-wrapper': (context) => const RoleWrapper(),
        
        // Dashboard masing-masing role
        '/admin-home': (context) => const AdminHomeScreen(),
        // '/petugas-home': (context) => const PetugasHomeScreen(),
        // '/peminjam-home': (context) => const KatalogPeminjamScreen(),
      },
    );
  }
}