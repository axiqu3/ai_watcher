
import 'dart:convert';

import 'package:ai_watcher/candidate/camera.dart';
import 'package:ai_watcher/chat.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Attendexam.dart';
import 'candidate_home.dart';

class UpcomingExam extends StatefulWidget {
  const UpcomingExam({super.key});

  @override
  State<UpcomingExam> createState() => _UpcomingExamState();
}

class _UpcomingExamState extends State<UpcomingExam> {
  List<Map<String, dynamic>> exams = [];
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
    setState(() => _isLoading = true);

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
              'id': item['id'].toString(),
              'exam': item['exam'].toString(),
              'examname': item['examname'].toString(),
              'startdate': item['startdate'].toString(),
              'starttime': item['starttime'].toString(),
              'enddate': item['enddate'].toString(),
              'endtime': item['endtime'].toString(),
              'examinerlid': item['examinerlid'].toString(),
              'enaminername': item['enaminername'].toString(),
            });
          }
          setState(() {
            exams = tempList;
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
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Bar
                    Row(
                      children: [
                        // Back Button
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const CandidateHome()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Color(0xFF1E3A8A),
                              size: 20,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Upcoming Exams',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40), // Balance the back button
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey[400], size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search by exam name...',
                                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Exam List
              Expanded(
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF3B82F6),
                  ),
                )
                    : filteredExams.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E7FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.event_busy_outlined,
                          size: 60,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No upcoming exams found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF1E3A8A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check back later for new exams',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(20),
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
      ),
    );
  }

  Widget _buildExamCard(Map<String, dynamic> exam, int index) {
    // Alternate between dark and light cards
    final isDark = index % 2 == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A8A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? null : Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF1E3A8A).withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Exam Name and Menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  exam['examname'] ?? 'Exam Name',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                  ),
                ),
              ),
              Icon(
                Icons.more_vert,
                color: isDark ? Colors.white70 : Colors.grey[400],
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Exam Details Grid
          Row(
            children: [
              Expanded(
                child: _buildInfoColumn(
                  icon: Icons.calendar_today_outlined,
                  label: 'Start Date',
                  value: exam['startdate'] ?? '-',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoColumn(
                  icon: Icons.access_time_outlined,
                  label: 'Start Time',
                  value: exam['starttime'] ?? '-',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoColumn(
                  icon: Icons.calendar_today_outlined,
                  label: 'End Date',
                  value: exam['enddate'] ?? '-',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoColumn(
                  icon: Icons.access_time_outlined,
                  label: 'End Time',
                  value: exam['endtime'] ?? '-',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: 'Attend',
                  icon: Icons.play_arrow_rounded,
                  onTap: () async {
                    SharedPreferences sh = await SharedPreferences.getInstance();
                    sh.setString('exam', exam['id'].toString());
                    sh.setString('qeid', exam['exam'].toString());
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const attendexam()),
                    );
                  },
                  isDark: isDark,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  label: 'Chat',
                  icon: Icons.chat_outlined,
                  onTap: () async {
                    SharedPreferences sh = await SharedPreferences.getInstance();
                    sh.setString('toid', exam['examinerlid'].toString());
                    sh.setString('agrname', exam['enaminername'].toString());
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyChatPage(title: '')),
                    );
                  },
                  isDark: isDark,
                  isPrimary: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isDark
                  ? Colors.white70
                  : const Color(0xFF3B82F6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1E3A8A),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          )
              : null,
          color: isPrimary
              ? null
              : (isDark
              ? Colors.white.withOpacity(0.2)
              : const Color(0xFFE0E7FF)),
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? null
              : Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.3)
                : const Color(0xFF3B82F6).withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary
                  ? Colors.white
                  : (isDark ? Colors.white : const Color(0xFF3B82F6)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isPrimary
                    ? Colors.white
                    : (isDark ? Colors.white : const Color(0xFF3B82F6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


























// import 'dart:convert';
//
// import 'package:ai_watcher/candidate/camera.dart';
// import 'package:ai_watcher/chat.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'Attendexam.dart';
// import 'candidate_home.dart';
//
// class UpcomingExam extends StatefulWidget {
//   const UpcomingExam({super.key});
//
//   @override
//   State<UpcomingExam> createState() => _UpcomingExamState();
// }
//
// class _UpcomingExamState extends State<UpcomingExam> {
//   List<Map<String, dynamic>> exams = [];
//   List<Map<String, dynamic>> filteredExams = [];
//   bool _isLoading = true;
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_filterExams);
//     _fetchUpcomingExams();
//   }
//
//   Future<void> _fetchUpcomingExams() async {
//     setState(() => _isLoading = true);
//
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String? url = sh.getString('url');
//       String? lid = sh.getString('lid');
//
//       if (url == null || lid == null) {
//         Fluttertoast.showToast(msg: "Server URL or login ID not found.");
//         return;
//       }
//
//       final apiUrl = Uri.parse('$url/studentviewupcomingexam/');
//
//       final response = await http.post(apiUrl, body: {'lid': lid});
//
//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//
//         if (jsonData['status'] == 'ok') {
//           List<Map<String, dynamic>> tempList = [];
//           for (var item in jsonData['data']) {
//             tempList.add({
//               'id': item['id'].toString(),
//               'exam': item['exam'].toString(),
//               'examname': item['examname'].toString(),
//               'startdate': item['startdate'].toString(),
//               'starttime': item['starttime'].toString(),
//               'enddate': item['enddate'].toString(),
//               'endtime': item['endtime'].toString(),
//               'examinerlid': item['examinerlid'].toString(),
//               'enaminername': item['enaminername'].toString(),
//             });
//           }
//           setState(() {
//             exams = tempList;
//             filteredExams = tempList;
//           });
//         } else {
//           Fluttertoast.showToast(msg: "No upcoming exams found");
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
//   void _filterExams() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       filteredExams = exams.where((exam) {
//         return exam['examname'].toString().toLowerCase().contains(query);
//       }).toList();
//     });
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const CandidateHome()),
//         );
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF8F9FF),
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0047AB)),
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => const CandidateHome()),
//               );
//             },
//           ),
//           title: const Text(
//             'Upcoming Exams',
//             style: TextStyle(
//               color: Color(0xFF0047AB),
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           centerTitle: true,
//           flexibleSpace: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Color(0xFF0047AB), Color(0xFF0066FF)],
//               ),
//             ),
//           ),
//         ),
//         body: Column(
//           children: [
//             // Search Bar
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: 'Search by exam name...',
//                   prefixIcon: const Icon(Icons.search, color: Color(0xFF0066FF)),
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: const BorderSide(color: Color(0xFF0066FF), width: 2),
//                   ),
//                 ),
//               ),
//             ),
//
//             // Exam List
//             Expanded(
//               child: _isLoading
//                   ? const Center(child: CircularProgressIndicator(color: Color(0xFF0066FF)))
//                   : filteredExams.isEmpty
//                   ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.event_busy_outlined,
//                       size: 80,
//                       color: Colors.grey[400],
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No upcoming exams found',
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//                   : ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: filteredExams.length,
//                 itemBuilder: (context, index) {
//                   final exam = filteredExams[index];
//                   return _buildExamCard(exam);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildExamCard(Map<String, dynamic> exam) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           gradient: const LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Colors.white, Color(0xFFF0F7FF)],
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Exam Name
//               Text(
//                 exam['examname'] ?? 'Exam Name',
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF0047AB),
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               // Exam Details
//               _buildDetailRow(Icons.calendar_today_outlined, 'Start Date', exam['startdate'] ?? '-'),
//               const SizedBox(height: 12),
//               _buildDetailRow(Icons.access_time_outlined, 'Start Time', exam['starttime'] ?? '-'),
//               const SizedBox(height: 12),
//               _buildDetailRow(Icons.calendar_today_outlined, 'End Date', exam['enddate'] ?? '-'),
//               const SizedBox(height: 12),
//               _buildDetailRow(Icons.access_time_outlined, 'End Time', exam['endtime'] ?? '-'),
//               const SizedBox(height: 24),
//
//               // Attend Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: ElevatedButton.icon(
//                   onPressed: () async {
//                     SharedPreferences sh = await SharedPreferences.getInstance();
//                     sh.setString('exam', exam['id'].toString());
//                     sh.setString('qeid', exam['exam'].toString());
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const attendexam()),
//                       // MaterialPageRoute(builder: (context) => const AttendInterview(title: '',)),
//                     );
//                   },
//                   icon: const Icon(Icons.play_arrow_rounded, size: 20),
//                   label: const Text(
//                     'Attend Exam',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFFF6B00),
//                     foregroundColor: Colors.white,
//                     elevation: 6,
//                     shadowColor: Colors.orangeAccent.withOpacity(0.5),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20,),
//               SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: ElevatedButton.icon(
//                   onPressed: () async {
//                     SharedPreferences sh = await SharedPreferences.getInstance();
//                     sh.setString('toid', exam['examinerlid'].toString());
//                     sh.setString('agrname', exam['enaminername'].toString());
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const MyChatPage(title: '',)),
//                     );
//                   },
//                   icon: const Icon(Icons.chat, size: 20),
//                   label: const Text(
//                     'Chat',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                     elevation: 6,
//                     shadowColor: Colors.orangeAccent.withOpacity(0.5),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                   ),
//                 ),
//               ),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(IconData icon, String label, String value) {
//     return Row(
//       children: [
//         Icon(icon, size: 20, color: const Color(0xFF0066FF)),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   color: Colors.grey,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF0047AB),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
//
//
//







// import 'dart:convert';
//
// import 'package:ai_watcher/Staff/add_question.dart';
// import 'package:ai_watcher/Staff/staff_home.dart';
// import 'package:ai_watcher/Staff/view_examrequest.dart';
// import 'package:ai_watcher/Staff/view_question.dart';
// import 'package:ai_watcher/candidate/Attendexam.dart';
// // import 'package:easy_search_bar/easy_search_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// import 'candidate_home.dart';
//
//
//
// void main() {
//   runApp(const ViewHouseApp());
// }
//
// class ViewHouseApp extends StatelessWidget {
//   const ViewHouseApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: upc_exam(title: 'View Users'),
//     );
//   }
// }
//
// class upc_exam extends StatefulWidget {
//   const upc_exam({super.key, required this.title});
//   final String title;
//
//   @override
//   State<upc_exam> createState() => _upc_examState();
// }
//
// class _upc_examState extends State<upc_exam> {
//   List<Map<String, dynamic>> users = [];
//   List<Map<String, dynamic>> filteredUsers = [];
//   List<String> nameSuggestions = [];
//
//   @override
//   void initState() {
//     super.initState();
//     viewUsers("");
//   }
//
//   Future<void> viewUsers(String searchValue) async {
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String urls = sh.getString('url') ?? '';
//       String img = sh.getString('img_url') ?? '';
//       String lid = sh.getString('lid').toString();
//       String apiUrl = '$urls/studentviewupcomingexam/';
//
//       var response = await http.post(Uri.parse(apiUrl), body: {
//         'lid':lid
//       });
//       var jsonData = json.decode(response.body);
//
//       if (jsonData['status'] == 'ok') {
//         List<Map<String, dynamic>> tempList = [];
//         for (var item in jsonData['data']) {
//           tempList.add({
//             'id': item['id'].toString(),
//             'exam': item['exam'].toString(),
//             'examname': item['examname'].toString(),
//             'startdate': item['startdate'].toString(),
//             'starttime': item['starttime'].toString(),
//             'enddate':  item['enddate'].toString(),
//             'endtime':  item['endtime'].toString(),
//           });
//         }
//         setState(() {
//           users = tempList;
//           filteredUsers = tempList
//               .where((user) =>
//               user['examname']
//                   .toString()
//                   .toLowerCase()
//                   .contains(searchValue.toLowerCase()))
//               .toList();
//           nameSuggestions = users.map((e) => e['examname'].toString()).toSet().toList();
//         });
//       }
//     } catch (e) {
//       print("Error fetching users: $e");
//     }
//   }
//
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//         onWillPop: () async {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const CandidateHome()),
//       );
//       return false; // Prevent default pop
//     },
//     child:Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color.fromARGB(255, 232, 177, 61),
//         title: Text('Search by examname'),
//         // suggestions: nameSuggestions,
//         // onSearch: (value) {
//         //   setState(() {
//         //     filteredUsers = users
//         //         .where((user) => user['name']
//         //         .toString()
//         //         .toLowerCase()
//         //         .contains(value.toLowerCase()))
//         //         .toList();
//         //   });
//         // },
//       ),
//       body: ListView.builder(
//         shrinkWrap: true,
//         physics: BouncingScrollPhysics(),
//         itemCount: filteredUsers.length,
//         itemBuilder: (context, index) {
//           final user = filteredUsers[index];
//           return Card(
//             margin: const EdgeInsets.all(10),
//             elevation: 5,
//             child: ListTile(
//               // leading: CircleAvatar(
//               //   backgroundImage: NetworkImage(user['photo']),
//               //   radius: 30,
//               // ),
//               title: Text(user['examname'], style: TextStyle(fontWeight: FontWeight.bold)),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//
//                   // Text("examname: ${user['examname']}"),
//                   Text("startdate: ${user['startdate']}"),
//                   Text("starttime: ${user['starttime']}"),
//                   Text("enddate: ${user['enddate']}"),
//                   Text("endtime: ${user['endtime']}"),
//                   SizedBox(height: 20,),
//
//                   ElevatedButton(onPressed: ()async{
//                     SharedPreferences sh=await SharedPreferences.getInstance();
//                     sh.setString('exam',user['exam'].toString());
//                     Navigator.push(context, MaterialPageRoute(builder: (context)=>attendexam()));
//
//                   }, child: Text('Attent Exam')),
//
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     ));
//   }
// }
