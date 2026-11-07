import 'dart:convert';

import 'package:ai_watcher/Staff/ViewProctorUsers.dart';
import 'package:ai_watcher/Staff/ViewproctorActivities.dart';
import 'package:ai_watcher/Staff/add_question.dart';
import 'package:ai_watcher/Staff/staff_home.dart';
import 'package:ai_watcher/Staff/view_examrequest.dart';
import 'package:ai_watcher/Staff/view_marks.dart';
import 'package:ai_watcher/Staff/view_question.dart';
import 'package:ai_watcher/candidate/ViewExamRequest.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// ─── Theme ────────────────────────────────────────────────────────────────────
const _primary      = Color(0xFF194569);
const _primaryLight = Color(0xFF2A6096);
const _bg           = Color(0xFFF0F4F8);
const _card         = Colors.white;
const _text         = Color(0xFF0D1F2D);
const _sub          = Color(0xFF607D8B);
const _divider      = Color(0xFFE8EEF4);
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  runApp(const ViewHouseApp());
}

class ViewHouseApp extends StatelessWidget {
  const ViewHouseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: viewallocatedexam(title: 'View Users'),
    );
  }
}

class viewallocatedexam extends StatefulWidget {
  const viewallocatedexam({super.key, required this.title});
  final String title;

  @override
  State<viewallocatedexam> createState() => _viewallocatedexamState();
}

class _viewallocatedexamState extends State<viewallocatedexam> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<String> nameSuggestions = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    viewUsers("");
  }

  Future<void> viewUsers(String searchValue) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String img = sh.getString('img_url') ?? '';
      String lid = sh.getString('lid').toString();
      String apiUrl = '$urls/examinerviewallocatedexam/';

      var response = await http.post(Uri.parse(apiUrl), body: {'lid': lid});
      var jsonData = json.decode(response.body);

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
          });
        }
        setState(() {
          users = tempList;
          filteredUsers = tempList
              .where((user) =>
              user['examname']
                  .toString()
                  .toLowerCase()
                  .contains(searchValue.toLowerCase()))
              .toList();
          nameSuggestions =
              users.map((e) => e['examname'].toString()).toSet().toList();
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  // ── Info row ─────────────────────────────────────────────────────────────
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _primary, size: 14),
          ),
          const SizedBox(width: 10),
          Text('$label: ',
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: _sub)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500, color: _text)),
          ),
        ],
      ),
    );
  }

  // ── Action button ─────────────────────────────────────────────────────────
  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
        decoration: BoxDecoration(
          gradient: outlined
              ? null
              : const LinearGradient(
            colors: [_primary, _primaryLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          color: outlined ? _card : null,
          borderRadius: BorderRadius.circular(11),
          border: outlined
              ? Border.all(color: _primary.withOpacity(0.3), width: 1.4)
              : null,
          boxShadow: outlined
              ? null
              : [
            BoxShadow(
              color: _primary.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: outlined ? _primary : Colors.white, size: 14),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: outlined ? _primary : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const StaffHome()));
        return false;
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [

            // ── Gradient Header ──────────────────────────────────────
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
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -30, right: -20,
                    child: Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8, right: 35,
                    child: Container(
                      width: 55, height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Back + title row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(
                                        builder: (_) => const StaffHome())),
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
                                Text('Allocated Exams',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                                Text('Manage your assigned exams',
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
                            child: const Icon(Icons.assignment_outlined,
                                color: Colors.white, size: 20),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // ── Search bar ─────────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          onChanged: (value) {
                            setState(() {
                              filteredUsers = users
                                  .where((user) =>
                                  user['examname']
                                      .toString()
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search by exam name...',
                            hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13),
                            prefixIcon: Icon(Icons.search,
                                color: Colors.white.withOpacity(0.7),
                                size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Exam count badge ───────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.format_list_numbered,
                                color: Colors.white70, size: 15),
                            const SizedBox(width: 6),
                            Text(
                              '${filteredUsers.length} exam${filteredUsers
                                  .length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── List ──────────────────────────────────────────────────
            Expanded(
              child: filteredUsers.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.assignment_outlined,
                        size: 64,
                        color: _sub.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text('No exams found',
                        style: TextStyle(
                            fontSize: 15,
                            color: _sub.withOpacity(0.6),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ── Exam name header ────────────────
                          Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_primary, _primaryLight],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                    Icons.assignment_outlined,
                                    color: Colors.white,
                                    size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(user['examname'],
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: _text)),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),
                          Divider(color: _divider, height: 1),
                          const SizedBox(height: 12),

                          // ── Date/time info ──────────────────
                          _infoRow(Icons.calendar_today_outlined,
                              'Start Date', user['startdate']),
                          _infoRow(Icons.access_time_outlined,
                              'Start Time', user['starttime']),
                          _infoRow(Icons.event_outlined,
                              'End Date', user['enddate']),
                          _infoRow(Icons.timer_off_outlined,
                              'End Time', user['endtime']),

                          const SizedBox(height: 14),
                          Divider(color: _divider, height: 1),
                          const SizedBox(height: 12),

                          // ── Action buttons — row 1 ──────────
                          Row(
                            children: [
                              Expanded(
                                child: _actionButton(
                                  icon: Icons.quiz_outlined,
                                  label: 'Questions',
                                  onTap: () async {
                                    SharedPreferences sh =
                                    await SharedPreferences
                                        .getInstance();
                                    sh.setString('exam',
                                        user['id'].toString());
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                view_question(
                                                    title: '')));
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _actionButton(
                                  icon: Icons.inbox_outlined,
                                  label: 'Exam Request',
                                  outlined: true,
                                  onTap: () async {
                                    SharedPreferences sh =
                                    await SharedPreferences
                                        .getInstance();
                                    sh.setString('eid',
                                        user['exam'].toString());
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ViewExamRequest(
                                                    title: '')));
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // ── Action buttons — row 2 ──────────
                          Row(
                            children: [
                              Expanded(
                                child: _actionButton(
                                  icon: Icons.bar_chart_outlined,
                                  label: 'Marks',
                                  outlined: true,
                                  onTap: () async {
                                    SharedPreferences sh =
                                    await SharedPreferences
                                        .getInstance();
                                    sh.setString('eid',
                                        user['exam'].toString());
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                StaffViewMark(
                                                    title: '')));
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _actionButton(
                                  icon: Icons.visibility_outlined,
                                  label: 'Proctor Activities',
                                  onTap: () async {
                                    SharedPreferences sh =
                                    await SharedPreferences
                                        .getInstance();
                                    sh.setString('eid',
                                        user['exam'].toString());
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const ViewProctorUsers(
                                                title: 'Proctor Activities')));
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


// import 'dart:convert';
//
// import 'package:ai_watcher/Staff/ViewproctorActivities.dart';
// import 'package:ai_watcher/Staff/add_question.dart';
// import 'package:ai_watcher/Staff/staff_home.dart';
// import 'package:ai_watcher/Staff/view_examrequest.dart';
// import 'package:ai_watcher/Staff/view_marks.dart';
// import 'package:ai_watcher/Staff/view_question.dart';
// import 'package:ai_watcher/candidate/ViewExamRequest.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// // ─── Theme ────────────────────────────────────────────────────────────────────
// const _primary      = Color(0xFF194569);
// const _primaryLight = Color(0xFF2A6096);
// const _bg           = Color(0xFFF0F4F8);
// const _card         = Colors.white;
// const _text         = Color(0xFF0D1F2D);
// const _sub          = Color(0xFF607D8B);
// const _divider      = Color(0xFFE8EEF4);
// // ─────────────────────────────────────────────────────────────────────────────
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
//       home: viewallocatedexam(title: 'View Users'),
//     );
//   }
// }
//
// class viewallocatedexam extends StatefulWidget {
//   const viewallocatedexam({super.key, required this.title});
//   final String title;
//
//   @override
//   State<viewallocatedexam> createState() => _viewallocatedexamState();
// }
//
// class _viewallocatedexamState extends State<viewallocatedexam> {
//   List<Map<String, dynamic>> users         = [];
//   List<Map<String, dynamic>> filteredUsers = [];
//   List<String> nameSuggestions             = [];
//
//   final TextEditingController _searchController = TextEditingController();
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
//       String img  = sh.getString('img_url') ?? '';
//       String lid  = sh.getString('lid').toString();
//       String apiUrl = '$urls/examinerviewallocatedexam/';
//
//       var response = await http.post(Uri.parse(apiUrl), body: {'lid': lid});
//       var jsonData = json.decode(response.body);
//
//       if (jsonData['status'] == 'ok') {
//         List<Map<String, dynamic>> tempList = [];
//         for (var item in jsonData['data']) {
//           tempList.add({
//             'id':        item['id'].toString(),
//             'exam':      item['exam'].toString(),
//             'examname':  item['examname'].toString(),
//             'startdate': item['startdate'].toString(),
//             'starttime': item['starttime'].toString(),
//             'enddate':   item['enddate'].toString(),
//             'endtime':   item['endtime'].toString(),
//           });
//         }
//         setState(() {
//           users = tempList;
//           filteredUsers = tempList
//               .where((user) => user['examname']
//               .toString()
//               .toLowerCase()
//               .contains(searchValue.toLowerCase()))
//               .toList();
//           nameSuggestions =
//               users.map((e) => e['examname'].toString()).toSet().toList();
//         });
//       }
//     } catch (e) {
//       print("Error fetching users: $e");
//     }
//   }
//
//   // ── Info row ─────────────────────────────────────────────────────────────
//   Widget _infoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 7),
//       child: Row(
//         children: [
//           Container(
//             width: 28, height: 28,
//             decoration: BoxDecoration(
//               color: _primary.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(icon, color: _primary, size: 14),
//           ),
//           const SizedBox(width: 10),
//           Text('$label: ',
//               style: const TextStyle(
//                   fontSize: 12, fontWeight: FontWeight.w600, color: _sub)),
//           Expanded(
//             child: Text(value,
//                 style: const TextStyle(
//                     fontSize: 13, fontWeight: FontWeight.w500, color: _text)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Action button ─────────────────────────────────────────────────────────
//   Widget _actionButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     bool outlined = false,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
//         decoration: BoxDecoration(
//           gradient: outlined
//               ? null
//               : const LinearGradient(
//             colors: [_primary, _primaryLight],
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//           ),
//           color: outlined ? _card : null,
//           borderRadius: BorderRadius.circular(11),
//           border: outlined
//               ? Border.all(color: _primary.withOpacity(0.3), width: 1.4)
//               : null,
//           boxShadow: outlined
//               ? null
//               : [
//             BoxShadow(
//               color: _primary.withOpacity(0.25),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon,
//                 color: outlined ? _primary : Colors.white, size: 14),
//             const SizedBox(width: 6),
//             Text(label,
//                 style: TextStyle(
//                     color: outlined ? _primary : Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushReplacement(context,
//             MaterialPageRoute(builder: (context) => const staff_home()));
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: _bg,
//         body: Column(
//           children: [
//
//             // ── Gradient Header ──────────────────────────────────────
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.fromLTRB(20, 54, 20, 24),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [_primary, _primaryLight],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.only(
//                   bottomLeft:  Radius.circular(32),
//                   bottomRight: Radius.circular(32),
//                 ),
//               ),
//               child: Stack(
//                 children: [
//                   // Decorative circles
//                   Positioned(
//                     top: -30, right: -20,
//                     child: Container(
//                       width: 120, height: 120,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.white.withOpacity(0.06),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: 8, right: 35,
//                     child: Container(
//                       width: 55, height: 55,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.white.withOpacity(0.08),
//                       ),
//                     ),
//                   ),
//
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//
//                       // Back + title row
//                       Row(
//                         children: [
//                           GestureDetector(
//                             onTap: () => Navigator.pushReplacement(context,
//                                 MaterialPageRoute(
//                                     builder: (_) => const staff_home())),
//                             child: Container(
//                               width: 38, height: 38,
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.15),
//                                 borderRadius: BorderRadius.circular(11),
//                                 border: Border.all(
//                                     color: Colors.white.withOpacity(0.2)),
//                               ),
//                               child: const Icon(Icons.arrow_back_ios_new,
//                                   color: Colors.white, size: 16),
//                             ),
//                           ),
//                           const SizedBox(width: 14),
//                           const Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('Allocated Exams',
//                                     style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.w800,
//                                         color: Colors.white)),
//                                 Text('Manage your assigned exams',
//                                     style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.white60)),
//                               ],
//                             ),
//                           ),
//                           Container(
//                             width: 40, height: 40,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.15),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                   color: Colors.white.withOpacity(0.2)),
//                             ),
//                             child: const Icon(Icons.assignment_outlined,
//                                 color: Colors.white, size: 20),
//                           ),
//                         ],
//                       ),
//
//                       const SizedBox(height: 18),
//
//                       // ── Search bar ─────────────────────────────────
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.15),
//                           borderRadius: BorderRadius.circular(14),
//                           border: Border.all(
//                               color: Colors.white.withOpacity(0.2)),
//                         ),
//                         child: TextField(
//                           controller: _searchController,
//                           style: const TextStyle(
//                               color: Colors.white, fontSize: 14),
//                           onChanged: (value) {
//                             setState(() {
//                               filteredUsers = users
//                                   .where((user) => user['examname']
//                                   .toString()
//                                   .toLowerCase()
//                                   .contains(value.toLowerCase()))
//                                   .toList();
//                             });
//                           },
//                           decoration: InputDecoration(
//                             hintText: 'Search by exam name...',
//                             hintStyle: TextStyle(
//                                 color: Colors.white.withOpacity(0.6),
//                                 fontSize: 13),
//                             prefixIcon: Icon(Icons.search,
//                                 color: Colors.white.withOpacity(0.7),
//                                 size: 20),
//                             border: InputBorder.none,
//                             contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 14),
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 12),
//
//                       // ── Exam count badge ───────────────────────────
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.13),
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(
//                               color: Colors.white.withOpacity(0.2)),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(Icons.format_list_numbered,
//                                 color: Colors.white70, size: 15),
//                             const SizedBox(width: 6),
//                             Text(
//                               '${filteredUsers.length} exam${filteredUsers.length == 1 ? '' : 's'}',
//                               style: const TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             // ── List ──────────────────────────────────────────────────
//             Expanded(
//               child: filteredUsers.isEmpty
//                   ? Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.assignment_outlined,
//                         size: 64,
//                         color: _sub.withOpacity(0.3)),
//                     const SizedBox(height: 12),
//                     Text('No exams found',
//                         style: TextStyle(
//                             fontSize: 15,
//                             color: _sub.withOpacity(0.6),
//                             fontWeight: FontWeight.w500)),
//                   ],
//                 ),
//               )
//                   : ListView.builder(
//                 physics: const BouncingScrollPhysics(),
//                 padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
//                 itemCount: filteredUsers.length,
//                 itemBuilder: (context, index) {
//                   final user = filteredUsers[index];
//                   return Container(
//                     margin: const EdgeInsets.only(bottom: 16),
//                     decoration: BoxDecoration(
//                       color: _card,
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: _divider),
//                       boxShadow: [
//                         BoxShadow(
//                           color: _primary.withOpacity(0.07),
//                           blurRadius: 14,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//
//                           // ── Exam name header ────────────────
//                           Row(
//                             children: [
//                               Container(
//                                 width: 40, height: 40,
//                                 decoration: BoxDecoration(
//                                   gradient: const LinearGradient(
//                                     colors: [_primary, _primaryLight],
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                   ),
//                                   borderRadius:
//                                   BorderRadius.circular(12),
//                                 ),
//                                 child: const Icon(
//                                     Icons.assignment_outlined,
//                                     color: Colors.white,
//                                     size: 20),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Text(user['examname'],
//                                     style: const TextStyle(
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.w800,
//                                         color: _text)),
//                               ),
//                             ],
//                           ),
//
//                           const SizedBox(height: 14),
//                           Divider(color: _divider, height: 1),
//                           const SizedBox(height: 12),
//
//                           // ── Date/time info ──────────────────
//                           _infoRow(Icons.calendar_today_outlined,
//                               'Start Date', user['startdate']),
//                           _infoRow(Icons.access_time_outlined,
//                               'Start Time', user['starttime']),
//                           _infoRow(Icons.event_outlined,
//                               'End Date', user['enddate']),
//                           _infoRow(Icons.timer_off_outlined,
//                               'End Time', user['endtime']),
//
//                           const SizedBox(height: 14),
//                           Divider(color: _divider, height: 1),
//                           const SizedBox(height: 12),
//
//                           // ── Action buttons — row 1 ──────────
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: _actionButton(
//                                   icon: Icons.quiz_outlined,
//                                   label: 'Questions',
//                                   onTap: () async {
//                                     SharedPreferences sh =
//                                     await SharedPreferences
//                                         .getInstance();
//                                     sh.setString('exam',
//                                         user['id'].toString());
//                                     Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                             builder: (context) =>
//                                                 view_question(
//                                                     title: '')));
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: _actionButton(
//                                   icon: Icons.inbox_outlined,
//                                   label: 'Exam Request',
//                                   outlined: true,
//                                   onTap: () async {
//                                     SharedPreferences sh =
//                                     await SharedPreferences
//                                         .getInstance();
//                                     sh.setString('eid',
//                                         user['exam'].toString());
//                                     Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                             builder: (context) =>
//                                                 ViewExamRequest(
//                                                     title: '')));
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//
//                           const SizedBox(height: 10),
//
//                           // ── Action buttons — row 2 ──────────
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: _actionButton(
//                                   icon: Icons.bar_chart_outlined,
//                                   label: 'Marks',
//                                   outlined: true,
//                                   onTap: () async {
//                                     SharedPreferences sh =
//                                     await SharedPreferences
//                                         .getInstance();
//                                     sh.setString('eid',
//                                         user['exam'].toString());
//                                     Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                             builder: (context) =>
//                                                 StaffViewMark(
//                                                     title: '')));
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: _actionButton(
//                                   icon: Icons.visibility_outlined,
//                                   label: 'Proctor Activities',
//                                   onTap: () async {
//                                     SharedPreferences sh =
//                                     await SharedPreferences
//                                         .getInstance();
//                                     sh.setString('eid',
//                                         user['exam'].toString());
//                                     Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                             builder: (context) =>
//                                                 viewproctoractivities(
//                                                     title: '')));
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'dart:convert';
//
// import 'package:ai_watcher/Staff/ViewproctorActivities.dart';
// import 'package:ai_watcher/Staff/add_question.dart';
// import 'package:ai_watcher/Staff/staff_home.dart';
// import 'package:ai_watcher/Staff/view_examrequest.dart';
// import 'package:ai_watcher/Staff/view_marks.dart';
// import 'package:ai_watcher/Staff/view_question.dart';
// import 'package:ai_watcher/candidate/ViewExamRequest.dart';
// // import 'package:easy_search_bar/easy_search_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
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
//       home: viewallocatedexam(title: 'View Users'),
//     );
//   }
// }
//
// class viewallocatedexam extends StatefulWidget {
//   const viewallocatedexam({super.key, required this.title});
//   final String title;
//
//   @override
//   State<viewallocatedexam> createState() => _viewallocatedexamState();
// }
//
// class _viewallocatedexamState extends State<viewallocatedexam> {
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
//       String apiUrl = '$urls/examinerviewallocatedexam/';
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
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//         onWillPop: () async {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const staff_home()),
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
//                   ElevatedButton(onPressed: ()async{
//                     SharedPreferences sh=await SharedPreferences.getInstance();
//                     sh.setString('exam',user['id'].toString());
//                     Navigator.push(context, MaterialPageRoute(builder: (context)=>view_question(title: '',)));
//
//                   }, child: Text('Question')),
//
//
//                   ElevatedButton(onPressed: ()async{
//                     SharedPreferences sh=await SharedPreferences.getInstance();
//                     sh.setString('eid', user['exam'].toString());
//                     Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewExamRequest(title: '',)));
//
//
//                   }, child: const Text("Exam Request")),
//
//
//                   ElevatedButton(onPressed: ()async{
//                     SharedPreferences sh=await SharedPreferences.getInstance();
//                     sh.setString('eid', user['exam'].toString());
//                     Navigator.push(context, MaterialPageRoute(builder: (context)=>StaffViewMark(title: '',)));
//
//
//                   }, child: const Text("Marks")),
//
//
//                   ElevatedButton(onPressed: ()async{
//                     SharedPreferences sh=await SharedPreferences.getInstance();
//                     sh.setString('eid', user['exam'].toString());
//                     Navigator.push(context, MaterialPageRoute(builder: (context)=>viewproctoractivities(title: '',)));
//
//
//                   }, child: const Text("Proctor Activities")),
//
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
}