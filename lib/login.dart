import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'candidate/candidate_home.dart';
import 'candidate/signup.dart';
import 'Staff/staff_home.dart'; // Make sure StaffHome class inside here uses UpperCamelCase

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),
      home: const LoginScreen(title: 'Login'), // Renamed to UpperCamelCase
    );
  }
}

// ─── Theme ────────────────────────────────────────────────────────────────────
const _primary      = Color(0xFF194569);
const _primaryLight = Color(0xFF2A6096);
const _bg           = Color(0xFFF0F4F8);
const _text         = Color(0xFF0D1F2D);
const _sub          = Color(0xFF607D8B);
const _divider      = Color(0xFFE8EEF4);
// ─────────────────────────────────────────────────────────────────────────────

// Renamed from 'login' to 'LoginScreen' to follow UpperCamelCase style
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.title});
  final String title;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Renamed from '_loginState' to '_LoginScreenState'
class _LoginScreenState extends State<LoginScreen> {

  // ── 2 tabs: Candidate | Staff ─────────────────────────────────────────────
  int _selectedTab = 0; // 0 = Candidate, 1 = Staff

  // Candidate controllers
  final TextEditingController _regNumberController  = TextEditingController();
  final TextEditingController _candPasswordController = TextEditingController();

  // Staff controllers
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading           = false;
  bool _obscurePassword     = true;
  bool _obscureCandPassword = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [

          // ── Decorative top gradient ────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: size.height * 0.48,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primary, _primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
          ),

          // ── Decorative circles ─────────────────────────────────────────
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06), // Updated from withOpacity
              ),
            ),
          ),
          Positioned(
            top: 60, right: 30,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08), // Updated from withOpacity
              ),
            ),
          ),
          Positioned(
            top: 120, left: -30,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05), // Updated from withOpacity
              ),
            ),
          ),

          // ── Main content ───────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [

                  // ── Branding ─────────────────────────────────────────
                  SizedBox(height: size.height * 0.06),
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15), // Updated from withOpacity
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25), width: 1.5), // Updated
                    ),
                    child: const Icon(Icons.school_outlined,
                        color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AIXam',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Smart Exam Monitoring Platform',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.65)), // Updated
                  ),

                  SizedBox(height: size.height * 0.05),

                  // ── Login card ────────────────────────────────────────
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: _divider),
                      boxShadow: [
                        BoxShadow(
                          color: _primary.withValues(alpha: 0.12), // Updated
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: _text),
                        ),
                        const SizedBox(height: 20),

                        // ── Tab selector ────────────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _divider),
                          ),
                          child: Row(
                            children: [
                              _buildTab('Candidate', 0, Icons.person_outline),
                              _buildTab('Staff',    1, Icons.badge_outlined),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Tab content ──────────────────────────────
                        if (_selectedTab == 0)
                          _buildCandidateForm()
                        else
                          _buildStaffForm(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab button ────────────────────────────────────────────────────────────
  Widget _buildTab(String label, int index, IconData icon) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
              colors: [_primary, _primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected ? Colors.white : _sub, size: 16),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : _sub)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Candidate login form (reg number + password) ──────────────────────────
  Widget _buildCandidateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Info banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: 0.06), // Updated
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _primary.withValues(alpha: 0.15)), // Updated
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: _primary, size: 16),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Login using your registration number provided by admin.',
                  style: TextStyle(fontSize: 12, color: _primary),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Registration number field
        const Text('Registration Number',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _text)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _primary.withValues(alpha: 0.15)), // Updated
          ),
          child: TextField(
            controller: _regNumberController,
            style: const TextStyle(fontSize: 14, color: _text),
            decoration: InputDecoration(
              hintText: 'e.g. APP2024001',
              hintStyle:
              TextStyle(color: _sub.withValues(alpha: 0.6), fontSize: 14), // Updated
              prefixIcon: Icon(Icons.numbers,
                  color: _primary.withValues(alpha: 0.6), size: 20), // Updated
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Password field
        const Text('Password',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _text)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _primary.withValues(alpha: 0.15)), // Updated
          ),
          child: TextField(
            controller: _candPasswordController,
            obscureText: _obscureCandPassword,
            style: const TextStyle(fontSize: 14, color: _text),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle:
              TextStyle(color: _sub.withValues(alpha: 0.6), fontSize: 14), // Updated
              prefixIcon: Icon(Icons.lock_outline,
                  color: _primary.withValues(alpha: 0.6), size: 20), // Updated
              suffixIcon: GestureDetector(
                onTap: () => setState(
                        () => _obscureCandPassword = !_obscureCandPassword),
                child: Icon(
                  _obscureCandPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _sub,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Login button
        GestureDetector(
          onTap: _isLoading ? null : _candidateLogin,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_primary, _primaryLight],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.35), // Updated
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: _isLoading
                ? const Center(
              child: SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              ),
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Login',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Sign up link
        Center(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const candidate_signup(title: '')),
            ),
            child: RichText(
              text: const TextSpan(
                text: "Don't have an account? ",
                style: TextStyle(fontSize: 13, color: _sub),
                children: [
                  TextSpan(
                    text: 'Sign up',
                    style: TextStyle(
                        color: _primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Staff login form (email + password) ───────────────────────────────────
  Widget _buildStaffForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Email field
        const Text('Email Address',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _text)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _primary.withValues(alpha: 0.15)), // Updated
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontSize: 14, color: _text),
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle:
              TextStyle(color: _sub.withValues(alpha: 0.6), fontSize: 14), // Updated
              prefixIcon: Icon(Icons.email_outlined,
                  color: _primary.withValues(alpha: 0.6), size: 20), // Updated
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Password field
        const Text('Password',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _text)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _primary.withValues(alpha: 0.15)), // Updated
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(fontSize: 14, color: _text),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle:
              TextStyle(color: _sub.withValues(alpha: 0.6), fontSize: 14), // Updated
              prefixIcon: Icon(Icons.lock_outline,
                  color: _primary.withValues(alpha: 0.6), size: 20), // Updated
              suffixIcon: GestureDetector(
                onTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                child: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _sub,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Login button
        GestureDetector(
          onTap: _isLoading ? null : _staffLogin,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_primary, _primaryLight],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.35), // Updated
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: _isLoading
                ? const Center(
              child: SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              ),
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Login',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Candidate login API call ───────────────────────────────────────────────
  Future<void> _candidateLogin() async {
    setState(() => _isLoading = true);

    String regNumber = _regNumberController.text.trim();
    String password  = _candPasswordController.text.trim();

    if (regNumber.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields");
      setState(() => _isLoading = false);
      return;
    }

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');

    if (url == null || url.isEmpty) {
      Fluttertoast.showToast(msg: "Server URL not set");
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$url/candidate_login/'),
        body: {
          'reg_number': regNumber,
          'password'  : password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'ok') {
          String lid = data['lid'].toString();
          sh.setString("lid", lid);
          Fluttertoast.showToast(msg: "Login Successful");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CandidateHome()),
          );
        } else {
          Fluttertoast.showToast(
              msg: data['message'] ?? "Invalid credentials");
        }
      } else {
        Fluttertoast.showToast(
            msg: "Network Error: ${response.statusCode}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Staff login API call ──────────────────────────────────────────────────
  Future<void> _staffLogin() async {
    setState(() => _isLoading = true);

    String email    = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields");
      setState(() => _isLoading = false);
      return;
    }

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');

    if (url == null || url.isEmpty) {
      Fluttertoast.showToast(msg: "Server URL not set");
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$url/Applogin_post/'),
        body: {
          'Username': email,
          'Password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'ok') {
          String lid  = data['lid'].toString();
          String type = data['type'].toString();
          sh.setString("lid", lid);
          Fluttertoast.showToast(msg: "Login Successful");

          if (type == 'examiner') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const StaffHome()), // Make sure class name matches UpperCamelCase
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CandidateHome()),
            );
          }
        } else {
          Fluttertoast.showToast(msg: "Invalid credentials");
        }
      } else {
        Fluttertoast.showToast(
            msg: "Network Error: ${response.statusCode}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }
}