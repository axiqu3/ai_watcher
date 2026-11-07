import 'dart:convert';
import 'dart:ui';
import 'package:ai_watcher/candidate/view_marks.dart';
import 'package:ai_watcher/candidate/viewexam.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'settings_page.dart';
import 'changepassword.dart';
import 'upcomingExam.dart';
import 'viewprofile.dart';
import '../login.dart';
import 'viewreply.dart';

// ─── Theme Constants ─────────────────────────────────────────────────────────
const kPrimary      = Color(0xFF194569);
const kPrimaryLight = Color(0xFF2A6096);
const kAccent       = Color(0xFF1E88E5);
const kBg           = Color(0xFFF0F4F8);
const kCard         = Colors.white;
const kText         = Color(0xFF0D1F2D);
const kSubText      = Color(0xFF607D8B);
// ─────────────────────────────────────────────────────────────────────────────

class CandidateHome extends StatefulWidget {
  const CandidateHome({super.key});

  @override
  State<CandidateHome> createState() => _CandidateHomeState();
}

class _CandidateHomeState extends State<CandidateHome>
    with SingleTickerProviderStateMixin {
  String name  = 'Candidate';
  String photo = '';
  bool _isLoading    = true;
  int  _selectedIndex = 0;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  // Swipeable exam data — loaded from API (max 3)
  final PageController _examPageController =
  PageController(viewportFraction: 0.92);
  int _currentExamPage = 0;

  // Real exam data from API
  List<Map<String, dynamic>> _exams = [];
  bool _examsLoading = true;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    _fetchProfileData();
    _fetchUpcomingExams();
  }

  @override
  void dispose() {
    _examPageController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileData() async {
    setState(() => _isLoading = true);

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url        = sh.getString('url');
    String? lid        = sh.getString('lid');
    String? imgBaseUrl = sh.getString('img_url') ?? '';

    if (url == null || lid == null) {
      Fluttertoast.showToast(msg: "Server URL or login ID not found.");
      setState(() => _isLoading = false);
      return;
    }

    final uri = Uri.parse('$url/candidateviewprofile/');
    try {
      final response = await http.post(uri, body: {'lid': lid});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            name  = data['name']?.toString() ?? 'Candidate';
            photo = imgBaseUrl + (data['photo']?.toString() ?? '');
          });
        } else {
          Fluttertoast.showToast(msg: "Profile not found");
        }
      } else {
        Fluttertoast.showToast(msg: "Network Error");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
      _animCtrl.forward();
    }
  }

  // ── Fetch upcoming exams (same API as UpcomingExam page, max 3) ─────────────
  Future<void> _fetchUpcomingExams() async {
    setState(() => _examsLoading = true);
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      String? lid = sh.getString('lid');

      if (url == null || lid == null) return;

      final apiUrl = Uri.parse('$url/studentviewupcomingexam/');
      final response = await http.post(apiUrl, body: {'lid': lid});

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'ok') {
          List<Map<String, dynamic>> tempList = [];
          for (var item in jsonData['data']) {
            tempList.add({
              'id'              : item['id'].toString(),
              'exam'            : item['exam'].toString(),
              'examname'        : item['examname'].toString(),
              'startdate'       : item['startdate'].toString(),
              'starttime'       : item['starttime'].toString(),
              'enddate'         : item['enddate'].toString(),
              'endtime'         : item['endtime'].toString(),
              'examinerlid'     : item['examinerlid'].toString(),
              'enaminername'    : item['enaminername'].toString(),
              'already_attended': item['already_attended'] ?? false,
            });
          }
          setState(() {
            // Show only first 3 exams on home page
            _exams = tempList.take(3).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Exam fetch error: $e');
    } finally {
      setState(() => _examsLoading = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const viewexam(title: '')));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const UserVIewProfilepagespages(title: '',)))
            .then((_) => setState(() => _selectedIndex = 0)); // reset on return
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SettingsPage()))
            .then((_) => setState(() => _selectedIndex = 0)); // reset on return
        break;
    }
  }

  final List<Map<String, dynamic>> _quickItems = [
    {'label': 'View Exams',    'icon': Icons.description_outlined, 'color': Color(0xFF1E6B9E)},
    {'label': 'Complaint',     'icon': Icons.feedback_outlined,    'color': Color(0xFF1A7A6E)},
    {'label': 'Upcoming Exam', 'icon': Icons.event_note_outlined,  'color': Color(0xFF6A3FA0)},
    {'label': 'View Marks',    'icon': Icons.grade_outlined,       'color': Color(0xFFB85C00)},
    {'label': 'Settings',    'icon': Icons.settings_outlined,       'color': Color(0xFF3CB7B7)},
    {'label': 'Logout',        'icon': Icons.logout,               'color': Color(0xFFC0392B)},
  ];

  void _onQuickTap(String label) {
    switch (label) {
      case 'View Exams':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const viewexam(title: '')));
        break;
      case 'Complaint':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const viewreplypage(title: '')));
        break;
      case 'Upcoming Exam':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const UpcomingExam()));
        break;
      case 'View Marks':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const view_marks(title: '')));
        break;
      case 'Settings':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SettingsPage()));
        break;
      case 'Logout':
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LoginScreen(title: '')));
        break;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      extendBodyBehindAppBar: true,
      body: _isLoading
          ? _buildLoader()
          : FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ─────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildHeader()),

              // ── Stats Row ───────────────────────────────────────────
              SliverToBoxAdapter(child: _buildStatsRow()),

              // ── Upcoming Exams title ────────────────────────────────
              SliverToBoxAdapter(
                child: _sectionHeader(
                  'Upcoming Exams',
                  action: 'View All',
                  onAction: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UpcomingExam()),
                  ),
                ),
              ),

              // ── Swipeable cards ─────────────────────────────────────
              SliverToBoxAdapter(
                child: _examsLoading
                    ? SizedBox(
                  height: 218,
                  child: Center(
                    child: CircularProgressIndicator(
                        color: kPrimary, strokeWidth: 2.5),
                  ),
                )
                    : _exams.isEmpty
                    ? SizedBox(
                  height: 218,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            color: kPrimary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.event_busy_outlined,
                              color: kPrimary, size: 28),
                        ),
                        const SizedBox(height: 10),
                        const Text('No upcoming exams',
                            style: TextStyle(
                                fontSize: 13,
                                color: kSubText,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                )
                    : SizedBox(
                  height: 218,
                  child: PageView.builder(
                    controller: _examPageController,
                    itemCount: _exams.length,
                    onPageChanged: (i) =>
                        setState(() => _currentExamPage = i),
                    itemBuilder: (ctx, i) =>
                        _buildExamCard(_exams[i], i),
                  ),
                ),
              ),

              // ── Dot indicators ──────────────────────────────────────
              if (!_examsLoading && _exams.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _exams.length,
                            (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width:  _currentExamPage == i ? 22 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _currentExamPage == i
                                ? kPrimary
                                : kPrimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Quick Access title ──────────────────────────────────
              SliverToBoxAdapter(
                child: _sectionHeader('Quick Access'),
              ),

              // ── Grid ────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _buildGridItem(_quickItems[i]),
                    childCount: _quickItems.length,
                  ),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.80,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Loading screen ──────────────────────────────────────────────────────────
  Widget _buildLoader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimary, kPrimaryLight],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            SizedBox(height: 16),
            Text('Loading...',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 56, 22, 28),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.35),
                          Colors.white.withOpacity(0.08),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(2.5),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.55),
                              width: 1.5),
                          image: photo.isNotEmpty
                              ? DecorationImage(
                              image: NetworkImage(photo),
                              fit: BoxFit.cover)
                              : null,
                        ),
                        child: photo.isEmpty
                            ? const Icon(Icons.person,
                            color: Colors.white, size: 22)
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 1, bottom: 1,
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: kPrimary, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_getGreeting(),
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                                letterSpacing: 0.2)),
                        const SizedBox(width: 4),
                        const Text('👋', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    Text(
                      name.split(' ').first,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.1),
                    ),
                  ],
                ),
              ),
              _headerIconBtn(
                icon: Icons.notifications_outlined,
                badge: true,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 22),

          RichText(
            text: const TextSpan(
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.35,
                  letterSpacing: -0.3),
              children: [
                TextSpan(text: 'Ready for your\n'),
                TextSpan(text: 'next exam? '),
                TextSpan(text: '🎯', style: TextStyle(fontSize: 22)),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    color: Colors.white.withOpacity(0.5), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Search exams, subjects...',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 14,
                        letterSpacing: 0.1),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('⌘ K',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIconBtn({
    required IconData icon,
    bool badge = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.13),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                  color: Colors.white.withOpacity(0.2), width: 1),
            ),
            child: Icon(icon, color: Colors.white, size: 21),
          ),
          if (badge)
            Positioned(
              right: 9, top: 9,
              child: Container(
                width: 9, height: 9,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252),
                  shape: BoxShape.circle,
                  border: Border.all(color: kPrimary, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Stats row ───────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          _statCard(
            '${_exams.length}',
            'Exams\nScheduled',
            Icons.event_note_outlined,
            const Color(0xFF1565C0),
          ),
          const SizedBox(width: 12),
          _statCard('2', 'Results\nPending',
              Icons.hourglass_bottom_rounded, const Color(0xFF6A3FA0)),
          const SizedBox(width: 12),
          _statCard('87%', 'Avg\nScore', Icons.show_chart_rounded,
              const Color(0xFF1A7A6E)),
        ],
      ),
    );
  }

  Widget _statCard(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 17),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1)),
            const SizedBox(height: 3),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: kSubText, height: 1.3)),
          ],
        ),
      ),
    );
  }

  // ── Section header ──────────────────────────────────────────────────────────
  Widget _sectionHeader(String title,
      {String? action, VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4, height: 18,
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kText,
                      letterSpacing: -0.2)),
            ],
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(action,
                    style: const TextStyle(
                        fontSize: 12,
                        color: kPrimary,
                        fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }

  // ── Exam card (real API data) ────────────────────────────────────────────────
  Widget _buildExamCard(Map<String, dynamic> exam, int index) {
    // All cards use the same brand color theme
    const colors = [kPrimary, kPrimaryLight];

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 10, 8, 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.32),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20, right: -20,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -30, left: -10,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + status
                Row(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.15), width: 1),
                      ),
                      child: const Icon(Icons.school_outlined,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exam['examname'] ?? 'Exam',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.2),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            exam['enaminername'] ?? '',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF4CAF50).withOpacity(0.45),
                          width: 1,
                        ),
                      ),
                      child: const Text('Upcoming',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Info chips
                Row(
                  children: [
                    _examInfoChip(Icons.calendar_today_outlined,
                        exam['startdate'] ?? ''),
                    const SizedBox(width: 8),
                    _examInfoChip(Icons.access_time_rounded,
                        exam['starttime'] ?? ''),
                    const SizedBox(width: 8),
                    _examInfoChip(Icons.stop_circle_outlined,
                        exam['endtime'] ?? ''),
                  ],
                ),
                const SizedBox(height: 14),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: _examBtn(
                        'Re-Schedule',
                        Icons.event_repeat_rounded,
                        filled: false,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const UpcomingExam())),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _examBtn(
                        'View All',
                        Icons.list_alt_rounded,
                        filled: true,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const UpcomingExam())),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _examInfoChip(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.11),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
              color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white60, size: 11),
            const SizedBox(width: 4),
            Flexible(
              child: Text(text,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 9.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _examBtn(
      String label,
      IconData icon, {
        required bool filled,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(11),
          border: filled
              ? null
              : Border.all(
              color: Colors.white.withOpacity(0.28), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 14,
                color: filled ? kPrimary : Colors.white),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: filled ? kPrimary : Colors.white)),
          ],
        ),
      ),
    );
  }

  // ── Quick access grid item ──────────────────────────────────────────────────
  Widget _buildGridItem(Map<String, dynamic> item) {
    final color = item['color'] as Color;
    return GestureDetector(
      onTap: () => _onQuickTap(item['label'] as String),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              color: color.withOpacity(0.09),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.18), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(item['icon'] as IconData, color: color, size: 24),
          ),
          const SizedBox(height: 7),
          Text(
            item['label'] as String,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: kText,
                height: 1.3),
          ),
        ],
      ),
    );
  }

  // ── Bottom nav ──────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final icons = [
      Icons.home_rounded,
      Icons.calendar_month_rounded,
      Icons.person_rounded,
      Icons.settings_rounded,
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 68,
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (i) => _navIcon(icons[i], i)),
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    final active = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withOpacity(0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: active ? Colors.white : Colors.white38,
                size: active ? 26 : 23),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width:  active ? 5 : 0,
              height: active ? 5 : 0,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}





//
// import 'dart:convert';
// import 'dart:ui';
// import 'package:ai_watcher/candidate/view_marks.dart';
// import 'package:ai_watcher/candidate/viewexam.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// import 'changepassword.dart';
// import 'upcomingExam.dart';
// import 'viewprofile.dart';
// import '../login.dart';
// import 'viewreply.dart';
//
// class CandidateHome extends StatefulWidget {
//   const CandidateHome({super.key});
//
//   @override
//   State<CandidateHome> createState() => _CandidateHomeState();
// }
//
// class _CandidateHomeState extends State<CandidateHome> {
//   String name = 'Candidate';
//   String photo = '';
//   bool _isLoading = true;
//   int _selectedIndex = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchProfileData();
//   }
//
//   Future<void> _fetchProfileData() async {
//     setState(() => _isLoading = true);
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String? url = sh.getString('url');
//     String? lid = sh.getString('lid');
//     String? imgBaseUrl = sh.getString('img_url') ?? '';
//
//     if (url == null || lid == null) {
//       Fluttertoast.showToast(msg: "Server URL or login ID not found.");
//       setState(() => _isLoading = false);
//       return;
//     }
//
//     final uri = Uri.parse('$url/candidateviewprofile/');
//
//     try {
//       final response = await http.post(uri, body: {'lid': lid});
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == 'ok') {
//           setState(() {
//             name = data['name']?.toString() ?? 'Candidate';
//             photo = imgBaseUrl + (data['photo']?.toString() ?? '');
//           });
//         } else {
//           Fluttertoast.showToast(msg: "Profile not found");
//         }
//       } else {
//         Fluttertoast.showToast(msg: "Network Error");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error: $e");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   String _getGreeting() {
//     final hour = DateTime.now().hour;
//     if (hour < 12) return 'Good morning';
//     if (hour < 17) return 'Good afternoon';
//     return 'Good evening';
//   }
//
//   void _onBottomNavTap(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//
//     switch (index) {
//       case 0:
//         break;
//       case 1:
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const viewexam(title: '')),
//         );
//         break;
//       case 2:
//       // Payment or messages section
//         break;
//       case 3:
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const UserVIewProfilepages()),
//         );
//         break;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FE),
//       body: SafeArea(
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header Section
//               Container(
//                 padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Top Bar
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             // Profile Picture
//                             Container(
//                               width: 44,
//                               height: 44,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: const Color(0xFF5B8DEF),
//                                   width: 2,
//                                 ),
//                                 image: photo.isNotEmpty
//                                     ? DecorationImage(
//                                   image: NetworkImage(photo),
//                                   fit: BoxFit.cover,
//                                 )
//                                     : null,
//                               ),
//                               child: photo.isEmpty
//                                   ? const Icon(Icons.person, color: Color(0xFF5B8DEF))
//                                   : null,
//                             ),
//                             const SizedBox(width: 12),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   _getGreeting(),
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Color(0xFF9CA3AF),
//                                     fontWeight: FontWeight.w400,
//                                   ),
//                                 ),
//                                 Text(
//                                   name.split(' ').first,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFF1F2937),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         // Notification Icon
//                         Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Stack(
//                             children: [
//                               const Center(
//                                 child: Icon(
//                                   Icons.notifications_none,
//                                   color: Color(0xFF1F2937),
//                                   size: 22,
//                                 ),
//                               ),
//                               Positioned(
//                                 right: 10,
//                                 top: 10,
//                                 child: Container(
//                                   width: 8,
//                                   height: 8,
//                                   decoration: const BoxDecoration(
//                                     color: Color(0xFFEF4444),
//                                     shape: BoxShape.circle,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 24),
//                     // Main Heading
//                     const Text(
//                       'How are your feeling\ntoday?',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF1F2937),
//                         height: 1.3,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     // Search Bar
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.04),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.search, color: Colors.grey[400], size: 22),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               'Search an exam, subjects, etc...',
//                               style: TextStyle(
//                                 color: Colors.grey[400],
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ),
//                           Icon(Icons.mic_none, color: Colors.grey[400], size: 22),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Upcoming Exams Section
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Upcoming Exams',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF1F2937),
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const UpcomingExam(),
//                           ),
//                         );
//                       },
//                       child: const Text(
//                         'View All',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF5B8DEF),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 12),
//
//               // Large Combined Exam Card
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 20),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF5B8DEF), Color(-15124058)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFF5B8DEF).withOpacity(0.3),
//                       blurRadius: 16,
//                       offset: const Offset(0, 6),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     // Top Row: Exam Icon with 3D layers, Exam Name, and Message Icon
//                     Row(
//                       children: [
//                         // 3D Layered Exam Icon
//                         SizedBox(
//                           width: 50,
//                           height: 50,
//                           child: Stack(
//                             children: [
//                               // Third layer (back)
//                               Positioned(
//                                 top: 8,
//                                 left: 8,
//                                 child: Container(
//                                   width: 50,
//                                   height: 50,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.3),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                               ),
//                               // Second layer (middle)
//                               Positioned(
//                                 top: 4,
//                                 left: 4,
//                                 child: Container(
//                                   width: 50,
//                                   height: 50,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.5),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                               ),
//                               // First layer (front)
//                               Positioned(
//                                 top: 0,
//                                 left: 0,
//                                 child: Container(
//                                   width: 50,
//                                   height: 50,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.15),
//                                         blurRadius: 10,
//                                         offset: const Offset(0, 4),
//                                       ),
//                                     ],
//                                   ),
//                                   child: const Icon(
//                                     Icons.school_outlined,
//                                     color: Color(0xFF5B8DEF),
//                                     size: 28,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         // Exam Name and Subject
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: const [
//                               Text(
//                                 'Mathematics Exam',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               SizedBox(height: 2),
//                               Text(
//                                 'Final Semester',
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   color: Colors.white70,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         // Message Icon
//                         Container(
//                           width: 36,
//                           height: 36,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.message_outlined,
//                             color: Color(0xFF5B8DEF),
//                             size: 18,
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     // Date and Time Row
//                     Row(
//                       children: [
//                         // Date
//                         Expanded(
//                           child: Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(6),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.2),
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 child: const Icon(
//                                   Icons.calendar_today,
//                                   color: Colors.white,
//                                   size: 14,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: const [
//                                   Text(
//                                     'Date',
//                                     style: TextStyle(
//                                       fontSize: 11,
//                                       color: Colors.white70,
//                                     ),
//                                   ),
//                                   SizedBox(height: 2),
//                                   Text(
//                                     '18 Nov, Monday',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         // Time
//                         Expanded(
//                           child: Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(6),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.2),
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 child: const Icon(
//                                   Icons.access_time,
//                                   color: Colors.white,
//                                   size: 14,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: const [
//                                   Text(
//                                     'Time',
//                                     style: TextStyle(
//                                       fontSize: 11,
//                                       color: Colors.white70,
//                                     ),
//                                   ),
//                                   SizedBox(height: 2),
//                                   Text(
//                                     '8pm - 9:30 pm',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     // Buttons Row
//                     Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const UpcomingExam(),
//                                 ),
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white,
//                               foregroundColor: const Color(0xFF5B8DEF),
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               elevation: 0,
//                             ),
//                             child: const Text(
//                               'Re-Schedule',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const UserVIewProfilepages(),
//                                 ),
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white,
//                               foregroundColor: const Color(0xFF5B8DEF),
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               elevation: 0,
//                             ),
//                             child: const Text(
//                               'Attend Exam',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 28),
//
//               // Quick Access Section
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: const [
//                     Text(
//                       'Quick Access',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF1F2937),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // Category Pills
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Row(
//                   children: [
//                     _buildCategoryPill('All', true),
//                     _buildCategoryPill('Exams', false),
//                     _buildCategoryPill('Profile', false),
//                     _buildCategoryPill('Settings', false),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               // Quick Access Cards
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Column(
//                   children: [
//                     _buildQuickAccessCard(
//                       name: 'View Profile',
//                       specialty: 'Profile Management',
//                       rating: '4.9',
//                       reviews: '180',
//                       icon: Icons.person,
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const UserVIewProfilepages(),
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     _buildQuickAccessCard(
//                       name: 'View Exams',
//                       specialty: 'Exam Management',
//                       rating: '4.8',
//                       reviews: '165',
//                       icon: Icons.description,
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const viewexam(title: ''),
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     _buildQuickAccessCard(
//                       name: 'Complaint',
//                       specialty: 'Exam Management',
//                       rating: '4.8',
//                       reviews: '165',
//                       icon: Icons.description,
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const viewreplypage(title: ''),
//                           ),
//                         );
//                       },
//                     ),
//
//                     const SizedBox(height: 16),
//                     _buildQuickAccessCard(
//                       name: 'upcoming exam',
//                       specialty: 'Exam Management',
//                       rating: '4.8',
//                       reviews: '165',
//                       icon: Icons.description,
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const UpcomingExam(),
//                           ),
//                         );
//                       },
//                     ),
//
//                     const SizedBox(height: 16),
//                     _buildQuickAccessCard(
//                       name: 'View Marks',
//                       specialty: 'Exam Management',
//                       rating: '4.8',
//                       reviews: '165',
//                       icon: Icons.description,
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const view_marks(title: ''),
//                           ),
//                         );
//                       },
//                     ),
//
//                     const SizedBox(height: 16),
//                     _buildQuickAccessCard(
//                       name: 'logout',
//                       specialty: 'Exam Management',
//                       rating: '4.8',
//                       reviews: '165',
//                       icon: Icons.description,
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const login(title: ''),
//                           ),
//                         );
//                       },
//                     ),
//
//
//
//                     const SizedBox(height: 16),
//                     _buildQuickAccessCard(
//                       name: 'Change Password',
//                       specialty: 'Security',
//                       rating: '4.7',
//                       reviews: '142',
//                       icon: Icons.lock,
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const UserChangePassword(),
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 100),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: Container(
//         margin: const EdgeInsets.all(20),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(30),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(30),
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.2),
//                   width: 1.5,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 30,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildBottomNavItem(
//                         icon: Icons.home_rounded,
//                         index: 0,
//                       ),
//                       _buildBottomNavItem(
//                         icon: Icons.calendar_today_rounded,
//                         index: 1,
//                       ),
//                       _buildBottomNavItem(
//                         icon: Icons.mail_rounded,
//                         index: 2,
//                       ),
//                       _buildBottomNavItem(
//                         icon: Icons.settings_rounded,
//                         index: 3,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoCard({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF0F4FF),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               icon,
//               color: const Color(0xFF5B8DEF),
//               size: 18,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(
//                     fontSize: 11,
//                     color: Color(0xFF9CA3AF),
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF1F2937),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCategoryPill(String label, bool isSelected) {
//     return Container(
//       margin: const EdgeInsets.only(right: 12),
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       decoration: BoxDecoration(
//         color: isSelected ? const Color(0xFF5B8DEF) : Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w600,
//           color: isSelected ? Colors.white : const Color(0xFF6B7280),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuickAccessCard({
//     required String name,
//     required String specialty,
//     required String rating,
//     required String reviews,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             // Profile Picture
//             Container(
//               width: 56,
//               height: 56,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF0F4FF),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 icon,
//                 color: const Color(0xFF5B8DEF),
//                 size: 28,
//               ),
//             ),
//             const SizedBox(width: 16),
//             // Details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF1F2937),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     specialty,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: Color(0xFF9CA3AF),
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.star,
//                         color: Color(0xFFFBBF24),
//                         size: 16,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         rating,
//                         style: const TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF1F2937),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         '$reviews Reviews',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFF9CA3AF),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             // Bookmark Icon
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF0F4FF),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.bookmark_border,
//                 color: Color(0xFF5B8DEF),
//                 size: 20,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBottomNavItem({
//     required IconData icon,
//     required int index,
//   }) {
//     final isSelected = _selectedIndex == index;
//     return GestureDetector(
//       onTap: () => _onBottomNavTap(index),
//       child: Container(
//         padding: const EdgeInsets.all(6),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? Colors.white.withOpacity(0.1)
//               : Colors.transparent,
//           shape: BoxShape.circle,
//           border: isSelected
//               ? Border.all(
//             color: Colors.white.withOpacity(0.9),
//             width: 2,
//           )
//               : null,
//         ),
//         child: Icon(
//           icon,
//           color: isSelected
//               ? const Color(0xFF5B8DEF)
//               : const Color(0xFF64748B),
//           size: 26,
//         ),
//       ),
//     );
//   }
// }
//
//
//
//
//
//
// // import 'dart:convert';
// // import 'package:ai_watcher/candidate/viewexam.dart';
// // import 'package:flutter/material.dart';
// // import 'package:fluttertoast/fluttertoast.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:http/http.dart' as http;
// //
// // import 'changepassword.dart';
// // import 'upcomingExam.dart';
// // import 'viewprofile.dart';
// // import '../login.dart';
// //
// // class CandidateHome extends StatefulWidget {
// //   const CandidateHome({super.key});
// //
// //   @override
// //   State<CandidateHome> createState() => _CandidateHomeState();
// // }
// //
// // class _CandidateHomeState extends State<CandidateHome> {
// //   String name = 'Candidate';
// //   String photo = '';
// //   bool _isLoading = true;
// //   int _selectedIndex = 0;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchProfileData();
// //   }
// //
// //   Future<void> _fetchProfileData() async {
// //     setState(() => _isLoading = true);
// //
// //     SharedPreferences sh = await SharedPreferences.getInstance();
// //     String? url = sh.getString('url');
// //     String? lid = sh.getString('lid');
// //     String? imgBaseUrl = sh.getString('img_url') ?? '';
// //
// //     if (url == null || lid == null) {
// //       Fluttertoast.showToast(msg: "Server URL or login ID not found.");
// //       setState(() => _isLoading = false);
// //       return;
// //     }
// //
// //     final uri = Uri.parse('$url/candidateviewprofile/');
// //
// //     try {
// //       final response = await http.post(uri, body: {'lid': lid});
// //       if (response.statusCode == 200) {
// //         final data = jsonDecode(response.body);
// //         if (data['status'] == 'ok') {
// //           setState(() {
// //             name = data['name']?.toString() ?? 'Candidate';
// //             photo = imgBaseUrl + (data['photo']?.toString() ?? '');
// //           });
// //         } else {
// //           Fluttertoast.showToast(msg: "Profile not found");
// //         }
// //       } else {
// //         Fluttertoast.showToast(msg: "Network Error");
// //       }
// //     } catch (e) {
// //       Fluttertoast.showToast(msg: "Error: $e");
// //     } finally {
// //       setState(() => _isLoading = false);
// //     }
// //   }
// //
// //   void _onBottomNavTap(int index) {
// //     setState(() {
// //       _selectedIndex = index;
// //     });
// //
// //     // Navigate based on selection
// //     switch (index) {
// //       case 0:
// //       // Already on Home
// //         break;
// //       case 1:
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(builder: (context) => const viewexam(title: '')),
// //         );
// //         break;
// //       case 3:
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(builder: (context) => const UserVIewProfilepages()),
// //         );
// //         break;
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF5F7FA),
// //       body: SafeArea(
// //         child: Stack(
// //           children: [
// //             _isLoading
// //                 ? const Center(child: CircularProgressIndicator())
// //                 : SingleChildScrollView(
// //               physics: const BouncingScrollPhysics(),
// //               padding: const EdgeInsets.only(
// //                 left: 20,
// //                 right: 20,
// //                 top: 16,
// //                 bottom: 100, // Space for bottom nav
// //               ),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   // Header Row
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       // Menu Icon
// //                       Container(
// //                         padding: const EdgeInsets.all(8),
// //                         decoration: BoxDecoration(
// //                           color: Colors.white,
// //                           borderRadius: BorderRadius.circular(12),
// //                           boxShadow: [
// //                             BoxShadow(
// //                               color: Colors.black.withOpacity(0.05),
// //                               blurRadius: 10,
// //                               offset: const Offset(0, 4),
// //                             ),
// //                           ],
// //                         ),
// //                         child: const Icon(
// //                           Icons.apps,
// //                           color: Color(0xFF1E3A8A),
// //                           size: 24,
// //                         ),
// //                       ),
// //                       // Home text
// //                       const Text(
// //                         'Home',
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.w600,
// //                           color: Color(0xFF1E3A8A),
// //                         ),
// //                       ),
// //                       // Notification Icon
// //                       Container(
// //                         padding: const EdgeInsets.all(8),
// //                         decoration: BoxDecoration(
// //                           color: Colors.white,
// //                           borderRadius: BorderRadius.circular(12),
// //                           boxShadow: [
// //                             BoxShadow(
// //                               color: Colors.black.withOpacity(0.05),
// //                               blurRadius: 10,
// //                               offset: const Offset(0, 4),
// //                             ),
// //                           ],
// //                         ),
// //                         child: Stack(
// //                           children: [
// //                             const Icon(
// //                               Icons.notifications_outlined,
// //                               color: Color(0xFF1E3A8A),
// //                               size: 24,
// //                             ),
// //                             Positioned(
// //                               right: 0,
// //                               top: 0,
// //                               child: Container(
// //                                 width: 8,
// //                                 height: 8,
// //                                 decoration: const BoxDecoration(
// //                                   color: Colors.red,
// //                                   shape: BoxShape.circle,
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //
// //                   const SizedBox(height: 24),
// //
// //                   // Greeting
// //                   Text(
// //                     'Hi ${name.split(' ').first}!',
// //                     style: const TextStyle(
// //                       fontSize: 28,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF1E3A8A),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 4),
// //                   const Text(
// //                     'Good Morning',
// //                     style: TextStyle(
// //                       fontSize: 14,
// //                       color: Colors.grey,
// //                     ),
// //                   ),
// //
// //                   const SizedBox(height: 20),
// //
// //                   // Search Bar
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 16,
// //                       vertical: 12,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(12),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black.withOpacity(0.05),
// //                           blurRadius: 10,
// //                           offset: const Offset(0, 4),
// //                         ),
// //                       ],
// //                     ),
// //                     child: Row(
// //                       children: [
// //                         Icon(Icons.search, color: Colors.grey[400]),
// //                         const SizedBox(width: 12),
// //                         Text(
// //                           'Search',
// //                           style: TextStyle(
// //                             color: Colors.grey[400],
// //                             fontSize: 15,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //
// //                   const SizedBox(height: 20),
// //
// //                   // Welcome Card with Illustration
// //                   Container(
// //                     padding: const EdgeInsets.all(16),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(16),
// //                       border: Border.all(
// //                         color: const Color(0xFF3B82F6).withOpacity(0.3),
// //                         width: 1.5,
// //                       ),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black.withOpacity(0.05),
// //                           blurRadius: 10,
// //                           offset: const Offset(0, 4),
// //                         ),
// //                       ],
// //                     ),
// //                     child: Row(
// //                       children: [
// //                         Expanded(
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: const [
// //                               Text(
// //                                 'Welcome!',
// //                                 style: TextStyle(
// //                                   fontSize: 16,
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Color(0xFF1E3A8A),
// //                                 ),
// //                               ),
// //                               SizedBox(height: 4),
// //                               Text(
// //                                 "Let's schedule your\nprojects",
// //                                 style: TextStyle(
// //                                   fontSize: 12,
// //                                   color: Colors.grey,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                         // Placeholder for illustration
// //                         Container(
// //                           width: 80,
// //                           height: 80,
// //                           decoration: BoxDecoration(
// //                             color: const Color(0xFFE0E7FF),
// //                             borderRadius: BorderRadius.circular(12),
// //                           ),
// //                           child: const Icon(
// //                             Icons.school_outlined,
// //                             size: 40,
// //                             color: Color(0xFF3B82F6),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //
// //                   const SizedBox(height: 24),
// //
// //                   // Section Header
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       const Text(
// //                         'Ongoing Projects',
// //                         style: TextStyle(
// //                           fontSize: 18,
// //                           fontWeight: FontWeight.bold,
// //                           color: Color(0xFF1E3A8A),
// //                         ),
// //                       ),
// //                       Text(
// //                         'view all',
// //                         style: TextStyle(
// //                           fontSize: 14,
// //                           color: Colors.grey[400],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //
// //                   const SizedBox(height: 16),
// //
// //                   // Project Cards Grid
// //                   GridView.count(
// //                     shrinkWrap: true,
// //                     physics: const NeverScrollableScrollPhysics(),
// //                     crossAxisCount: 2,
// //                     crossAxisSpacing: 16,
// //                     mainAxisSpacing: 16,
// //                     childAspectRatio: 0.85,
// //                     children: [
// //                       _buildProjectCard(
// //                         title: 'View Profile',
// //                         subtitle: 'Profile',
// //                         date: 'May 26, 2022',
// //                         progress: 0.8,
// //                         color: const Color(0xFF1E3A8A),
// //                         icon: Icons.person_outline,
// //                         onTap: () {
// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder: (context) => const UserVIewProfilepages(),
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                       _buildProjectCard(
// //                         title: 'Upcoming',
// //                         subtitle: 'Exams',
// //                         date: 'May 26, 2022',
// //                         progress: 0.5,
// //                         color: Colors.white,
// //                         icon: Icons.event_available,
// //                         isLight: true,
// //                         onTap: () {
// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder: (context) => const UpcomingExam(),
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                       _buildProjectCard(
// //                         title: 'Exams',
// //                         subtitle: 'Marketing',
// //                         date: 'May 26, 2022',
// //                         progress: 0.6,
// //                         color: Colors.white,
// //                         icon: Icons.description_outlined,
// //                         isLight: true,
// //                         onTap: () {
// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder: (context) => const viewexam(title: ''),
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                       _buildProjectCard(
// //                         title: 'Password',
// //                         subtitle: 'User Manager',
// //                         date: 'May 26, 2022',
// //                         progress: 0.5,
// //                         color: Colors.white,
// //                         icon: Icons.lock_outline,
// //                         isLight: true,
// //                         onTap: () {
// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder: (context) => const UserChangePassword(),
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                       _buildProjectCard(
// //                         title: 'Logout',
// //                         subtitle: 'User Manager',
// //                         date: 'May 26, 2022',
// //                         progress: 0.5,
// //                         color: Colors.white,
// //                         icon: Icons.lock_outline,
// //                         isLight: true,
// //                         onTap: () {
// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder: (context) => const login(title: '',),
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                     ],
// //                   ),
// //
// //                   const SizedBox(height: 20),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //       // Floating Action Button
// //       floatingActionButton: Container(
// //         width: 64,
// //         height: 64,
// //         decoration: BoxDecoration(
// //           gradient: const LinearGradient(
// //             colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
// //           ),
// //           shape: BoxShape.circle,
// //           boxShadow: [
// //             BoxShadow(
// //               color: const Color(0xFF1E3A8A).withOpacity(0.4),
// //               blurRadius: 12,
// //               offset: const Offset(0, 6),
// //             ),
// //           ],
// //         ),
// //         child: FloatingActionButton(
// //           onPressed: () {
// //             Navigator.push(
// //               context,
// //               MaterialPageRoute(builder: (context) => const viewexam(title: '')),
// //             );
// //           },
// //           backgroundColor: Colors.transparent,
// //           elevation: 0,
// //           child: const Icon(Icons.add, size: 32, color: Colors.white),
// //         ),
// //       ),
// //       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
// //       // Bottom Navigation Bar
// //       bottomNavigationBar: Container(
// //         decoration: BoxDecoration(
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.1),
// //               blurRadius: 20,
// //               offset: const Offset(0, -5),
// //             ),
// //           ],
// //         ),
// //         child: BottomAppBar(
// //           color: Colors.white,
// //           shape: const CircularNotchedRectangle(),
// //           notchMargin: 8,
// //           child: SizedBox(
// //             height: 60,
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// //               children: [
// //                 _buildBottomNavItem(
// //                   icon: Icons.home_outlined,
// //                   label: 'Home',
// //                   index: 0,
// //                 ),
// //                 _buildBottomNavItem(
// //                   icon: Icons.calendar_today_outlined,
// //                   label: 'My task',
// //                   index: 1,
// //                 ),
// //                 const SizedBox(width: 40), // Space for FAB
// //                 _buildBottomNavItem(
// //                   icon: Icons.payment_outlined,
// //                   label: 'Payment',
// //                   index: 2,
// //                 ),
// //                 _buildBottomNavItem(
// //                   icon: Icons.settings_outlined,
// //                   label: 'Settings',
// //                   index: 3,
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildBottomNavItem({
// //     required IconData icon,
// //     required String label,
// //     required int index,
// //   }) {
// //     final isSelected = _selectedIndex == index;
// //     return GestureDetector(
// //       onTap: () => _onBottomNavTap(index),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(
// //             icon,
// //             color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[400],
// //             size: 24,
// //           ),
// //           const SizedBox(height: 4),
// //           Text(
// //             label,
// //             style: TextStyle(
// //               fontSize: 12,
// //               color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[400],
// //               fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildProjectCard({
// //     required String title,
// //     required String subtitle,
// //     required String date,
// //     required double progress,
// //     required Color color,
// //     required IconData icon,
// //     bool isLight = false,
// //     required VoidCallback onTap,
// //   }) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         padding: const EdgeInsets.all(16),
// //         decoration: BoxDecoration(
// //           color: color,
// //           borderRadius: BorderRadius.circular(16),
// //           border: isLight
// //               ? Border.all(color: Colors.grey[200]!)
// //               : null,
// //           boxShadow: [
// //             BoxShadow(
// //               color: isLight
// //                   ? Colors.black.withOpacity(0.05)
// //                   : color.withOpacity(0.3),
// //               blurRadius: 12,
// //               offset: const Offset(0, 6),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Header with date and menu
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Text(
// //                   date,
// //                   style: TextStyle(
// //                     fontSize: 11,
// //                     color: isLight ? Colors.grey : Colors.white70,
// //                   ),
// //                 ),
// //                 Icon(
// //                   Icons.more_vert,
// //                   size: 18,
// //                   color: isLight ? Colors.grey : Colors.white70,
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 12),
// //             // Icon
// //             Container(
// //               padding: const EdgeInsets.all(10),
// //               decoration: BoxDecoration(
// //                 color: isLight
// //                     ? const Color(0xFFE0E7FF)
// //                     : Colors.white.withOpacity(0.2),
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //               child: Icon(
// //                 icon,
// //                 color: isLight ? const Color(0xFF3B82F6) : Colors.white,
// //                 size: 24,
// //               ),
// //             ),
// //             const SizedBox(height: 12),
// //             // Title
// //             Text(
// //               title,
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //                 color: isLight ? const Color(0xFF1E3A8A) : Colors.white,
// //               ),
// //             ),
// //             const SizedBox(height: 4),
// //             Text(
// //               subtitle,
// //               style: TextStyle(
// //                 fontSize: 12,
// //                 color: isLight ? Colors.grey : Colors.white70,
// //               ),
// //             ),
// //             const Spacer(),
// //             // Progress bar
// //             Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Text(
// //                       'Progress',
// //                       style: TextStyle(
// //                         fontSize: 11,
// //                         color: isLight ? Colors.grey : Colors.white70,
// //                       ),
// //                     ),
// //                     Text(
// //                       '${(progress * 100).toInt()}%',
// //                       style: TextStyle(
// //                         fontSize: 11,
// //                         fontWeight: FontWeight.bold,
// //                         color: isLight ? const Color(0xFF1E3A8A) : Colors.white,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 6),
// //                 ClipRRect(
// //                   borderRadius: BorderRadius.circular(4),
// //                   child: LinearProgressIndicator(
// //                     value: progress,
// //                     backgroundColor: isLight
// //                         ? Colors.grey[200]
// //                         : Colors.white.withOpacity(0.3),
// //                     valueColor: AlwaysStoppedAnimation<Color>(
// //                       isLight ? const Color(0xFF3B82F6) : Colors.white,
// //                     ),
// //                     minHeight: 6,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// //
//
//
//
//
//
// // // import 'dart:convert';
// // //
// // // import 'package:ai_watcher/candidate/upcomingExam.dart';
// // // import 'package:ai_watcher/candidate/viewexam.dart';
// // // import 'package:ai_watcher/candidate/viewprofile.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:fluttertoast/fluttertoast.dart';
// // // import 'package:http/http.dart' as http;
// // // import 'package:shared_preferences/shared_preferences.dart';
// // //
// // // import '../Staff/changepassword.dart';
// // // import '../login.dart';
// // //
// // //
// // // void main() {
// // //   runApp(const MaterialApp(
// // //     debugShowCheckedModeBanner: false,
// // //     home: candidate_home(),
// // //   ));
// // // }
// // //
// // // class candidate_home extends StatefulWidget {
// // //   const candidate_home({super.key});
// // //
// // //   @override
// // //   State<candidate_home> createState() => _candidate_homeState();
// // // }
// // //
// // // class _candidate_homeState extends State<candidate_home> {
// // //
// // //   _candidate_homeState(){
// // //     _send_data();
// // //   }
// // //
// // //   String name_='';
// // //   String photo_='';
// // //
// // //
// // //   void _send_data() async{
// // //
// // //
// // //
// // //     SharedPreferences sh = await SharedPreferences.getInstance();
// // //     String url = sh.getString('url').toString();
// // //     String lid = sh.getString('lid').toString();
// // //     String img = sh.getString('img_url') ?? '';
// // //
// // //
// // //     final urls = Uri.parse('$url/candidateviewprofile/');
// // //     try {
// // //       final response = await http.post(urls, body: {
// // //         'lid':lid
// // //
// // //
// // //
// // //       });
// // //       if (response.statusCode == 200) {
// // //         String status = jsonDecode(response.body)['status'];
// // //         if (status=='ok') {
// // //           String name=jsonDecode(response.body)['name'].toString();
// // //           String photo=img +jsonDecode(response.body)['photo'].toString();
// // //
// // //           setState(() {
// // //
// // //             name_= name;
// // //             photo_= photo;
// // //           });
// // //
// // //
// // //
// // //
// // //
// // //         }else {
// // //           Fluttertoast.showToast(msg: 'Not Found');
// // //         }
// // //       }
// // //       else {
// // //         Fluttertoast.showToast(msg: 'Network Error');
// // //       }
// // //     }
// // //     catch (e){
// // //       Fluttertoast.showToast(msg: e.toString());
// // //     }
// // //   }
// // //
// // //
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       // drawer: const Drawer(
// // //       //   child: DrawerContent(),
// // //       // ),
// // //       appBar: AppBar(
// // //         backgroundColor: Colors.white,
// // //         elevation: 0,
// // //         iconTheme: const IconThemeData(color: Colors.black87),
// // //         // actions: const [
// // //         //   Icon(Icons.notifications_none),
// // //         //   SizedBox(width: 16),
// // //         // ],
// // //       ),
// // //       backgroundColor: const Color(0xFFF5F6FA),
// // //       body: Padding(
// // //         padding: const EdgeInsets.all(20.0),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //              Row(
// // //               children: [
// // //                 CircleAvatar(
// // //                   backgroundImage: NetworkImage(photo_),
// // //                   radius: 25,
// // //                 ),
// // //                 SizedBox(width: 12),
// // //                 Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   children: [
// // //                     Text(
// // //                       name_,
// // //                       style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
// // //                     ),
// // //                     Text(
// // //                       'What do you want to do today?',
// // //                       style: TextStyle(color: Colors.black54,fontSize: 8),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ],
// // //             ),
// // //             const SizedBox(height: 30),
// // //             Container(
// // //               padding: const EdgeInsets.all(20),
// // //               decoration: BoxDecoration(
// // //                 color: Colors.white,
// // //                 borderRadius: BorderRadius.circular(20),
// // //               ),
// // //               child: Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                 children: const [
// // //                   Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       Text(''),
// // //                       SizedBox(height: 6),
// // //                       Text(
// // //                         '',
// // //                         style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                   Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       Text(''),
// // //                       SizedBox(height: 6),
// // //                       Text(
// // //                         '',
// // //                         style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
// // //                       ),
// // //
// // //                     ],
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //             const SizedBox(height: 25),
// // //             const Text(
// // //               'Quick Actions',
// // //               style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
// // //             ),
// // //             const SizedBox(height: 15),
// // //             Expanded(
// // //               child: GridView.count(
// // //                 crossAxisCount: 2,
// // //                 crossAxisSpacing: 15,
// // //                 mainAxisSpacing: 15,
// // //                 children: [
// // //                   ActionCard(
// // //                     title: 'View Profile',
// // //                     color: Colors.pinkAccent,
// // //                     icon: Icons.verified_user,
// // //                     onTap: () {
// // //                       Navigator.push(
// // //                         context,
// // //                         MaterialPageRoute(builder: (context) => UserVIewProfilepages(title: '')),
// // //                       );
// // //                     },
// // //                   ),
// // //
// // //
// // //                   ActionCard(
// // //                     title: 'Change password',
// // //                     color: Colors.deepPurple,
// // //                     icon: Icons.table_view_outlined,
// // //                     onTap: () {
// // //                       Navigator.push(
// // //                         context,
// // //                         MaterialPageRoute(builder: (context) => changepassword()),
// // //                       );
// // //                     },
// // //                   ),
// // //
// // //                   ActionCard(
// // //                     title: ' View UpcomingExam',
// // //                     color: Colors.deepPurple,
// // //                     icon: Icons.table_view_outlined,
// // //                     onTap: () {
// // //                       Navigator.push(
// // //                         context,
// // //                         MaterialPageRoute(builder: (context) => upc_exam(title: '',)),
// // //                       );
// // //                     },
// // //                   ),
// // //
// // //
// // //                   ActionCard(
// // //                     title: ' Logout',
// // //                     color: Colors.deepPurple,
// // //                     icon: Icons.table_view_outlined,
// // //                     onTap: () {
// // //                       Navigator.push(
// // //                         context,
// // //                         MaterialPageRoute(builder: (context) => login(title: '',)),
// // //                       );
// // //                     },
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // class ActionCard extends StatelessWidget {
// // //   final String title;
// // //   final Color color;
// // //   final IconData icon;
// // //   final VoidCallback? onTap; // ADD this
// // //
// // //   const ActionCard({
// // //     super.key,
// // //     required this.title,
// // //     required this.color,
// // //     required this.icon,
// // //     this.onTap, // ADD this
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return GestureDetector(
// // //       onTap: onTap, // USE this
// // //       child: Container(
// // //         padding: const EdgeInsets.all(16),
// // //         decoration: BoxDecoration(
// // //           color: color.withOpacity(0.1),
// // //           borderRadius: BorderRadius.circular(20),
// // //         ),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             CircleAvatar(
// // //               backgroundColor: color,
// // //               child: Icon(icon, color: Colors.white),
// // //             ),
// // //             const SizedBox(height: 10),
// // //             Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // //
// // // class DrawerContent extends StatefulWidget {
// // //   const DrawerContent({super.key});
// // //
// // //   @override
// // //   State<DrawerContent> createState() => _DrawerContentState();
// // // }
// // //
// // // class _DrawerContentState extends State<DrawerContent> {
// // //   void showDrawerMessage(String message) {
// // //     Navigator.pop(context); // Close drawer
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(content: Text(message)),
// // //     );
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return ListView(
// // //       padding: EdgeInsets.zero,
// // //       children: [
// // //         const DrawerHeader(
// // //           decoration: BoxDecoration(color: Colors.blue),
// // //           child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
// // //         ),
// // //         ListTile(
// // //           leading: const Icon(Icons.dashboard),
// // //           title: const Text('Dashboard'),
// // //           onTap: () => showDrawerMessage('Dashboard selected'),
// // //         ),
// // //         ListTile(
// // //           leading: const Icon(Icons.receipt),
// // //           title: const Text('Add User'),
// // //           onTap: () => showDrawerMessage('Bills selected'),
// // //         ),
// // //         ListTile(
// // //           leading: const Icon(Icons.send),
// // //           title: const Text('Transfers'),
// // //           onTap: () => showDrawerMessage('Transfers selected'),
// // //         ),
// // //         ListTile(
// // //           leading: const Icon(Icons.settings),
// // //           title: const Text('Settings'),
// // //           onTap: () => showDrawerMessage('Settings selected'),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // // }
