import 'dart:convert';
import 'dart:io';
import 'package:ai_watcher/Staff/view_question.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../login.dart';
import 'staff_home.dart';

// ─── Theme (same as all pages) ────────────────────────────────────────────────
const _primary      = Color(0xFF194569);
const _primaryLight = Color(0xFF2A6096);
const _bg           = Color(0xFFF0F4F8);
const _card         = Colors.white;
const _text         = Color(0xFF0D1F2D);
const _sub          = Color(0xFF607D8B);
const _divider      = Color(0xFFE8EEF4);
// ─────────────────────────────────────────────────────────────────────────────

class changepassword extends StatefulWidget {
  const changepassword({super.key});

  @override
  State<changepassword> createState() => _changepasswordState();
}

class _changepasswordState extends State<changepassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentpasswordcontroller  = TextEditingController();
  final TextEditingController _newpasswordcontroller      = TextEditingController();
  final TextEditingController _confirmpasswordcontroller  = TextEditingController();

  bool _obscureCurrent  = true;
  bool _obscureNew      = true;
  bool _obscureConfirm  = true;
  bool _isLoading       = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _sendData() async {
    String currentpassword = _currentpasswordcontroller.text;
    String newpassword     = _newpasswordcontroller.text;
    String confirmpassword = _confirmpasswordcontroller.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url  = sh.getString('url');
    String? exam = sh.getString('exam');
    String? lid  = sh.getString('lid');

    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    setState(() => _isLoading = true);

    final uri     = Uri.parse('$url/app_changepassword/');
    var   request = http.MultipartRequest('POST', uri);
    request.fields['currentpassword'] = currentpassword;
    request.fields['newpassword']     = newpassword;
    request.fields['confirmpassword'] = confirmpassword;
    request.fields['lid']             = lid.toString();

    try {
      var response = await request.send();
      var respStr  = await response.stream.bytesToString();
      var data     = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Password changed successfully.");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen(title: '')),
        );
      } else {
        Fluttertoast.showToast(msg: "Incorrect Password.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Reusable field builder ───────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: _text)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _primary.withOpacity(0.15)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(fontSize: 14, color: _text),
            decoration: InputDecoration(
              hintText: 'Enter your ${label.toLowerCase()}',
              hintStyle:
              TextStyle(color: _sub.withOpacity(0.6), fontSize: 13),
              prefixIcon:
              Icon(icon, color: _primary.withOpacity(0.6), size: 20),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _sub,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              errorStyle: const TextStyle(fontSize: 11),
            ),
            validator: validator,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Section header ────────────────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 4),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [_primary, _primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StaffHome()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [

            // ── Gradient Header ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primary, _primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Stack(
                children: [

                  // Decorative circles
                  Positioned(
                    top: -30, right: -30,
                    child: Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10, right: 30,
                    child: Container(
                      width: 55, height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 30, left: -15,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),

                  // Header content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Top bar — back + title
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const StaffHome()),
                            ),
                            child: Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.2)),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Change Password',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                                Text('Update your account security',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white60)),
                              ],
                            ),
                          ),
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2)),
                            ),
                            child: const Icon(Icons.lock_outline,
                                color: Colors.white, size: 20),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Lock icon + info row
                      Row(
                        children: [
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                  width: 1.5),
                            ),
                            child: const Icon(Icons.security_outlined,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Secure your account',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Choose a strong password to keep your account safe.',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.65),
                                      height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Form body ──────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 60),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Password card ──────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _divider),
                          boxShadow: [
                            BoxShadow(
                              color: _primary.withOpacity(0.07),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader('Password Details',
                                Icons.lock_outline),

                            _buildField(
                              controller: _currentpasswordcontroller,
                              label: 'Current Password',
                              icon: Icons.lock_outline,
                              obscure: _obscureCurrent,
                              onToggle: () => setState(
                                      () => _obscureCurrent = !_obscureCurrent),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty)
                                  return 'Current password is required';
                                return null;
                              },
                            ),

                            _buildField(
                              controller: _newpasswordcontroller,
                              label: 'New Password',
                              icon: Icons.lock_reset_outlined,
                              obscure: _obscureNew,
                              onToggle: () =>
                                  setState(() => _obscureNew = !_obscureNew),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty)
                                  return 'New password is required';
                                if (value.length < 6)
                                  return 'Password must be at least 6 characters';
                                return null;
                              },
                            ),

                            _buildField(
                              controller: _confirmpasswordcontroller,
                              label: 'Confirm New Password',
                              icon: Icons.lock_clock_outlined,
                              obscure: _obscureConfirm,
                              onToggle: () => setState(
                                      () => _obscureConfirm = !_obscureConfirm),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty)
                                  return 'Please confirm your password';
                                if (value != _newpasswordcontroller.text)
                                  return 'Passwords do not match';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Tips card ──────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border:
                          Border.all(color: _primary.withOpacity(0.12)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 30, height: 30,
                              decoration: BoxDecoration(
                                color: _primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.info_outline,
                                  color: _primary.withOpacity(0.7), size: 16),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Use at least 6 characters with a mix of letters, numbers and symbols for a stronger password.',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: _sub,
                                    height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Submit button ──────────────────────────────────
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                          if (_formKey.currentState!.validate()) {
                            _sendData();
                          } else {
                            Fluttertoast.showToast(
                                msg: "Please fix errors in the form");
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding:
                          const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_primary, _primaryLight],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _primary.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: _isLoading
                              ? const Center(
                            child: SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5),
                            ),
                          )
                              : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 10),
                              Text('Update Password',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Cancel button ──────────────────────────────────
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const StaffHome()),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding:
                          const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: _primary.withOpacity(0.25),
                                width: 1.5),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close_rounded,
                                  color: _primary, size: 18),
                              SizedBox(width: 10),
                              Text('Cancel',
                                  style: TextStyle(
                                      color: _primary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}