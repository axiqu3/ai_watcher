import 'dart:convert';
import 'package:ai_watcher/Staff/staff_home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const _primary      = Color(0xFF194569);
const _primaryLight = Color(0xFF2A6096);
const _bg           = Color(0xFFF0F4F8);
const _text         = Color(0xFF0D1F2D);
const _sub          = Color(0xFF607D8B);
const _divider      = Color(0xFFE8EEF4);

class view_alerts extends StatefulWidget {
  const view_alerts({super.key, required this.title});
  final String title;

  @override
  State<view_alerts> createState() => _view_alertsState();
}

class _view_alertsState extends State<view_alerts> {
  List<Map<String, dynamic>> allAlerts      = [];
  List<Map<String, dynamic>> filteredAlerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    setState(() => _isLoading = true);
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url') ?? '';

      var response = await http.post(
        Uri.parse('$url/staff_view_alerts/'),
        body: {},
      );
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> temp = [];
        for (var item in jsonData['data']) {
          temp.add({
            'id':        item['id'].toString(),
            'examname':  item['examname'].toString(),
            'startdate': item['startdate'].toString(),
            'starttime': item['starttime'].toString(),
            'enddate':   item['enddate'].toString(),
            'endtime':   item['endtime'].toString(),
          });
        }
        setState(() {
          allAlerts      = temp;
          filteredAlerts = temp;
          _isLoading     = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error: $e");
    }
  }

  void _applySearch(String query) {
    setState(() {
      filteredAlerts = allAlerts.where((a) =>
      a['examname'].toString().toLowerCase().contains(query.toLowerCase()) ||
          a['startdate'].toString().toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  // Returns days remaining until exam
  int _daysRemaining(String startdate) {
    try {
      final parts = startdate.split('-');
      final examDate = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      return examDate.difference(DateTime.now()).inDays;
    } catch (_) {
      return 0;
    }
  }

  Color _urgencyColor(int days) {
    if (days <= 3)  return const Color(0xFFEF4444); // red   - urgent
    if (days <= 7)  return const Color(0xFFF97316); // orange - soon
    if (days <= 14) return const Color(0xFFEAB308); // yellow - upcoming
    return const Color(0xFF22C55E);                  // green  - plenty of time
  }

  String _urgencyLabel(int days) {
    if (days == 0)  return 'Today!';
    if (days == 1)  return 'Tomorrow!';
    if (days <= 3)  return 'In $days days';
    if (days <= 7)  return 'This week';
    if (days <= 14) return 'In $days days';
    return 'In $days days';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const StaffHome()));
        return false;
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [

            // ── Gradient Header ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 24),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Top row
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => const StaffHome())),
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                            Text('Upcoming Exam Alerts',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            Text('Exams scheduled from today',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white60)),
                          ],
                        ),
                      ),
                      // Count badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Text(
                          '${filteredAlerts.length} Exams',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Search bar
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: TextField(
                      onChanged: _applySearch,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search exam name or date...',
                        hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.55), fontSize: 13),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.white.withOpacity(0.7), size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Exam Alert List ──────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                  child: CircularProgressIndicator(color: _primary))
                  : filteredAlerts.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy_outlined,
                        size: 64, color: _sub.withOpacity(0.35)),
                    const SizedBox(height: 12),
                    const Text('No upcoming exams',
                        style: TextStyle(color: _sub, fontSize: 15)),
                    const SizedBox(height: 6),
                    const Text('All caught up!',
                        style: TextStyle(color: _sub, fontSize: 12)),
                  ],
                ),
              )
                  : RefreshIndicator(
                color: _primary,
                onRefresh: _fetchAlerts,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredAlerts.length,
                  itemBuilder: (context, index) {
                    final exam   = filteredAlerts[index];
                    final days   = _daysRemaining(exam['startdate']);
                    final color  = _urgencyColor(days);
                    final label  = _urgencyLabel(days);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _divider),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [

                          // ── Top colored strip ──────────────────────
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.08),
                              borderRadius: const BorderRadius.only(
                                topLeft:  Radius.circular(18),
                                topRight: Radius.circular(18),
                              ),
                              border: Border(
                                  bottom: BorderSide(
                                      color: color.withOpacity(0.2))),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(label,
                                    style: TextStyle(
                                        color: color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('UPCOMING',
                                      style: TextStyle(
                                          color: color,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800)),
                                ),
                              ],
                            ),
                          ),

                          // ── Exam details ───────────────────────────
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                // Exam icon
                                Container(
                                  width: 48, height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        color.withOpacity(0.8),
                                        color,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                      Icons.event_available_rounded,
                                      color: Colors.white,
                                      size: 24),
                                ),

                                const SizedBox(width: 14),

                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      // Exam name
                                      Text(
                                        exam['examname'],
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: _text,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Start date & time
                                      _detailRow(
                                        Icons.play_circle_outline_rounded,
                                        'Starts',
                                        '${exam['startdate']}  ${exam['starttime']}',
                                        const Color(0xFF22C55E),
                                      ),
                                      const SizedBox(height: 5),

                                      // End date & time
                                      _detailRow(
                                        Icons.stop_circle_outlined,
                                        'Ends',
                                        '${exam['enddate']}  ${exam['endtime']}',
                                        const Color(0xFFEF4444),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
      IconData icon, String label, String value, Color iconColor) {
    return Row(children: [
      Icon(icon, size: 14, color: iconColor),
      const SizedBox(width: 6),
      Text('$label: ',
          style: const TextStyle(
              fontSize: 11, color: _sub, fontWeight: FontWeight.w600)),
      Expanded(
        child: Text(value,
            style: const TextStyle(
                fontSize: 12, color: _text, fontWeight: FontWeight.w500)),
      ),
    ]);
  }
}