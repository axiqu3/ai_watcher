import 'dart:convert';

import 'package:ai_watcher/Staff/add_question.dart';
import 'package:ai_watcher/Staff/edit_question.dart';
import 'package:ai_watcher/Staff/staff_home.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'ai_question_generator.dart';
import 'viewallocatedexam.dart';

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
      home: view_question(title: 'View Questions'),
    );
  }
}

class view_question extends StatefulWidget {
  const view_question({super.key, required this.title});
  final String title;

  @override
  State<view_question> createState() => _view_questionState();
}

class _view_questionState extends State<view_question> {
  List<Map<String, dynamic>> users         = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<String> nameSuggestions             = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    viewUsers("");
  }

  Future<void> viewUsers(String searchValue) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls  = sh.getString('url')  ?? '';
      String exam  = sh.getString('exam') ?? '';
      String apiUrl = '$urls/examinerviewquestion/';

      var response = await http.post(Uri.parse(apiUrl), body: {'exam': exam});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'id':      item['id'],
            'question': item['question'],
            'option1':  item['option1'],
            'option2':  item['option2'],
            'option3':  item['option3'],
            'option4':  item['option4'],
            'answer':   item['answer'],
          });
        }
        setState(() {
          users = tempList;
          filteredUsers = tempList
              .where((user) => user['question']
              .toString()
              .toLowerCase()
              .contains(searchValue.toLowerCase()))
              .toList();
          nameSuggestions =
              users.map((e) => e['question'].toString()).toSet().toList();
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  Widget _optionChip(String letter, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24, height: 24,
            margin: const EdgeInsets.only(right: 8, top: 1),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: _primary.withOpacity(0.2)),
            ),
            child: Center(
              child: Text(letter,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _primary)),
            ),
          ),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13, color: _text, height: 1.4)),
          ),
        ],
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

            // ── Gradient Header ────────────────────────────────────────
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
                            onTap: () => Navigator.pushReplacement(context,
                                MaterialPageRoute(
                                    builder: (_) => const viewallocatedexam(title: '',))),
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
                                Text('Question Bank',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                                Text('Manage your exam questions',
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
                            child: const Icon(Icons.quiz_outlined,
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
                                  .where((user) => user['question']
                                  .toString()
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                                  .toList();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search questions...',
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

                      // ── Question count ─────────────────────────────
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
                              '${filteredUsers.length} question${filteredUsers.length == 1 ? '' : 's'}',
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
                    Icon(Icons.quiz_outlined,
                        size: 64,
                        color: _sub.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text('No questions found',
                        style: TextStyle(
                            fontSize: 15,
                            color: _sub.withOpacity(0.6),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
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

                          // ── Question number + text ──────────
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32, height: 32,
                                margin:
                                const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_primary, _primaryLight],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(9),
                                ),
                                child: Center(
                                  child: Text('${index + 1}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight:
                                          FontWeight.w800)),
                                ),
                              ),
                              Expanded(
                                child: Text(user['question'],
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: _text,
                                        height: 1.4)),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),
                          Divider(color: _divider, height: 1),
                          const SizedBox(height: 12),

                          // ── Options ──────────────────────────
                          _optionChip('A', user['option1']),
                          _optionChip('B', user['option2']),
                          _optionChip('C', user['option3']),
                          _optionChip('D', user['option4']),

                          const SizedBox(height: 8),

                          // ── Answer badge ─────────────────────
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _primary.withOpacity(0.08),
                                  _primaryLight.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: _primary.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: _primary, size: 16),
                                const SizedBox(width: 8),
                                const Text('Answer: ',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _sub)),
                                Expanded(
                                  child: Text(user['answer'],
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: _primary)),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),
                          Divider(color: _divider, height: 1),
                          const SizedBox(height: 10),

                          // ── Action buttons ───────────────────
                          Row(
                            children: [
                              // Edit button
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditQuestions(
                                              title: '',
                                              question: user['question']
                                                  .toString(),
                                              option1: user['option1']
                                                  .toString(),
                                              option2: user['option2']
                                                  .toString(),
                                              option3: user['option3']
                                                  .toString(),
                                              option4: user['option4']
                                                  .toString(),
                                              answer: user['answer']
                                                  .toString(),
                                              id: user['id'].toString(),
                                            ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          _primary,
                                          _primaryLight
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius:
                                      BorderRadius.circular(11),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.edit_outlined,
                                            color: Colors.white,
                                            size: 15),
                                        SizedBox(width: 6),
                                        Text('Edit',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight:
                                                FontWeight.w700)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              // Delete button
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    SharedPreferences sh =
                                    await SharedPreferences
                                        .getInstance();
                                    String? url = sh.getString('url');

                                    if (url == null) {
                                      Fluttertoast.showToast(
                                          msg:
                                          "Server URL not found.");
                                      return;
                                    }

                                    final uri = Uri.parse(
                                        '$url/deletequestion/');
                                    var request =
                                    http.MultipartRequest(
                                        'POST', uri);
                                    request.fields['id'] =
                                        user['id'].toString();

                                    try {
                                      var response =
                                      await request.send();
                                      var respStr = await response
                                          .stream
                                          .bytesToString();
                                      var data = jsonDecode(respStr);

                                      if (response.statusCode == 200 &&
                                          data['status'] == 'ok') {
                                        Fluttertoast.showToast(
                                            msg:
                                            "Deleted successfully.");
                                        viewUsers("");
                                      } else {
                                        Fluttertoast.showToast(
                                            msg:
                                            "Deletion failed.");
                                      }
                                    } catch (e) {
                                      Fluttertoast.showToast(
                                          msg: "Error: $e");
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _card,
                                      borderRadius:
                                      BorderRadius.circular(11),
                                      border: Border.all(
                                          color: Colors.red
                                              .withOpacity(0.4),
                                          width: 1.5),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.delete_outline,
                                            color: Colors.red
                                                .withOpacity(0.8),
                                            size: 15),
                                        const SizedBox(width: 6),
                                        Text('Delete',
                                            style: TextStyle(
                                                color: Colors.red
                                                    .withOpacity(0.8),
                                                fontSize: 13,
                                                fontWeight:
                                                FontWeight.w700)),
                                      ],
                                    ),
                                  ),
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

        // ── FAB ──────────────────────────────────────────────────────
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── AI Generate mini button ──
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6A11CB).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const ai_question_generator(title: '',)));
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text('AI Generate',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // ── Existing Add Question button ──
            Container(
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const add_question(title: '')));
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Add Question',
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
      ),
    );
  }
}






// import 'dart:convert';
//
// import 'package:ai_watcher/Staff/add_question.dart';
// import 'package:ai_watcher/Staff/edit_question.dart';
// import 'package:ai_watcher/Staff/staff_home.dart';
// // import 'package:easy_search_bar/easy_search_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
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
//       home: view_question(title: 'View Users'),
//     );
//   }
// }
//
// class view_question extends StatefulWidget {
//   const view_question({super.key, required this.title});
//   final String title;
//
//   @override
//   State<view_question> createState() => _view_questionState();
// }
//
// class _view_questionState extends State<view_question> {
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
//       String exam = sh.getString('exam') ?? '';
//       String apiUrl = '$urls/examinerviewquestion/';
//
//       var response = await http.post(Uri.parse(apiUrl), body: {'exam': exam});
//       var jsonData = json.decode(response.body);
//
//       if (jsonData['status'] == 'ok') {
//         List<Map<String, dynamic>> tempList = [];
//         for (var item in jsonData['data']) {
//           tempList.add({
//             'id': item['id'],
//             'question': item['question'],
//             'option1': item['option1'],
//             'option2': item['option2'],
//             'option3': item['option3'],
//             'option4': item['option4'],
//             'answer': item['answer'],
//           });
//         }
//         setState(() {
//           users = tempList;
//           filteredUsers = tempList
//               .where((user) => user['question']
//                   .toString()
//                   .toLowerCase()
//                   .contains(searchValue.toLowerCase()))
//               .toList();
//           nameSuggestions =
//               users.map((e) => e['question'].toString()).toSet().toList();
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
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const staff_home()),
//           );
//           return false; // Prevent default pop
//         },
//         child: Scaffold(
//           appBar: AppBar(
//             backgroundColor: Color.fromARGB(255, 232, 177, 61),
//             title: Text('Search by name'),
//             // suggestions: nameSuggestions,
//             // onSearch: (value) {
//             //   setState(() {
//             //     filteredUsers = users
//             //         .where((user) => user['name']
//             //         .toString()
//             //         .toLowerCase()
//             //         .contains(value.toLowerCase()))
//             //         .toList();
//             //   });
//             // },
//           ),
//           body: ListView.builder(
//             shrinkWrap: true,
//             physics: BouncingScrollPhysics(),
//             itemCount: filteredUsers.length,
//             itemBuilder: (context, index) {
//               final user = filteredUsers[index];
//               return Card(
//                 margin: const EdgeInsets.all(10),
//                 elevation: 5,
//                 child: ListTile(
//                   title: Text(user['question'],
//                       style: TextStyle(fontWeight: FontWeight.bold)),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("option1: ${user['option1']}"),
//                       Text("option2: ${user['option2']}"),
//                       Text("option3: ${user['option3']}"),
//                       Text("option4: ${user['option4']}"),
//                       Text("answer: ${user['answer']}"),
//                       Row(
//                         children: [
//                           ElevatedButton(onPressed: () {
//                             Navigator.push(context, MaterialPageRoute(builder: (context)=>EditQuestions(title: '',
//                               question: user['question'].toString(), option1: user['option1'].toString(),
//                               option2: user['option2'].toString(), option3: user['option3'].toString(),
//                               option4: user['option4'].toString(), answer:user['answer '].toString(),
//                               id: user['id'].toString(),)));
//
//                           }, child: Text("edit")),
//
//                           ElevatedButton(
//                               onPressed: () async {
//                                 SharedPreferences sh =
//                                     await SharedPreferences.getInstance();
//                                 String? url = sh.getString('url');
//                                 String? exam = sh.getString('exam');
//
//                                 if (url == null) {
//                                   Fluttertoast.showToast(
//                                       msg: "Server URL not found.");
//                                   return;
//                                 }
//
//                                 final uri =
//                                     Uri.parse('$url/deletequestion/');
//                                 var request =
//                                     http.MultipartRequest('POST', uri);
//                                 request.fields['id'] = user['id'].toString();
//
//                                 try {
//                                   var response = await request.send();
//                                   var respStr =
//                                       await response.stream.bytesToString();
//                                   var data = jsonDecode(respStr);
//
//                                   if (response.statusCode == 200 &&
//                                       data['status'] == 'ok') {
//                                     Fluttertoast.showToast(
//                                         msg: "deleted successfully.");
//                                     viewUsers("");
//                                   } else {
//                                     Fluttertoast.showToast(
//                                         msg: "Submission failed.");
//                                   }
//                                 } catch (e) {
//                                   Fluttertoast.showToast(msg: "Error: $e");
//                                 }
//                               },
//                               child: Text("Delete")),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//           floatingActionButton: FloatingActionButton(onPressed: () {
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => add_question(
//                           title: '',
//                         )));
//           }),
//         ));
//   }
// }