import 'dart:convert';

import 'package:ai_watcher/Staff/add_question.dart';
import 'package:ai_watcher/Staff/staff_home.dart';
import 'package:ai_watcher/Staff/view_question.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'candidate_home.dart';
import 'send complaint.dart';

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
  runApp(const viewreply());
}

class viewreply extends StatelessWidget {
  const viewreply({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: viewreplypage(title: 'View Users'),
    );
  }
}

class viewreplypage extends StatefulWidget {
  const viewreplypage({super.key, required this.title});
  final String title;

  @override
  State<viewreplypage> createState() => _viewreplypageState();
}

class _viewreplypageState extends State<viewreplypage> {
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    viewUsers("");
  }

  Future<void> viewUsers(String searchValue) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String lid = sh.getString('lid').toString();
      String apiUrl = '$urls/userviewreply/';

      var response = await http.post(Uri.parse(apiUrl), body: {'lid': lid});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'id':        item['id'].toString(),
            'complaint': item['complaint'].toString(),
            'reply':     item['reply'].toString(),
            'status':    item['status'].toString(),
            'date':      item['date'].toString(),
          });
        }
        setState(() {
          users = tempList;
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  // ── Status badge color ────────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':  return const Color(0xFF1A7A6E);
      case 'pending':   return const Color(0xFFE67E22);
      case 'rejected':  return Colors.red;
      default:          return _sub;
    }
  }

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':  return const Color(0xFFE6F7F5);
      case 'pending':   return const Color(0xFFFFF3E0);
      case 'rejected':  return const Color(0xFFFFEBEE);
      default:          return _bg;
    }
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
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const CandidateHome()),
                    ),
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
                        Text('My Complaints',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        Text('Track your submitted complaints',
                            style: TextStyle(fontSize: 12, color: Colors.white60)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Text(
                      '${users.length} total',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // ── List ──────────────────────────────────────────────────────
            Expanded(
              child: users.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.inbox_outlined, color: _primary, size: 34),
                    ),
                    const SizedBox(height: 14),
                    const Text('No complaints yet',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600, color: _text)),
                    const SizedBox(height: 4),
                    const Text('Tap + to submit a new complaint',
                        style: TextStyle(fontSize: 12, color: _sub)),
                  ],
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _buildComplaintCard(user, index);
                },
              ),
            ),
          ],
        ),

        // ── FAB ──────────────────────────────────────────────────────────
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primary, _primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CandidateSentReplay(title: '')),
              );
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // ── Complaint Card ────────────────────────────────────────────────────────
  Widget _buildComplaintCard(Map<String, dynamic> user, int index) {
    final statusColor = _statusColor(user['status']);
    final statusBg    = _statusBg(user['status']);

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
              border: const Border(bottom: BorderSide(color: _divider, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_primary, _primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flag_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Complaint #${user['id']}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700, color: _text)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 11, color: _sub),
                          const SizedBox(width: 4),
                          Text(user['date'],
                              style: const TextStyle(fontSize: 11, color: _sub)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 7, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        user['status'],
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Complaint text ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit_note_outlined,
                        size: 14, color: _primary.withOpacity(0.7)),
                    const SizedBox(width: 6),
                    const Text('Complaint',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600, color: _sub)),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _primary.withOpacity(0.08)),
                  ),
                  child: Text(
                    user['complaint'],
                    style: const TextStyle(fontSize: 13, color: _text, height: 1.4),
                  ),
                ),
              ],
            ),
          ),

          // ── Reply text ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.reply_outlined,
                        size: 14, color: _primary.withOpacity(0.7)),
                    const SizedBox(width: 6),
                    const Text('Reply',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600, color: _sub)),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: user['reply'].toString().isEmpty ||
                        user['reply'].toString() == 'null'
                        ? _bg
                        : const Color(0xFFE6F7F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: user['reply'].toString().isEmpty ||
                          user['reply'].toString() == 'null'
                          ? _primary.withOpacity(0.08)
                          : const Color(0xFF1A7A6E).withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    user['reply'].toString().isEmpty ||
                        user['reply'].toString() == 'null'
                        ? 'No reply yet...'
                        : user['reply'],
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: user['reply'].toString().isEmpty ||
                          user['reply'].toString() == 'null'
                          ? _sub
                          : _text,
                      fontStyle: user['reply'].toString().isEmpty ||
                          user['reply'].toString() == 'null'
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




// import 'dart:convert';
//
// import 'package:ai_watcher/Staff/add_question.dart';
// import 'package:ai_watcher/Staff/staff_home.dart';
// import 'package:ai_watcher/Staff/view_question.dart';
// // import 'package:easy_search_bar/easy_search_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// import 'candidate_home.dart';
// import 'send complaint.dart';
//
//
//
// void main() {
//   runApp(const viewreply());
// }
//
// class viewreply extends StatelessWidget {
//   const viewreply({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: viewreplypage(title: 'View Users'),
//     );
//   }
// }
//
// class viewreplypage extends StatefulWidget {
//   const viewreplypage({super.key, required this.title});
//   final String title;
//
//   @override
//   State<viewreplypage> createState() => _viewreplypageState();
// }
//
// class _viewreplypageState extends State<viewreplypage> {
//   List<Map<String, dynamic>> users = [];
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
//       String lid = sh.getString('lid').toString();
//       String apiUrl = '$urls/userviewreply/';
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
//             'complaint': item['complaint'].toString(),
//             'reply': item['reply'].toString(),
//             'status': item['status'].toString(),
//             'date': item['date'].toString(),
//
//           });
//         }
//         setState(() {
//           users = tempList;
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
//         itemCount: users.length,
//         itemBuilder: (context, index) {
//           final user = users[index];
//           return Card(
//             margin: const EdgeInsets.all(10),
//             elevation: 5,
//             child: ListTile(
//               // leading: CircleAvatar(
//               //   backgroundImage: NetworkImage(user['photo']),
//               //   radius: 30,
//               // ),
//               // title: Text(user['examname'], style: TextStyle(fontWeight: FontWeight.bold)),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//
//                   // Text("examname: ${user['examname']}"),
//                   Text("Date: ${user['date']}"),
//                   Text("Complaint: ${user['complaint']}"),
//                   Text("Status: ${user['status']}"),
//                   Text("Reply: ${user['reply']}"),
//                   SizedBox(height: 20,),
//
//
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(onPressed: (){
//         Navigator.push(context, MaterialPageRoute(builder: (context)=>CandidateSentReplay(title: '',)));
//       },child: Icon(Icons.add),),
//     ));
//   }
// }
