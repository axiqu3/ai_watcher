import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'staff_home.dart';           // staff_home
import 'changepassword.dart';       // changepassword
import '../login.dart';
import 'viewprofile.dart';             // login

// ─── Theme (same as all pages) ────────────────────────────────────────────────
const kPrimary      = Color(0xFF194569);
const kPrimaryLight = Color(0xFF2A6096);
const kBg           = Color(0xFFF0F4F8);
const kCard         = Colors.white;
const kText         = Color(0xFF0D1F2D);
const kSubText      = Color(0xFF607D8B);
const kDivider      = Color(0xFFE8EEF4);
// ─────────────────────────────────────────────────────────────────────────────

class StaffSettingsPage extends StatefulWidget {
  const StaffSettingsPage({super.key});

  @override
  State<StaffSettingsPage> createState() => _StaffSettingsPageState();
}

class _StaffSettingsPageState extends State<StaffSettingsPage> {
  // ── Profile data ───────────────────────────────────────────────────────────
  String _staffName  = '';
  String _staffEmail = '';
  String _staffPhoto = '';
  String _staffRole  = 'Staff';
  bool   _profileLoading = true;

  // ── Toggle states ──────────────────────────────────────────────────────────
  bool _notifNewCandidate    = true;
  bool _notifExamStarted     = true;
  bool _notifResults         = false;
  bool _notifAnnouncements   = true;
  bool _notifEmail           = false;
  bool _darkMode             = false;
  bool _biometric            = false;
  bool _autoGrading          = true;
  bool _showLiveCount        = true;
  bool _suspiciousAlert      = true;
  bool _twoFactorAuth        = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ── Load profile ───────────────────────────────────────────────────────────
  Future<void> _loadProfile() async {
    setState(() => _profileLoading = true);
    try {
      final sh   = await SharedPreferences.getInstance();
      final url  = sh.getString('url') ?? '';
      final lid  = sh.getString('lid') ?? '';
      final imgBaseUrl = sh.getString('img_url') ?? '';

      if (url.isEmpty || lid.isEmpty) {
        setState(() => _profileLoading = false);
        return;
      }

      final response = await http.post(
        Uri.parse('$url/staffviewprofile/'),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            _staffName  = data['name']?.toString()  ?? '';
            _staffEmail = data['email']?.toString() ?? '';
            _staffRole  = data['role']?.toString()  ?? 'Staff';
            _staffPhoto = imgBaseUrl + (data['photo']?.toString() ?? '');
          });
        }
      }
    } catch (_) {
      // fail silently
    } finally {
      setState(() => _profileLoading = false);
    }
  }

  // ── Navigate helper ────────────────────────────────────────────────────────
  void _go(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StaffHome()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: kBg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App Bar ─────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader(context)),

            // ── Profile Card ─────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildProfileCard()),

            // ── Profile Section ──────────────────────────────────────────
            _sectionSliver('Profile', [
              _navTile(
                icon: Icons.person_outline,
                label: 'View & Edit Profile',
                subtitle: 'Name, photo, contact info',
                onTap:() => _go(const viewprofile(title: '',)),
              ),
              _navTile(
                icon: Icons.lock_outline,
                label: 'Change Password',
                subtitle: 'Update your login password',
                onTap: () => _go(const changepassword()),
              ),
              _navTile(
                icon: Icons.badge_outlined,
                label: 'Staff ID & Department',
                subtitle: 'View your staff credentials',
                onTap: _showComingSoonSnack,
              ),
            ]),

            // ── Notifications Section ────────────────────────────────────
            _sectionSliver('Notifications', [
              _toggleTile(
                icon: Icons.person_add_alt_1_outlined,
                label: 'New Candidate Enrolled',
                subtitle: 'Alert when a candidate is added to your exam',
                value: _notifNewCandidate,
                onChanged: (v) => setState(() => _notifNewCandidate = v),
              ),
              _toggleTile(
                icon: Icons.play_circle_outline,
                label: 'Exam Started Alerts',
                subtitle: 'Notified when an exam goes live',
                value: _notifExamStarted,
                onChanged: (v) => setState(() => _notifExamStarted = v),
              ),
              _toggleTile(
                icon: Icons.emoji_events_outlined,
                label: 'Result Published',
                subtitle: 'Know when results are released',
                value: _notifResults,
                onChanged: (v) => setState(() => _notifResults = v),
              ),
              _toggleTile(
                icon: Icons.campaign_outlined,
                label: 'Admin Announcements',
                subtitle: 'Important notices from admin',
                value: _notifAnnouncements,
                onChanged: (v) => setState(() => _notifAnnouncements = v),
              ),
              _toggleTile(
                icon: Icons.email_outlined,
                label: 'Email Notifications',
                subtitle: 'Receive alerts via email',
                value: _notifEmail,
                onChanged: (v) => setState(() => _notifEmail = v),
              ),
            ]),

            // ── Exam Management Section ──────────────────────────────────
            _sectionSliver('Exam Management', [
              _toggleTile(
                icon: Icons.auto_awesome_outlined,
                label: 'Auto Grading',
                subtitle: 'Automatically grade objective questions',
                value: _autoGrading,
                onChanged: (v) => setState(() => _autoGrading = v),
              ),
              _toggleTile(
                icon: Icons.people_alt_outlined,
                label: 'Show Live Candidate Count',
                subtitle: 'See how many are active during exam',
                value: _showLiveCount,
                onChanged: (v) => setState(() => _showLiveCount = v),
              ),
              _toggleTile(
                icon: Icons.warning_amber_rounded,
                label: 'Suspicious Activity Alerts',
                subtitle: 'Get alerted on tab switch / face mismatch',
                value: _suspiciousAlert,
                onChanged: (v) => setState(() => _suspiciousAlert = v),
              ),
              _navTile(
                icon: Icons.quiz_outlined,
                label: 'Manage Questions',
                subtitle: 'View, edit and delete questions',
                onTap: _showComingSoonSnack,
              ),
              _navTile(
                icon: Icons.assignment_outlined,
                label: 'Exam Reports',
                subtitle: 'Download or share exam summaries',
                onTap: _showComingSoonSnack,
              ),
              _navTile(
                icon: Icons.schedule_outlined,
                label: 'Schedule Exam',
                subtitle: 'Set date, time and duration',
                onTap: _showComingSoonSnack,
              ),
            ]),

            // ── Security Section ─────────────────────────────────────────
            _sectionSliver('Security', [
              _toggleTile(
                icon: Icons.security_outlined,
                label: 'Two-Factor Authentication',
                subtitle: 'Extra layer of login security',
                value: _twoFactorAuth,
                onChanged: (v) => setState(() => _twoFactorAuth = v),
              ),
              _navTile(
                icon: Icons.history_outlined,
                label: 'Login History',
                subtitle: 'See recent login activity',
                onTap: _showComingSoonSnack,
              ),
              _navTile(
                icon: Icons.devices_outlined,
                label: 'Active Sessions',
                subtitle: 'Manage logged-in devices',
                onTap: _showComingSoonSnack,
              ),
            ]),

            // ── Coming Soon Section ──────────────────────────────────────
            _sectionSliver('Coming Soon 🚀', [
              _comingSoonToggleTile(
                icon: Icons.dark_mode_outlined,
                label: 'Dark Mode',
                subtitle: 'Switch to a dark UI theme',
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
              _comingSoonToggleTile(
                icon: Icons.fingerprint,
                label: 'Biometric Login',
                subtitle: 'Use fingerprint or face unlock',
                value: _biometric,
                onChanged: (v) => setState(() => _biometric = v),
              ),
              _comingSoonNavTile(
                icon: Icons.analytics_outlined,
                label: 'Advanced Analytics Dashboard',
                subtitle: 'Deep insights on candidate performance',
              ),
              _comingSoonNavTile(
                icon: Icons.videocam_outlined,
                label: 'Live Proctoring Monitor',
                subtitle: 'Watch candidates in real-time',
              ),
              _comingSoonNavTile(
                icon: Icons.psychology_outlined,
                label: 'AI Question Generator',
                subtitle: 'Auto-generate questions using AI',
              ),
              _comingSoonNavTile(
                icon: Icons.bar_chart_outlined,
                label: 'Performance Comparison',
                subtitle: 'Compare candidates across exams',
              ),
              _comingSoonNavTile(
                icon: Icons.translate_outlined,
                label: 'Multi-Language Support',
                subtitle: 'Manage exams in multiple languages',
              ),
              _comingSoonNavTile(
                icon: Icons.cloud_upload_outlined,
                label: 'Bulk Question Import',
                subtitle: 'Upload questions from CSV / Excel',
              ),
              _comingSoonNavTile(
                icon: Icons.picture_as_pdf_outlined,
                label: 'PDF Report Export',
                subtitle: 'Export detailed results as PDF',
              ),
              _comingSoonNavTile(
                icon: Icons.chat_bubble_outline,
                label: 'In-App Messaging',
                subtitle: 'Chat with candidates during exam',
              ),
              _comingSoonNavTile(
                icon: Icons.integration_instructions_outlined,
                label: 'LMS Integration',
                subtitle: 'Connect with Moodle, Google Classroom',
              ),
              _comingSoonNavTile(
                icon: Icons.notifications_active_outlined,
                label: 'Custom Notification Templates',
                subtitle: 'Create your own alert messages',
              ),
            ]),

            // ── Account Actions ──────────────────────────────────────────
            _sectionSliver('Account', [
              _navTile(
                icon: Icons.info_outline,
                label: 'About App',
                subtitle: 'Version 1.0.0 — AI Watcher',
                onTap: () => _showAboutDialog(context),
              ),
              _navTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                subtitle: 'Read our data & privacy terms',
                onTap: _showComingSoonSnack,
              ),
              _navTile(
                icon: Icons.description_outlined,
                label: 'Terms & Conditions',
                subtitle: 'Staff usage agreement',
                onTap: _showComingSoonSnack,
              ),
              _dangerTile(
                icon: Icons.logout,
                label: 'Logout',
                subtitle: 'Sign out of your account',
                onTap: () => _confirmLogout(context),
              ),
            ]),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ── Widget builders ───────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimary, kPrimaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20, right: -20,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            top: 5, right: 50,
            child: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const StaffHome()),
                ),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Settings',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    Text('Manage your staff preferences',
                        style: TextStyle(fontSize: 13, color: Colors.white60)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(Icons.tune_rounded,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return GestureDetector(
      onTap: _showComingSoonSnack,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54, height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: kPrimary.withOpacity(0.3), width: 2),
                image: _staffPhoto.isNotEmpty
                    ? DecorationImage(
                    image: NetworkImage(_staffPhoto),
                    fit: BoxFit.cover)
                    : null,
              ),
              child: _staffPhoto.isEmpty
                  ? const Icon(Icons.person, color: kPrimary, size: 26)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _profileLoading
                  ? const SizedBox(
                height: 16,
                child: LinearProgressIndicator(
                  backgroundColor: Color(0xFFE8EEF4),
                  color: kPrimary,
                ),
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _staffName.isNotEmpty ? _staffName : 'Staff Member',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _staffRole,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: kPrimary),
                        ),
                      ),
                      if (_staffEmail.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _staffEmail,
                            style: const TextStyle(
                                fontSize: 12, color: kSubText),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _sectionSliver(String title, List<Widget> tiles) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 4),
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(children: _insertDividers(tiles)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _insertDividers(List<Widget> tiles) {
    final result = <Widget>[];
    for (int i = 0; i < tiles.length; i++) {
      result.add(tiles[i]);
      if (i < tiles.length - 1) {
        result.add(const Divider(
            height: 1, thickness: 1,
            indent: 56, endIndent: 16,
            color: kDivider));
      }
    }
    return result;
  }

  Widget _navTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: kPrimary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: kPrimary, size: 20),
      ),
      title: Text(label,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: kText)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: kSubText)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: kSubText, size: 20),
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: kPrimary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: kPrimary, size: 20),
      ),
      title: Text(label,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: kText)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: kSubText)),
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: kPrimary,
      ),
    );
  }

  Widget _comingSoonToggleTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Opacity(
      opacity: 0.55,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.grey, size: 20),
        ),
        title: Row(children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: kText)),
          ),
          _comingSoonBadge(),
        ]),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: kSubText)),
        trailing: CupertinoSwitch(
          value: value,
          onChanged: (_) => _showComingSoonSnack(),
          activeColor: Colors.grey,
        ),
      ),
    );
  }

  Widget _comingSoonNavTile({
    required IconData icon,
    required String label,
    required String subtitle,
  }) {
    return Opacity(
      opacity: 0.55,
      child: ListTile(
        onTap: _showComingSoonSnack,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.grey, size: 20),
        ),
        title: Row(children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: kText)),
          ),
          _comingSoonBadge(),
        ]),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: kSubText)),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: kSubText, size: 20),
      ),
    );
  }

  Widget _dangerTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.logout,
            color: Color(0xFFC0392B), size: 20),
      ),
      title: Text(label,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFC0392B))),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: kSubText)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: kSubText, size: 20),
    );
  }

  Widget _comingSoonBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFFFD700), width: 0.8),
      ),
      child: const Text('Soon',
          style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFF856404))),
    );
  }

  // ── Dialogs & Snacks ───────────────────────────────────────────────────────

  void _showComingSoonSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.rocket_launch_outlined, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('This feature is coming soon! 🚀',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: kPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.logout,
                  color: Color(0xFFC0392B), size: 28),
            ),
            const SizedBox(height: 14),
            const Text('Logout',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: kText)),
            const SizedBox(height: 6),
            const Text('Are you sure you want to sign out?',
                style: TextStyle(fontSize: 13, color: kSubText)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kDivider),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(
                            color: kText, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      SharedPreferences.getInstance().then((sh) {
                        sh.clear();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen(title: '')),
                              (route) => false,
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC0392B),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text('Logout',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [kPrimary, kPrimaryLight]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.school,
                  color: Colors.white, size: 32),
            ),
            const SizedBox(height: 14),
            const Text('AI Watcher',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kText)),
            const SizedBox(height: 4),
            const Text('Version 1.0.0',
                style: TextStyle(fontSize: 13, color: kSubText)),
            const SizedBox(height: 8),
            const Text(
              'AI-powered online exam proctoring platform for secure and fair assessments.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: kSubText),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close',
                style: TextStyle(
                    color: kPrimary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}