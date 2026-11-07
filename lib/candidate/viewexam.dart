import 'dart:async';
import 'dart:convert';

import 'package:ai_watcher/Staff/add_question.dart';
import 'package:ai_watcher/Staff/staff_home.dart';
import 'package:ai_watcher/Staff/view_question.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'candidate_home.dart';

void main() {
  runApp(const ViewHouseApp());
}

class ViewHouseApp extends StatelessWidget {
  const ViewHouseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: viewexam(title: 'View Users'),
    );
  }
}

// ─── Theme ────────────────────────────────────────────────────────────────────
const _primary      = Color(0xFF194569);
const _primaryLight = Color(0xFF2A6096);
const _bg           = Color(0xFFF0F4F8);
const _card         = Colors.white;
const _text         = Color(0xFF0D1F2D);
const _sub          = Color(0xFF607D8B);
const _divider      = Color(0xFFE8EEF4);
const _accent       = Color(0xFF1A7A6E);
// ─────────────────────────────────────────────────────────────────────────────

class viewexam extends StatefulWidget {
  const viewexam({super.key, required this.title});
  final String title;

  @override
  State<viewexam> createState() => _viewexamState();
}

class _viewexamState extends State<viewexam> {
  List<Map<String, dynamic>> users         = [];
  List<Map<String, dynamic>> filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  Timer? _expiryTimer;

  // ── Calendar state ──────────────────────────────────────────────────────────
  DateTime _focusedMonth   = DateTime.now();
  DateTime? _selectedDate;
  // ───────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    viewUsers("");
    _expiryTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _removeExpiredExams();
    });
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  bool _isExpired(Map<String, dynamic> exam) {
    try {
      final endDate  = exam['enddate'].toString().trim();
      final endTime  = exam['endtime'].toString().trim();
      final timeParts = endTime.split(':');
      final hour   = int.parse(timeParts[0]);
      final minute = int.parse(timeParts.length > 1 ? timeParts[1] : '0');
      final second = int.parse(timeParts.length > 2 ? timeParts[2] : '0');
      final dateParts = endDate.split('-');
      final endDateTime = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        hour, minute, second,
      );
      return DateTime.now().isAfter(endDateTime);
    } catch (_) {
      return false;
    }
  }

  void _removeExpiredExams() {
    setState(() {
      users         = users.where((e) => !_isExpired(e)).toList();
      filteredUsers = filteredUsers.where((e) => !_isExpired(e)).toList();
    });
  }

  Future<void> viewUsers(String searchValue) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String lid  = sh.getString('lid').toString();
      String apiUrl = '$urls/candidateviewexam/';

      var response = await http.post(Uri.parse(apiUrl), body: {'lid': lid});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          final exam = {
            'id':        item['id'].toString(),
            'exam':      item['exam'].toString(),
            'examname':  item['examname'].toString(),
            'startdate': item['startdate'].toString(),
            'starttime': item['starttime'].toString(),
            'enddate':   item['enddate'].toString(),
            'endtime':   item['endtime'].toString(),
          };
          if (!_isExpired(exam)) tempList.add(exam);
        }
        setState(() {
          users         = tempList;
          filteredUsers = _applyFilters(tempList, searchValue, _selectedDate);
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  // ── Filter helper ───────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _applyFilters(
      List<Map<String, dynamic>> source,
      String search,
      DateTime? date,
      ) {
    return source.where((u) {
      final matchesSearch = u['examname']
          .toString()
          .toLowerCase()
          .contains(search.toLowerCase());
      if (date == null) return matchesSearch;
      // Show exams where the selected date falls within [startdate, enddate]
      try {
        final start = DateTime.parse(u['startdate']);
        final end   = DateTime.parse(u['enddate']);
        final d     = DateTime(date.year, date.month, date.day);
        final s     = DateTime(start.year, start.month, start.day);
        final e2    = DateTime(end.year, end.month, end.day);
        return matchesSearch &&
            (d.isAtSameMomentAs(s) || d.isAfter(s)) &&
            (d.isAtSameMomentAs(e2) || d.isBefore(e2) || d.isAtSameMomentAs(e2));
      } catch (_) {
        return matchesSearch;
      }
    }).toList();
  }

  /// Collect all dates that have at least one exam
  Set<String> get _examDateKeys {
    final keys = <String>{};
    for (final u in users) {
      try {
        final start = DateTime.parse(u['startdate']);
        final end   = DateTime.parse(u['enddate']);
        for (var d = start;
        !d.isAfter(end);
        d = d.add(const Duration(days: 1))) {
          keys.add('${d.year}-${d.month}-${d.day}');
        }
      } catch (_) {}
    }
    return keys;
  }

  bool _hasExam(DateTime day) =>
      _examDateKeys.contains('${day.year}-${day.month}-${day.day}');

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: _primary.withOpacity(0.6)),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: _sub, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 12, color: _text, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700, color: color)),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  CALENDAR WIDGET
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildCalendar() {
    final now        = DateTime.now();
    final firstDay  = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay   = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // 0 = Sun

    final days = <DateTime?>[];
    for (int i = 0; i < startWeekday; i++) days.add(null);
    for (int d = 1; d <= lastDay.day; d++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, d));
    }

    const weekLabels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    const monthNames = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Month navigation ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                // Prev month
                _calNavBtn(Icons.chevron_left, () {
                  setState(() {
                    _focusedMonth = DateTime(
                        _focusedMonth.year, _focusedMonth.month - 1);
                    _selectedDate = null;
                    filteredUsers = _applyFilters(users, _searchController.text, null);
                  });
                }),
                Expanded(
                  child: Text(
                    '${monthNames[_focusedMonth.month - 1]}  ${_focusedMonth.year}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _text,
                        letterSpacing: 0.2),
                  ),
                ),
                // Clear selection
                if (_selectedDate != null)
                  GestureDetector(
                    onTap: () => setState(() {
                      _selectedDate = null;
                      filteredUsers = _applyFilters(
                          users, _searchController.text, null);
                    }),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Clear',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _primary)),
                    ),
                  ),
                // Next month
                _calNavBtn(Icons.chevron_right, () {
                  setState(() {
                    _focusedMonth = DateTime(
                        _focusedMonth.year, _focusedMonth.month + 1);
                    _selectedDate = null;
                    filteredUsers = _applyFilters(users, _searchController.text, null);
                  });
                }),
              ],
            ),
          ),

          // ── Week-day labels ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: weekLabels.map((l) => Expanded(
                child: Center(
                  child: Text(l,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: (l == 'Su' || l == 'Sa')
                              ? _primary.withOpacity(0.5)
                              : _sub)),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 6),

          // ── Day grid ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 14),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemCount: days.length,
              itemBuilder: (ctx, i) {
                final day = days[i];
                if (day == null) return const SizedBox();
                return _buildDayCell(day, now);
              },
            ),
          ),

          // ── Legend ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                _legendDot(Colors.orange.shade400),
                const SizedBox(width: 6),
                const Text('Exam scheduled',
                    style: TextStyle(fontSize: 11, color: _sub)),
                const SizedBox(width: 16),
                _legendDot(_primary),
                const SizedBox(width: 6),
                const Text('Selected',
                    style: TextStyle(fontSize: 11, color: _sub)),
                const Spacer(),
                _legendDot(const Color(0xFFE8F4FD), border: true),
                const SizedBox(width: 6),
                const Text('Today',
                    style: TextStyle(fontSize: 11, color: _sub)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime day, DateTime now) {
    final isToday    = day.year == now.year &&
        day.month == now.month && day.day == now.day;
    final isSelected = _selectedDate != null &&
        day.year == _selectedDate!.year &&
        day.month == _selectedDate!.month &&
        day.day == _selectedDate!.day;
    final hasExam    = _hasExam(day);
    final isWeekend  = day.weekday == DateTime.saturday ||
        day.weekday == DateTime.sunday;

    Color bgColor     = Colors.transparent;
    Color textColor   = isWeekend ? _primary.withOpacity(0.55) : _text;
    FontWeight weight = FontWeight.w500;

    if (isSelected) {
      bgColor   = _primary;
      textColor = Colors.white;
      weight    = FontWeight.w800;
    } else if (isToday) {
      bgColor   = const Color(0xFFE8F4FD);
      textColor = _primary;
      weight    = FontWeight.w700;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedDate = null;
            filteredUsers = _applyFilters(
                users, _searchController.text, null);
          } else {
            _selectedDate = day;
            filteredUsers = _applyFilters(
                users, _searchController.text, day);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: isToday && !isSelected
              ? Border.all(color: _primary.withOpacity(0.3), width: 1.5)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text('${day.day}',
                style: TextStyle(
                    fontSize: 13, color: textColor, fontWeight: weight)),
            // Exam dot
            if (hasExam && !isSelected)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 5, height: 5,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _calNavBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: _divider),
        ),
        child: Icon(icon, color: _primary, size: 18),
      ),
    );
  }

  Widget _legendDot(Color color, {bool border = false}) {
    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border
            ? Border.all(color: _primary.withOpacity(0.3), width: 1)
            : null,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CandidateHome()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            // ── Gradient Header ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primary, _primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CandidateHome()),
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
                            Text('Available Exams',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            Text('Browse and apply for exams',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white60)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Text(
                          '${filteredUsers.length} exams',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded,
                            color: Colors.white60, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search by exam name...',
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.45),
                                  fontSize: 14),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (v) {
                              setState(() {
                                filteredUsers = _applyFilters(
                                    users, v, _selectedDate);
                              });
                            },
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                filteredUsers = _applyFilters(
                                    users, '', _selectedDate);
                              });
                            },
                            child: const Icon(Icons.close,
                                color: Colors.white54, size: 18),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable body ──────────────────────────────────────────
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 30),
                children: [
                  // ── Stats Row ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: Row(
                      children: [
                        _statChip(Icons.menu_book_outlined,
                            '${filteredUsers.length} Available', _primary),
                        const SizedBox(width: 10),
                        _statChip(Icons.timer_outlined, 'Open Now', _accent),
                        const SizedBox(width: 10),
                        _statChip(Icons.send_outlined, 'Apply Fast',
                            _primaryLight),
                      ],
                    ),
                  ),

                  // ── CALENDAR ──────────────────────────────────────────
                  _buildCalendar(),

                  // ── Date filter banner ─────────────────────────────────
                  if (_selectedDate != null)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.filter_alt_outlined,
                              size: 16, color: _primary),
                          const SizedBox(width: 8),
                          Text(
                            'Filtered: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _primary),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => setState(() {
                              _selectedDate = null;
                              filteredUsers = _applyFilters(
                                  users, _searchController.text, null);
                            }),
                            child: const Icon(Icons.close,
                                size: 16, color: _primary),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // ── Exam cards ─────────────────────────────────────────
                  if (filteredUsers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72, height: 72,
                              decoration: BoxDecoration(
                                color: _primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.inbox_outlined,
                                  color: _primary, size: 34),
                            ),
                            const SizedBox(height: 14),
                            const Text('No exams found',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _text)),
                            const SizedBox(height: 4),
                            const Text('Try a different date or search',
                                style:
                                TextStyle(fontSize: 12, color: _sub)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...List.generate(
                      filteredUsers.length,
                          (i) => Padding(
                        padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child:
                        _buildExamCard(filteredUsers[i], i),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Exam Card ───────────────────────────────────────────────────────────────
  Widget _buildExamCard(Map<String, dynamic> user, int index) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
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
          // ── Card header ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.03),
              borderRadius: const BorderRadius.only(
                topLeft:  Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: const Border(
                  bottom: BorderSide(color: _divider, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_primary, _primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['examname'],
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _text)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                              Icons.confirmation_number_outlined,
                              size: 12,
                              color: _sub),
                          const SizedBox(width: 4),
                          Text('ID: ${user['id']}',
                              style: const TextStyle(
                                  fontSize: 11, color: _sub)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F7F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle,
                          size: 7, color: Color(0xFF1A7A6E)),
                      SizedBox(width: 4),
                      Text('Open',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A7A6E))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Schedule ───────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _primary.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.event_available_outlined,
                        color: _primary, size: 15),
                    const SizedBox(width: 8),
                    const Text('Exam Schedule',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _text)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _infoRow(Icons.play_circle_outline,
                          'Start', user['startdate']),
                    ),
                    Expanded(
                      child: _infoRow(Icons.access_time_outlined,
                          'Time', user['starttime']),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _infoRow(Icons.stop_circle_outlined,
                          'End', user['enddate']),
                    ),
                    Expanded(
                      child: _infoRow(Icons.timelapse_outlined,
                          'Time', user['endtime']),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Request button ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () async {
                  SharedPreferences sh =
                  await SharedPreferences.getInstance();
                  String url = sh.getString('url').toString();
                  String lid = sh.getString('lid').toString();
                  final urls = Uri.parse('$url/usersentexamrequest/');
                  try {
                    final response = await http.post(urls, body: {
                      'lid': lid,
                      'eid': user['id'].toString(),
                    });
                    if (response.statusCode == 200) {
                      Fluttertoast.showToast(
                          msg: 'Request sent successfully!');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CandidateHome()),
                      );
                    } else {
                      Fluttertoast.showToast(msg: 'Network Error');
                    }
                  } catch (e) {
                    Fluttertoast.showToast(msg: e.toString());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_primary, _primaryLight],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: _primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded,
                          color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text('Request to Apply',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}