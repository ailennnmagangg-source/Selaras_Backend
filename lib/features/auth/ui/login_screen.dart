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
  String? _errorMessage;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      await AuthController().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      // Jika login sukses, pindah ke RoleWrapper untuk dicek rolenya
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoleWrapper()),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = "Email atau password salah");
    } finally {
      setState(() => _isLoading = false);
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
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/images/login_illustration.png', height: 200),
              const SizedBox(height: 20),
              const Text("Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              const Text("Halo!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const Text("Selaraskan kebutuhan,\noptimalkan fasilitas.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 30),

              // Input Email
              _buildLabel("Email"),
              TextField(
                controller: _emailController,
                decoration: _inputDecoration("Masukkan alamat email Anda"),
              ),
              
              const SizedBox(height: 20),

              // Input Password
              _buildLabel("Kata Sandi"),
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                decoration: _inputDecoration("Masukkan kata sandi Anda").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.primaryBlue),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                ),
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textPlaceholder, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.inputBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.inputBorder)),
    );
  }
}