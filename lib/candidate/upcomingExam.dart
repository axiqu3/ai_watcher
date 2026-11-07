import 'dart:convert';
import 'package:ai_watcher/candidate/videochat.dart';
import 'package:ai_watcher/chat.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Attendexam.dart';
import 'candidate_home.dart';

// ─── Theme ────────────────────────────────────────────────────────────────────
const _primary      = Color(0xFF194569);
const _primaryLight = Color(0xFF2A6096);
const _bg           = Color(0xFFF0F4F8);
const _card         = Colors.white;
const _text         = Color(0xFF0D1F2D);
const _sub          = Color(0xFF607D8B);
const _divider      = Color(0xFFE8EEF4);
// ─────────────────────────────────────────────────────────────────────────────

class UpcomingExam extends StatefulWidget {
  const UpcomingExam({super.key});

  @override
  State<UpcomingExam> createState() => _UpcomingExamState();
}

class _UpcomingExamState extends State<UpcomingExam> {
  List<Map<String, dynamic>> exams         = [];
  List<Map<String, dynamic>> filteredExams = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterExams);
    _fetchUpcomingExams();
  }

  Future<void> _fetchUpcomingExams() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      String? lid = sh.getString('lid');

      if (url == null || lid == null) {
        Fluttertoast.showToast(msg: "Server URL or login ID not found.");
        return;
      }

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
              'duration'        : item['duration'] ?? 0,
              'attempts'        : item['attempts'] ?? 1,
              'used_attempts'   : item['used_attempts'] ?? 0,
            });
          }
          setState(() {
            exams         = tempList;
            filteredExams = tempList;
          });
        } else {
          Fluttertoast.showToast(msg: "No upcoming exams found");
        }
      } else {
        Fluttertoast.showToast(msg: "Network Error");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterExams() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredExams = exams.where((exam) {
        return exam['examname'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════════════════
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
            // ── Header ───────────────────────────────────────────────────────
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
                  // Back + title
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
                            Text('Upcoming Exams',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            Text('Your scheduled examinations',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white60)),
                          ],
                        ),
                      ),
                      // Count pill
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
                          '${filteredExams.length} exams',
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
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _filterExams();
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

            // ── Body ─────────────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.event_note_outlined,
                          color: _primary, size: 30),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(
                      width: 26, height: 26,
                      child: CircularProgressIndicator(
                          color: _primary, strokeWidth: 2.5),
                    ),
                    const SizedBox(height: 10),
                    const Text('Loading exams...',
                        style: TextStyle(
                            fontSize: 13, color: _sub)),
                  ],
                ),
              )
                  : filteredExams.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.08),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: const Icon(
                          Icons.event_busy_outlined,
                          color: _primary, size: 34),
                    ),
                    const SizedBox(height: 14),
                    const Text('No upcoming exams',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _text)),
                    const SizedBox(height: 4),
                    const Text('Check back later for new exams',
                        style: TextStyle(
                            fontSize: 12, color: _sub)),
                  ],
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                    16, 16, 16, 100),
                itemCount: filteredExams.length,
                itemBuilder: (context, index) {
                  final exam = filteredExams[index];
                  return _buildExamCard(exam, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Exam Card ─────────────────────────────────────────────────────────────
  Widget _buildExamCard(Map<String, dynamic> exam, int index) {
    final int duration     = int.tryParse(exam['duration'].toString()) ?? 0;
    final int maxAttempts  = int.tryParse(exam['attempts'].toString()) ?? 1;
    final int usedAttempts = int.tryParse(exam['used_attempts'].toString()) ?? 0;
    final int remaining    = maxAttempts - usedAttempts;
    final bool attemptsExhausted = remaining <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _divider),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Colored top accent bar ──────────────────────────────────────
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: attemptsExhausted
                    ? [Colors.red.shade300, Colors.red.shade400]
                    : [_primary, _primaryLight],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft:  Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title row ────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: _primary.withOpacity(0.15),
                        ),
                      ),
                      child: const Icon(Icons.school_outlined,
                          color: _primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exam['examname'] ?? 'Exam Name',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _text,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  size: 12, color: _sub),
                              const SizedBox(width: 4),
                              Text(
                                exam['enaminername'] ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _sub,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Index badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Duration + Attempts info row ─────────────────────────
                Row(
                  children: [
                    // Duration chip
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _primary.withOpacity(0.15)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined,
                                color: _primary, size: 16),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Duration',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: _sub,
                                        fontWeight: FontWeight.w500)),
                                Text(
                                  duration > 0
                                      ? '$duration mins'
                                      : 'No limit',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Attempts chip
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: attemptsExhausted
                              ? Colors.red.withOpacity(0.07)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: attemptsExhausted
                                ? Colors.red.withOpacity(0.25)
                                : Colors.green.withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              attemptsExhausted
                                  ? Icons.block_outlined
                                  : Icons.repeat_rounded,
                              color: attemptsExhausted
                                  ? Colors.red.shade600
                                  : const Color(0xFF2E7D32),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Attempts',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: _sub,
                                        fontWeight: FontWeight.w500)),
                                Text(
                                  '$usedAttempts / $maxAttempts',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: attemptsExhausted
                                          ? Colors.red.shade600
                                          : const Color(0xFF2E7D32)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Timing block ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _primary.withOpacity(0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildInfoColumn(
                          icon: Icons.play_circle_outline_rounded,
                          label: 'Start',
                          value: '${exam['startdate']}  ${exam['starttime']}',
                        ),
                      ),
                      Container(
                        width: 1, height: 36,
                        color: _divider,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: _buildInfoColumn(
                            icon: Icons.stop_circle_outlined,
                            label: 'End',
                            value: '${exam['enddate']}  ${exam['endtime']}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── Action buttons ────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                       child: _buildActionButton(
                        label: 'Attend',
                        icon: Icons.play_arrow_rounded,
                        onTap: () async {
                          if (attemptsExhausted) {
                            Fluttertoast.showToast(
                              msg: "No attempts remaining for this exam",
                              backgroundColor: Colors.red,
                            );
                            return;
                          }
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => _ExamInstructionSheet(
                              exam: exam,
                              onProceed: () async {
                                Navigator.pop(context);
                                SharedPreferences sh = await SharedPreferences.getInstance();
                                String url = sh.getString('url') ?? '';
                                String lid = sh.getString('lid') ?? '';
                                String eid = exam['exam'].toString();

                                // ── Call start_exam before entering ──────────────────
                                final res = await http.post(
                                  Uri.parse('$url/start_exam/'),
                                  body: {'eid': eid, 'lid': lid},
                                );
                                final data = jsonDecode(res.body);

                                if (data['status'] == 'attempts_exceeded') {
                                  Fluttertoast.showToast(
                                    msg: "No attempts remaining for this exam!",
                                    backgroundColor: Colors.red,
                                  );
                                  return; // stop here, don't open exam
                                }

                                // ── Attempt logged, now open exam ────────────────────
                                sh.setString('exam', exam['id'].toString());
                                sh.setString('qeid', eid);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => attendexam(
                                      startDate   : exam['startdate'],
                                      startTime   : exam['starttime'],
                                      endDate     : exam['enddate'],
                                      endTime     : exam['endtime'],
                                      duration    : int.tryParse(exam['duration'].toString()) ?? 0,
                                      maxAttempts : int.tryParse(exam['attempts'].toString()) ?? 1,
                                      usedAttempts: int.tryParse(exam['used_attempts'].toString()) ?? 0,
                                    ),
                                  ),
                                ).then((_) {
                                  // ── Refresh the list when candidate returns from exam ──
                                  setState(() => _isLoading = true);
                                  _fetchUpcomingExams();
                                });
                              },
                            ),
                          );
                        },
                        isFilled: true,
                        isDisabled: attemptsExhausted,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        label: 'Chat',
                        icon: Icons.chat_bubble_outline_rounded,
                        onTap: () async {
                          SharedPreferences sh =
                          await SharedPreferences.getInstance();
                          sh.setString(
                              'toid', exam['examinerlid'].toString());
                          sh.setString(
                              'agrname', exam['enaminername'].toString());
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                const MyChatPage(title: '')),
                          );
                        },
                        isFilled: false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        label: 'Video',
                        icon: Icons.video_call_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AgoraVideoCall()),
                          );
                        },
                        isFilled: false,
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

  // ── Info column ────────────────────────────────────────────────────────────
  Widget _buildInfoColumn({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: _primary.withOpacity(0.6)),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(fontSize: 11, color: _sub)),
          ],
        ),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: _text)),
      ],
    );
  }

  // ── Action button ──────────────────────────────────────────────────────────
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isFilled,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          gradient: isFilled && !isDisabled
              ? const LinearGradient(
            colors: [_primary, _primaryLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )
              : null,
          color: isDisabled
              ? Colors.grey.shade200
              : (isFilled ? null : Colors.transparent),
          borderRadius: BorderRadius.circular(11),
          border: isFilled && !isDisabled
              ? null
              : Border.all(
            color: isDisabled
                ? Colors.grey.shade400
                : _primary.withOpacity(0.35),
            width: 1.2,
          ),
          boxShadow: isFilled && !isDisabled
              ? [
            BoxShadow(
              color: _primary.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 15,
                color: isDisabled
                    ? Colors.grey.shade500
                    : (isFilled ? Colors.white : _primary)),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDisabled
                        ? Colors.grey.shade500
                        : (isFilled ? Colors.white : _primary))),
          ],
        ),
      ),
    );
  }
}

// ── Exam Instruction Bottom Sheet ─────────────────────────────────────────────
class _ExamInstructionSheet extends StatelessWidget {
  final Map<String, dynamic> exam;
  final VoidCallback onProceed;

  const _ExamInstructionSheet({
    required this.exam,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    final int duration     = int.tryParse(exam['duration'].toString()) ?? 0;
    final int maxAttempts  = int.tryParse(exam['attempts'].toString()) ?? 1;
    final int usedAttempts = int.tryParse(exam['used_attempts'].toString()) ?? 0;
    final int remaining    = maxAttempts - usedAttempts;

    return DraggableScrollableSheet(
      initialChildSize: 0.91,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.only(
              topLeft:  Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              // ── Drag handle ───────────────────────────────────────────
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: _divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── Sheet header ──────────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_primary, _primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.school_outlined,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exam['examname'] ?? 'Exam',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  size: 11, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                exam['enaminername'] ?? '',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (exam['already_attended'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Attended',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
              ),

              // ── Scrollable body ───────────────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  children: [

                    // ── Duration + Attempts summary ───────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F0FE),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: _primary.withOpacity(0.15)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.timer_outlined,
                                    color: _primary, size: 18),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text('Duration',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: _sub,
                                            fontWeight: FontWeight.w500)),
                                    Text(
                                      duration > 0
                                          ? '$duration mins'
                                          : 'No limit',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: _primary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.green.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.repeat_rounded,
                                    color: Color(0xFF2E7D32), size: 18),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text('Attempts Left',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: _sub,
                                            fontWeight: FontWeight.w500)),
                                    Text(
                                      '$remaining of $maxAttempts',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF2E7D32)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ── Exam timing card ──────────────────────────────────
                    _sheetSection(
                      title: 'Exam Schedule',
                      icon: Icons.schedule_outlined,
                      child: Column(
                        children: [
                          _timingRow(
                            Icons.play_circle_outline_rounded,
                            'Start',
                            '${exam['startdate']}   ${exam['starttime']}',
                            const Color(0xFF1A7A6E),
                            const Color(0xFFE6F7F5),
                          ),
                          const SizedBox(height: 10),
                          _timingRow(
                            Icons.stop_circle_outlined,
                            'End',
                            '${exam['enddate']}   ${exam['endtime']}',
                            const Color(0xFFC0392B),
                            const Color(0xFFFFEBEE),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Instructions ──────────────────────────────────────
                    _sheetSection(
                      title: 'Instructions',
                      icon: Icons.info_outline_rounded,
                      child: Column(
                        children: [
                          _instructionItem('1',
                              'Ensure you have a stable internet connection before starting the exam.'),
                          _instructionItem('2',
                              'Do not close or switch the app during the exam. It will be flagged as suspicious.'),
                          _instructionItem('3',
                              duration > 0
                                  ? 'You must complete the exam within $duration minutes. It will auto-submit when time expires.'
                                  : 'You must complete the exam within the allotted time. It will auto-submit when time expires.'),
                          _instructionItem('4',
                              'Camera and microphone access is required throughout the exam for proctoring.'),
                          _instructionItem('5',
                              'Each question must be answered before moving to the next. Review your answers before submitting.'),
                          _instructionItem('6',
                              'Do not use any external resources, books, or devices during the exam.'),
                          _instructionItem('7',
                              'Once you submit, your answers cannot be changed. Submit only when you are ready.'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Important notice ──────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFFFD54F), width: 1.2),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFB85C00), size: 20),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Any form of malpractice will result in immediate disqualification. '
                                  'Your activity is being monitored via AI proctoring.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF5D3F00),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Proceed button ────────────────────────────────────
                    GestureDetector(
                      onTap: onProceed,
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
                              color: _primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'I Understand — Start Exam',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Cancel ────────────────────────────────────────────
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: _primary.withOpacity(0.3), width: 1.2),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sheetSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: _primary),
              const SizedBox(width: 7),
              Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _text)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: _divider),
          ),
          child,
        ],
      ),
    );
  }

  Widget _timingRow(
      IconData icon, String label, String value, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: fg.withOpacity(0.7),
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      fontSize: 12,
                      color: fg,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _instructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _primary)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12, color: _text, height: 1.5)),
          ),
        ],
      ),
    );
  }
}