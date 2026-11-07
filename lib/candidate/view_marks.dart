import 'dart:convert';

import 'package:ai_watcher/Staff/staff_home.dart';
import 'package:ai_watcher/candidate/candidate_home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ViewHouseApp());
}

class ViewHouseApp extends StatelessWidget {
  const ViewHouseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: view_marks(title: 'View Marks'),
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
const _green        = Color(0xFF2E7D32);
const _greenLight   = Color(0xFFE8F5E9);
// ─────────────────────────────────────────────────────────────────────────────

class view_marks extends StatefulWidget {
  const view_marks({super.key, required this.title});
  final String title;

  @override
  State<view_marks> createState() => _view_marksState();
}

class _view_marksState extends State<view_marks> {
  List<Map<String, dynamic>> marks         = [];
  List<Map<String, dynamic>> filteredMarks = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterMarks);
    viewMarks();
  }

  Future<void> viewMarks() async {
    setState(() => _isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String lid  = sh.getString('lid') ?? '';

      String apiUrl = '$urls/candidateviewmark/';

      var response = await http.post(
        Uri.parse(apiUrl),
        body: {'lid': lid},
      );

      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'id'             : item['id'],
            'mark'           : item['mark'],
            'total_questions': item['total_questions'] ?? 0,
            'examname'       : item['examname'],
            'examdate'       : item['examdate'],
          });
        }
        setState(() {
          marks         = tempList;
          filteredMarks = tempList;
        });
      }
    } catch (e) {
      print("Error fetching marks: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterMarks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredMarks = marks.where((item) {
        return item['examname'].toString().toLowerCase().contains(query);
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
                  bottomLeft:  Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Stack(
                children: [
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
                                Text('My Marks',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                                Text('Your exam results',
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
                            child: const Icon(Icons.grade_outlined,
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

                      // ── Count row ──────────────────────────
                      Row(
                        children: [
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
                                const Icon(Icons.assignment_outlined,
                                    color: Colors.white70, size: 15),
                                const SizedBox(width: 6),
                                Text(
                                  '${filteredMarks.length} result${filteredMarks.length == 1 ? '' : 's'}',
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
                ],
              ),
            ),

            // ── List ──────────────────────────────────────────────────
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
                      child: const Icon(Icons.grade_outlined,
                          color: _primary, size: 30),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(
                      width: 26, height: 26,
                      child: CircularProgressIndicator(
                          color: _primary, strokeWidth: 2.5),
                    ),
                    const SizedBox(height: 10),
                    const Text('Loading marks...',
                        style: TextStyle(fontSize: 13, color: _sub)),
                  ],
                ),
              )
                  : filteredMarks.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.assignment_outlined,
                        size: 64, color: _sub.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text('No marks found',
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
                itemCount: filteredMarks.length,
                itemBuilder: (context, index) {
                  final item = filteredMarks[index];
                  return _buildMarkCard(item, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkCard(Map<String, dynamic> item, int index) {
    final int mark  = int.tryParse(item['mark'].toString()) ?? 0;
    final int total = int.tryParse(item['total_questions'].toString()) ?? 1;
    final bool isPassing = total > 0 && (mark / total) >= 0.5;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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

            // ── Top row: icon + examname + index badge ──
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                      Icons.menu_book,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['examname'] ?? '',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _text),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item['examdate'].toString(),
                        style: const TextStyle(
                            fontSize: 11, color: _sub),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('#${index + 1}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _primary)),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Divider(color: _divider, height: 1),
            const SizedBox(height: 12),

            // ── Mark highlight row ─────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _primary.withOpacity(0.06),
                    _primaryLight.withOpacity(0.03),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _primary.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: isPassing
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                        isPassing
                            ? Icons.check_circle_outline_rounded
                            : Icons.cancel_outlined,
                        color: isPassing ? _green : Colors.red.shade700,
                        size: 15),
                  ),
                  const SizedBox(width: 10),
                  const Text('Mark',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _sub)),
                  const Spacer(),
                  Text(
                    '$mark / $total',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _primary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Pass / Fail badge ─────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isPassing
                        ? Colors.green.withOpacity(0.08)
                        : Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: isPassing
                            ? Colors.green.withOpacity(0.25)
                            : Colors.red.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          isPassing
                              ? Icons.check_circle_outline_rounded
                              : Icons.cancel_outlined,
                          color: isPassing
                              ? Colors.green.withOpacity(0.8)
                              : Colors.red.withOpacity(0.8),
                          size: 13),
                      const SizedBox(width: 5),
                      Text(
                        isPassing ? 'Pass' : 'Fail',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isPassing
                                ? Colors.green.withOpacity(0.8)
                                : Colors.red.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}









// import 'dart:convert';
//
// import 'package:ai_watcher/Staff/staff_home.dart';
// import 'package:ai_watcher/candidate/candidate_home.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
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
//       home: view_marks(title: 'View Marks'),
//     );
//   }
// }
//
// // ─── Theme ────────────────────────────────────────────────────────────────────
// const _primary      = Color(0xFF194569);
// const _primaryLight = Color(0xFF2A6096);
// const _bg           = Color(0xFFF0F4F8);
// const _card         = Colors.white;
// const _text         = Color(0xFF0D1F2D);
// const _sub          = Color(0xFF607D8B);
// const _divider      = Color(0xFFE8EEF4);
// const _green        = Color(0xFF2E7D32);
// const _greenLight   = Color(0xFFE8F5E9);
// // ─────────────────────────────────────────────────────────────────────────────
//
// class view_marks extends StatefulWidget {
//   const view_marks({super.key, required this.title});
//   final String title;
//
//   @override
//   State<view_marks> createState() => _view_marksState();
// }
//
// class _view_marksState extends State<view_marks> {
//   List<Map<String, dynamic>> marks         = [];
//   List<Map<String, dynamic>> filteredMarks = [];
//   bool _isLoading = true;
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_filterMarks);
//     viewMarks();
//   }
//
//   Future<void> viewMarks() async {
//     setState(() => _isLoading = true);
//
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String urls = sh.getString('url') ?? '';
//       // ✅ FIX 1: Get the logged-in user's ID from SharedPreferences
//       String lid  = sh.getString('lid') ?? '';
//
//       String apiUrl = '$urls/candidateviewmark/';
//
//       // ✅ FIX 2: Send lid in the POST body
//       var response = await http.post(
//         Uri.parse(apiUrl),
//         body: {'lid': lid},
//       );
//
//       var jsonData = json.decode(response.body);
//
//       if (jsonData['status'] == 'ok') {
//         List<Map<String, dynamic>> tempList = [];
//         for (var item in jsonData['data']) {
//           tempList.add({
//             'id'      : item['id'],
//             'mark'    : item['mark'],
//             'examname': item['examname'],
//             'examdate': item['examdate'],
//           });
//         }
//         setState(() {
//           marks         = tempList;
//           filteredMarks = tempList;
//         });
//       }
//     } catch (e) {
//       print("Error fetching marks: $e");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   // ✅ FIX 3: Filter by examname instead of non-existent 'name'
//   void _filterMarks() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       filteredMarks = marks.where((item) {
//         return item['examname'].toString().toLowerCase().contains(query);
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
//         backgroundColor: _bg,
//         body: Column(
//           children: [
//             // ── Header ───────────────────────────────────────────────────────
//             Container(
//               padding: const EdgeInsets.fromLTRB(20, 54, 20, 20),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [_primary, _primaryLight],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.only(
//                   bottomLeft:  Radius.circular(28),
//                   bottomRight: Radius.circular(28),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Back + title row
//                   Row(
//                     children: [
//                       GestureDetector(
//                         onTap: () => Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                               builder: (_) => const CandidateHome()),
//                         ),
//                         child: Container(
//                           width: 38, height: 38,
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.15),
//                             borderRadius: BorderRadius.circular(11),
//                             border: Border.all(
//                                 color: Colors.white.withOpacity(0.2)),
//                           ),
//                           child: const Icon(Icons.arrow_back_ios_new,
//                               color: Colors.white, size: 16),
//                         ),
//                       ),
//                       const SizedBox(width: 14),
//                       const Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'My Marks',
//                               style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.w800,
//                                   color: Colors.white),
//                             ),
//                             Text(
//                               'Your exam results',
//                               style: TextStyle(
//                                   fontSize: 12, color: Colors.white60),
//                             ),
//                           ],
//                         ),
//                       ),
//                       // Count pill
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.15),
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                               color: Colors.white.withOpacity(0.2)),
//                         ),
//                         child: Text(
//                           '${filteredMarks.length} exams',
//                           style: const TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.white),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 16),
//
//                   // Search bar
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 14, vertical: 12),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.13),
//                       borderRadius: BorderRadius.circular(13),
//                       border: Border.all(
//                           color: Colors.white.withOpacity(0.2)),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.search_rounded,
//                             color: Colors.white60, size: 20),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: TextField(
//                             controller: _searchController,
//                             style: const TextStyle(
//                                 color: Colors.white, fontSize: 14),
//                             decoration: InputDecoration(
//                               hintText: 'Search by exam name...',
//                               hintStyle: TextStyle(
//                                   color: Colors.white.withOpacity(0.45),
//                                   fontSize: 14),
//                               border: InputBorder.none,
//                               isDense: true,
//                               contentPadding: EdgeInsets.zero,
//                             ),
//                           ),
//                         ),
//                         if (_searchController.text.isNotEmpty)
//                           GestureDetector(
//                             onTap: () {
//                               _searchController.clear();
//                               _filterMarks();
//                             },
//                             child: const Icon(Icons.close,
//                                 color: Colors.white54, size: 18),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // ── Body ─────────────────────────────────────────────────────────
//             Expanded(
//               child: _isLoading
//                   ? Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 64, height: 64,
//                       decoration: BoxDecoration(
//                         color: _primary.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(18),
//                       ),
//                       child: const Icon(Icons.grade_outlined,
//                           color: _primary, size: 30),
//                     ),
//                     const SizedBox(height: 16),
//                     const SizedBox(
//                       width: 26, height: 26,
//                       child: CircularProgressIndicator(
//                           color: _primary, strokeWidth: 2.5),
//                     ),
//                     const SizedBox(height: 10),
//                     const Text('Loading marks...',
//                         style: TextStyle(fontSize: 13, color: _sub)),
//                   ],
//                 ),
//               )
//                   : filteredMarks.isEmpty
//                   ? Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 72, height: 72,
//                       decoration: BoxDecoration(
//                         color: _primary.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: const Icon(
//                           Icons.assignment_outlined,
//                           color: _primary, size: 34),
//                     ),
//                     const SizedBox(height: 14),
//                     const Text('No marks found',
//                         style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                             color: _text)),
//                     const SizedBox(height: 4),
//                     const Text('No exam results available yet',
//                         style:
//                         TextStyle(fontSize: 12, color: _sub)),
//                   ],
//                 ),
//               )
//                   : ListView.builder(
//                 physics: const BouncingScrollPhysics(),
//                 padding:
//                 const EdgeInsets.fromLTRB(16, 16, 16, 100),
//                 itemCount: filteredMarks.length,
//                 itemBuilder: (context, index) {
//                   final item = filteredMarks[index];
//                   return _buildMarkCard(item, index);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ✅ FIX 4: Card now shows examname, mark, examdate correctly
//   Widget _buildMarkCard(Map<String, dynamic> item, int index) {
//     final isDark = index % 2 == 0;
//
//     // Determine mark colour (green if pass, red if fail — adjust threshold as needed)
//     final int mark = int.tryParse(item['mark'].toString()) ?? 0;
//     final bool isPassing = mark >= 50;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: isDark ? _primary : _card,
//         borderRadius: BorderRadius.circular(20),
//         border: isDark
//             ? null
//             : Border.all(color: _divider, width: 1),
//         boxShadow: [
//           BoxShadow(
//             color: isDark
//                 ? _primary.withOpacity(0.28)
//                 : Colors.black.withOpacity(0.04),
//             blurRadius: 14,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             // ── Mark Circle ──────────────────────────────────────────────
//             Container(
//               width: 60, height: 60,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: isDark
//                     ? Colors.white.withOpacity(0.12)
//                     : (isPassing
//                     ? _greenLight
//                     : Colors.red.shade50),
//                 border: Border.all(
//                   color: isDark
//                       ? Colors.white.withOpacity(0.25)
//                       : (isPassing
//                       ? _green.withOpacity(0.4)
//                       : Colors.red.withOpacity(0.3)),
//                   width: 2,
//                 ),
//               ),
//               child: Center(
//                 child: Text(
//                   '$mark',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                     color: isDark
//                         ? Colors.white
//                         : (isPassing ? _green : Colors.red.shade700),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 14),
//
//             // ── Info ─────────────────────────────────────────────────────
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Exam Name + index badge
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           item['examname'] ?? '',
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w700,
//                             color: isDark ? Colors.white : _text,
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 3),
//                         decoration: BoxDecoration(
//                           color: isDark
//                               ? Colors.white.withOpacity(0.15)
//                               : _primary.withOpacity(0.08),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           '#${index + 1}',
//                           style: TextStyle(
//                             fontSize: 10,
//                             fontWeight: FontWeight.w700,
//                             color: isDark ? Colors.white70 : _primary,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//
//                   // Exam Date
//                   _infoRow(
//                     Icons.calendar_today_outlined,
//                     'Date: ${item['examdate'] ?? 'N/A'}',
//                     isDark: isDark,
//                   ),
//                   const SizedBox(height: 6),
//
//                   // Pass / Fail badge
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: isDark
//                           ? Colors.white.withOpacity(0.12)
//                           : (isPassing
//                           ? _greenLight
//                           : Colors.red.shade50),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       isPassing ? '✅ Pass' : '❌ Fail',
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                         color: isDark
//                             ? Colors.white70
//                             : (isPassing
//                             ? _green
//                             : Colors.red.shade700),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _infoRow(IconData icon, String value, {required bool isDark}) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           size: 13,
//           color: isDark
//               ? Colors.white.withOpacity(0.55)
//               : _primary.withOpacity(0.6),
//         ),
//         const SizedBox(width: 7),
//         Expanded(
//           child: Text(
//             value,
//             style: TextStyle(
//               fontSize: 12,
//               color: isDark ? Colors.white.withOpacity(0.7) : _sub,
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }