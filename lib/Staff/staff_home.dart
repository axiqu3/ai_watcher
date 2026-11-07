// import 'package:fluttertoast/fluttertoast.dart';
// import 'changepassword.dart';
import 'dart:async';
import 'dart:convert';
import 'package:ai_watcher/Staff/view_alerts.dart';
import 'package:ai_watcher/Staff/view_payment.dart';
import 'package:ai_watcher/Staff/viewallocatedexam.dart';
import 'package:ai_watcher/Staff/viewcomplaint.dart';
import 'package:ai_watcher/Staff/viewprofile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../login.dart';
import 'notification.dart';
import 'staff_settings.dart';

// ─── Theme ────────────────────────────────────────────────────────────────────
const kPrimary      = Color(0xFF194569);
const kPrimaryLight = Color(0xFF2A6096);
const kBg           = Color(0xFFF0F4F8);
const kCard         = Colors.white;
const kText         = Color(0xFF0D1F2D);
const kSubText      = Color(0xFF607D8B);
const kDivider      = Color(0xFFE8EEF4);
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: StaffHome(), // Fixed to use the correct UpperCamelCase class name
  ));
}

class StaffHome extends StatefulWidget {
  const StaffHome({super.key});

  @override
  State<StaffHome> createState() => _StaffHomeState();
}

class _StaffHomeState extends State<StaffHome> {
  String name_  = '';
  String photo_ = '';
  String lid_   = '';
  int _currentIndex = 0;

  String _lastMessage = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getData();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchNotifi());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── API calls ──────────────────────────────────────────────────────────────
  Future<void> _fetchNotifi() async {
    if (!mounted) return;
    final sh  = await SharedPreferences.getInstance();
    final url = sh.getString('url') ?? '';
    final lid = sh.getString('lid') ?? '';
    final nid = sh.getString('nid') ?? '0';
    if (url.isEmpty || lid.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$url/view_notification/'),
        body: {'lid': lid, 'nid': nid},
      );
      if (response.statusCode != 200) return;
      final jsondata = json.decode(response.body);
      if (jsondata['status'] != 'ok') return;

      final notifications = jsondata['notifications'] as List<dynamic>;
      if (notifications.isEmpty) return;

      final latest  = notifications.last;
      final message = latest['message']?.toString() ?? 'New notification';
      final newNid  = latest['nid'].toString();

      if (message != _lastMessage) {
        _lastMessage = message;
        await sh.setString('nid', newNid);
        if (!mounted) return;
        _callbackDispatcher(message);
        _showAlertDialog(context, message);
      }
    } catch (_) {}
  }

void _callbackDispatcher(String message) async {
    final flip = FlutterLocalNotificationsPlugin();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    await flip.initialize(
      settings: const InitializationSettings(android: android),
    );
    
    _showLocalNotification(flip, message);
  }

  Future<void> _showLocalNotification(
      FlutterLocalNotificationsPlugin flip, String message) async {
    await flip.show(
      id: 0,
      title: 'Notification',
      body: message,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'rescue_channel_id',
          'Rescue Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  void _showAlertDialog(BuildContext context, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_outlined,
                color: kPrimary, size: 20),
          ),
          const SizedBox(width: 10),
          const Text('Notification',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
        ]),
        content: Text(message,
            style: const TextStyle(fontSize: 14, color: kSubText)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('OK',
                style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _getData() async {
    final sh  = await SharedPreferences.getInstance();
    final url = sh.getString('url') ?? '';
    final lid = sh.getString('lid') ?? '';
    final img = sh.getString('img_url') ?? '';
    if (url.isEmpty || lid.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$url/examinerviewprofile/'),
        body: {'lid': lid},
      );
      if (response.statusCode != 200) return;
      final data = jsonDecode(response.body);
      if (data['status'] == 'ok') {
        setState(() {
          name_  = data['name'].toString();
          photo_ = img + data['photo'].toString();
          lid_   = lid;
        });
      }
    } catch (_) {}
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final pages = [
      // 0 - Home
      _HomeBody(getName: () => name_, getPhoto: () => photo_),
      // 1 - Notifications
      const ViewNotification(),
      // 2 - Profile
      viewprofile(title: ''),
      // 3 - Settings
      const StaffSettingsPage(),
    ];

    return Scaffold(
      backgroundColor: kBg,
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_outlined,             Icons.home_rounded,               'Home'),
              _navItem(1, Icons.notifications_none_rounded, Icons.notifications_rounded,     'Notification'),
              _navItem(2, Icons.person_outline_rounded,     Icons.person_rounded,            'Profile'),
              _navItem(3, Icons.tune_outlined,              Icons.tune_rounded,              'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final bool selected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kPrimary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  selected ? activeIcon : icon,
                  color: selected ? kPrimary : kSubText,
                  size: 24,
                ),
                if (index == 1)
                  Positioned(
                    top: -2, right: -4,
                    child: Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? kPrimary : kSubText)),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ── Home Body ────────────────────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
class _HomeBody extends StatelessWidget {
  final String Function() getName;
  final String Function() getPhoto;

  const _HomeBody({required this.getName, required this.getPhoto});

  @override
  Widget build(BuildContext context) {
    final name  = getName();
    final photo = getPhoto();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Gradient Header ──────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimary, kPrimaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(top: -30, right: -30,
                    child: Container(width: 120, height: 120,
                        decoration: BoxDecoration(shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06)))),
                Positioned(top: 10, right: 30,
                    child: Container(width: 55, height: 55,
                        decoration: BoxDecoration(shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08)))),
                Positioned(top: 30, left: -15,
                    child: Container(width: 80, height: 80,
                        decoration: BoxDecoration(shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05)))),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.4), width: 2),
                          ),
                          child: ClipOval(
                            child: photo.isNotEmpty
                                ? Image.network(photo, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: kPrimaryLight,
                                    child: const Icon(Icons.person,
                                        color: Colors.white, size: 24)),)
                                : Container(color: kPrimaryLight,
                                child: const Icon(Icons.person,
                                    color: Colors.white, size: 24)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, ${name.isNotEmpty ? name.split(' ').first : 'Examiner'}! 👋',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w800,
                                    color: Colors.white),
                              ),
                              Text('Good to have you back',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7))),
                            ],
                          ),
                        ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.2)),
                              ),
                              child: const Icon(Icons.notifications_outlined,
                                  color: Colors.white, size: 20),
                            ),
                            Positioned(
                              top: -2, right: -2,
                              child: Container(
                                width: 10, height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Search bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search,
                              color: Colors.white.withOpacity(0.7), size: 20),
                          const SizedBox(width: 10),
                          Text('Search exams, candidates...',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 13)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stats row
                    Row(
                      children: [
                        _statChip(Icons.assignment_outlined,    'Exams',      '12'),
                        const SizedBox(width: 10),
                        _statChip(Icons.people_outline,         'Candidates', '84'),
                        const SizedBox(width: 10),
                        _statChip(Icons.warning_amber_outlined, 'Alerts',     '3'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Welcome Banner ───────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPrimary, kPrimaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kPrimary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome to AI Watcher!',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 6),
                        Text(
                          'Manage exam sessions &\nmonitor candidates with AI.',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12, height: 1.5),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          child: const Text('View Dashboard',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.25)),
                    ),
                    child: const Icon(Icons.security_outlined,
                        color: Colors.white, size: 36),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Quick Actions ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Quick Actions',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700,
                            color: kText)),
                    Text('See all',
                        style: TextStyle(
                            fontSize: 12, color: kPrimary.withOpacity(0.8),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
                  children: [
                    _ActionCard(
                      title: 'Exams',
                      icon: Icons.assignment_outlined,
                      color: const Color(0xFF1565C0),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => viewallocatedexam(title: ''))),
                    ),
                    _ActionCard(
                      title: 'Alerts',
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFEF4444),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => view_alerts(title: ''))),
                    ),
                    _ActionCard(
                      title: 'Payment',
                      icon: Icons.payment_rounded,
                      color: const Color(0xFF2E7D32),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => viewpayment(title: ''))),
                    ),
                    _ActionCard(
                      title: 'Notifications',
                      icon: Icons.notifications_active_outlined,
                      color: const Color(0xFF6A1B9A),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const ViewNotification())),
                    ),
                    _ActionCard(
                      title: 'Complaints',
                      icon: Icons.report_problem_outlined,
                      color: const Color(0xFFE65100),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const viewcomplaint(title: ''))),
                    ),
                    _ActionCard(
                      title: 'Settings',
                      icon: Icons.tune_rounded,
                      color: const Color(0xFF00695C),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const StaffSettingsPage())),
                    ),
                    _ActionCard(
                      title: 'Logout',
                      icon: Icons.logout_rounded,
                      color: const Color(0xFF546E7A),
                      onTap: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen(title: '')),
                        (route) => false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _statChip(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800)),
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 9)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ── Action Card ──────────────────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
    this.color = kPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kDivider),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    color: kText, fontSize: 11,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}