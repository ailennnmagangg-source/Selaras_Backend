import 'package:flutter/material.dart';
import 'package:selaras_backend/features/auth/logic/role_wrapper.dart';
import '../../../core/constants/app_colors.dart';
import '../logic/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;
  // Tambahkan variabel ini di dalam _LoginScreenState
  String? _emailError;
  String? _passwordError;

  void _handleLogin() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Validasi Input Kosong
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        if (email.isEmpty) _emailError = "Email wajib diisi!";
        if (password.isEmpty) _passwordError = "Kata sandi wajib diisi!";
        _isLoading = false;
      });
      return;
    }

    try {
      // 2. CEK APAKAH EMAIL TERDAFTAR DI DATABASE
      final bool isEmailRegistered = await AuthController().checkEmailExists(email);

      if (!isEmailRegistered) {
        setState(() {
          _emailError = "Akun tidak ditemukan!"; // Error muncul di field Email
          _isLoading = false;
        });
        return; // Berhenti, jangan lanjut ke proses login
      }

      // 3. JIKA EMAIL DITEMUKAN, BARU PROSES LOGIN
      await AuthController().login(email, password);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoleWrapper()),
        );
      }
    } catch (e) {
      String errorMsg = e.toString();
      debugPrint("Login Error Log: $errorMsg");

      setState(() {
        // Karena email sudah dipastikan ada di database (langkah 2),
        // maka jika login gagal di sini, penyebabnya pasti password salah.
        _passwordError = "Kata sandi salah!"; // Error muncul di field Password
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // TAMBAHKAN INI: Agar semua isi Column rata kiri
            children: [
              const SizedBox(height: 40),
              // Agar gambar tetap di tengah, bungkus dengan Center atau Align
              Center(
                child: Image.asset('assets/images/login_illustration.png', height: 200),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Login", 
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold, 
                    color: AppColors.textPrimary
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Halo!", 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
              ),
              const Text(
                "Selaraskan kebutuhan,\noptimalkan fasilitas.", 
                textAlign: TextAlign.start, // UBAH INI: Dari center ke start
                style: TextStyle(color: AppColors.textSecondary)
              ),
              const SizedBox(height: 30),

              // --- Bagian Input Email ---
            _buildLabel("Email"),
            TextField(
              controller: _emailController,
              decoration: _inputDecoration(
                "Masukkan alamat email Anda", 
                isError: _emailError != null // Tambahkan parameter isError
              ),
            ),
            if (_emailError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(_emailError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            
            const SizedBox(height: 20),

            // --- Bagian Input Password ---
            _buildLabel("Kata Sandi"),
            TextField(
              controller: _passwordController,
              obscureText: _isObscure,
              decoration: _inputDecoration(
                "Masukkan kata sandi Anda", 
                isError: _passwordError != null
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, 
                        color: _passwordError != null ? Colors.red : AppColors.primaryBlue),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
              ),
            ),
            if (_passwordError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(_passwordError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),

              const SizedBox(height: 40),

              // Tombol Masuk
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Masuk", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {bool isError = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textPlaceholder, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      
      // Border saat diam
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isError ? Colors.red : Colors.transparent, // Merah jika error
          width: isError ? 1.5 : 1,
        ), 
      ),
      
      // Border saat diklik
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isError ? Colors.red : AppColors.primaryBlue, 
          width: 2
        ),
      ),
    );
  }
}