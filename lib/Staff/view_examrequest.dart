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
      home: view_marks(title: 'View Users'),
    );
  }
}

class view_marks extends StatefulWidget {
  const view_marks({super.key, required this.title});
  final String title;

  @override
  State<view_marks> createState() => _view_marksState();
}

class _view_marksState extends State<view_marks> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterUsers);
    viewUsers("");
  }

  Future<void> viewUsers(String searchValue) async {
    setState(() => _isLoading = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String img = sh.getString('img_url') ?? '';
      String apiUrl = '$urls/flut_view_user/';

      var response = await http.post(Uri.parse(apiUrl), body: {});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'id': item['id'],
            'name': item['name'],
            'email': item['email'],
            'phone': item['phone'],
            'photo': img + item['photo'],
          });
        }
        setState(() {
          users = tempList;
          filteredUsers = tempList;
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsers = users.where((user) {
        return user['name'].toString().toLowerCase().contains(query);
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
          MaterialPageRoute(builder: (context) => const staff_home()),
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
                              MaterialPageRoute(
                                  builder: (context) => const staff_home()),
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
                              'Users',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                                hintText: 'Search by name...',
                                hintStyle: TextStyle(
                                    color: Colors.grey[400], fontSize: 15),
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

              // User List
              Expanded(
                child: _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF3B82F6),
                  ),
                )
                    : filteredUsers.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0E7FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_off_outlined,
                          size: 60,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No users found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF1E3A8A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try a different search',
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
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _buildUserCard(user, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, int index) {
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
      child: Row(
        children: [
          // Profile Picture
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.3) : Colors.grey[200]!,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE0E7FF),
              backgroundImage: user['photo'] != null && user['photo'].toString().isNotEmpty
                  ? NetworkImage(user['photo'])
                  : null,
              child: user['photo'] == null || user['photo'].toString().isEmpty
                  ? Icon(
                Icons.person,
                size: 40,
                color: isDark ? Colors.white : const Color(0xFF3B82F6),
              )
                  : null,
            ),
          ),
          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        user['name'],
                        style: TextStyle(
                          fontSize: 18,
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
                const SizedBox(height: 12),

                // Email
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: isDark ? Colors.white70 : const Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user['email'],
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Phone
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 16,
                      color: isDark ? Colors.white70 : const Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user['phone'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey[600],
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
}





// import 'dart:convert';
//
// import 'package:ai_watcher/Staff/add_question.dart';
// import 'package:ai_watcher/Staff/edit_question.dart';
// import 'package:ai_watcher/Staff/staff_home.dart';
// import 'package:ai_watcher/chat.dart';
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
//       home: ViewExamRequest(title: 'View Users'),
//     );
//   }
// }
//
// class ViewExamRequest extends StatefulWidget {
//   const ViewExamRequest({super.key, required this.title});
//   final String title;
//
//   @override
//   State<ViewExamRequest> createState() => _ViewExamRequestState();
// }
//
// class _ViewExamRequestState extends State<ViewExamRequest> {
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
//       String eid = sh.getString('eid') ?? '';
//       String apiUrl = '$urls/viewrequestexam/';
//
//       var response = await http.post(Uri.parse(apiUrl), body: {'eid': eid});
//       var jsonData = json.decode(response.body);
//
//       if (jsonData['status'] == 'ok') {
//         List<Map<String, dynamic>> tempList = [];
//         for (var item in jsonData['data']) {
//           tempList.add({
//             'id':item['id'].toString(),
//             'date': item['date'].toString(),
//             'status': item['status'].toString(),
//             'name': item['name'].toString(),
//             'email': item['email'].toString(),
//             'gender': item['gender'].toString(),
//             'phoneno': item['phoneno'].toString(),
//             'place': item['place'].toString(),
//             'state': item['state'].toString(),
//             'city': item['city'].toString(),
//             'dob': item['dob'].toString(),
//             'pin': item['pin'].toString(),
//             'photo': img+item['photo'].toString(),
//             'examname': item['examname'].toString(),
//             'startdate': item['startdate'].toString(),
//             'starttime': item['starttime'].toString(),
//             'enddate': item['enddate'].toString(),
//             'endtime': item['endtime'].toString(),
//             'ulid': item['ulid'].toString(),
//
//           });
//         }
//         setState(() {
//           users = tempList;
//           filteredUsers = tempList
//               .where((user) => user['date']
//                   .toString()
//                   .toLowerCase()
//                   .contains(searchValue.toLowerCase()))
//               .toList();
//           nameSuggestions =
//               users.map((e) => e['date'].toString()).toSet().toList();
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
//                   // title: Text(user['question'],
//                   //     style: TextStyle(fontWeight: FontWeight.bold)),
//                   leading: CircleAvatar(
//                     radius: 60,
//                     backgroundImage: NetworkImage(user['photo']),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("name: ${user['name']}"),
//                       Text("email: ${user['email']}"),
//                       Text("gender: ${user['gender']}"),
//                       Text("phoneno: ${user['phoneno']}"),
//                       Text("place: ${user['place']}"),
//                       Text("state: ${user['state']}"),
//                       Text("city: ${user['city']}"),
//                       Text("dob: ${user['dob']}"),
//                       Text("pin: ${user['pin']}"),
//                       Text("examname: ${user['examname']}"),
//                       Text("startdate: ${user['startdate']}"),
//                       Text("starttime: ${user['starttime']}"),
//                       Text("enddate: ${user['enddate']}"),
//                       Text("endtime: ${user['endtime']}"),
//                       Text("date: ${user['date']}"),
//                       Text("status: ${user['status']}"),
//
//
//                       user['status']=='pending'?ElevatedButton(
//                           onPressed: () async {
//                             SharedPreferences sh =
//                             await SharedPreferences.getInstance();
//                             String? url = sh.getString('url');
//                             String? exam = sh.getString('exam');
//
//                             if (url == null) {
//                               Fluttertoast.showToast(
//                                   msg: "Server URL not found.");
//                               return;
//                             }
//
//                             final uri =
//                             Uri.parse('$url/approve_examrequest/');
//                             var request =
//                             http.MultipartRequest('POST', uri);
//                             request.fields['erid'] = user['id'].toString();
//
//                             try {
//                               var response = await request.send();
//                               var respStr =
//                               await response.stream.bytesToString();
//                               var data = jsonDecode(respStr);
//
//                               if (response.statusCode == 200 &&
//                                   data['status'] == 'ok') {
//                                 Fluttertoast.showToast(
//                                     msg: "Approved successfully.");
//                                 viewUsers("");
//                               } else {
//                                 Fluttertoast.showToast(
//                                     msg: "Submission failed.");
//                               }
//                             } catch (e) {
//                               Fluttertoast.showToast(msg: "Error: $e");
//                             }
//                           },
//                           child: Text("Approve")):Text(''),
//
//
//                       user['status']=='pending'?ElevatedButton(
//                           onPressed: () async {
//                             SharedPreferences sh =
//                             await SharedPreferences.getInstance();
//                             String? url = sh.getString('url');
//                             String? exam = sh.getString('exam');
//
//                             if (url == null) {
//                               Fluttertoast.showToast(
//                                   msg: "Server URL not found.");
//                               return;
//                             }
//
//                             final uri =
//                             Uri.parse('$url/reject_examrequest/');
//                             var request =
//                             http.MultipartRequest('POST', uri);
//                             request.fields['erid'] = user['id'].toString();
//
//                             try {
//                               var response = await request.send();
//                               var respStr =
//                               await response.stream.bytesToString();
//                               var data = jsonDecode(respStr);
//
//                               if (response.statusCode == 200 &&
//                                   data['status'] == 'ok') {
//                                 Fluttertoast.showToast(
//                                     msg: "Rejected successfully.");
//                                 viewUsers("");
//                               } else {
//                                 Fluttertoast.showToast(
//                                     msg: "Submission failed.");
//                               }
//                             } catch (e) {
//                               Fluttertoast.showToast(msg: "Error: $e");
//                             }
//                           },
//                           child: Text("Reject")):Text(''),
//
//
//                       user['status']=='Approved'?ElevatedButton(
//                           onPressed: () async {
//                             SharedPreferences sh =
//                             await SharedPreferences.getInstance();
//                             sh.setString('toid', user['ulid'].toString());
//                             sh.setString('agrname', user['name'].toString());
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(builder: (context) => const MyChatPage(title: '',)),
//                             );
//                           },
//                           child: Text("Chat")):Text(''),
//
//
//
//                       // Row(
//                       //   children: [
//                       //
//                       //     ElevatedButton(
//                       //         onPressed: () async {
//                       //           SharedPreferences sh =
//                       //               await SharedPreferences.getInstance();
//                       //           String? url = sh.getString('url');
//                       //           String? exam = sh.getString('exam');
//                       //
//                       //           if (url == null) {
//                       //             Fluttertoast.showToast(
//                       //                 msg: "Server URL not found.");
//                       //             return;
//                       //           }
//                       //
//                       //           final uri =
//                       //               Uri.parse('$url/deletequestion/');
//                       //           var request =
//                       //               http.MultipartRequest('POST', uri);
//                       //           request.fields['id'] = user['id'].toString();
//                       //
//                       //           try {
//                       //             var response = await request.send();
//                       //             var respStr =
//                       //                 await response.stream.bytesToString();
//                       //             var data = jsonDecode(respStr);
//                       //
//                       //             if (response.statusCode == 200 &&
//                       //                 data['status'] == 'ok') {
//                       //               Fluttertoast.showToast(
//                       //                   msg: "deleted successfully.");
//                       //               viewUsers("");
//                       //             } else {
//                       //               Fluttertoast.showToast(
//                       //                   msg: "Submission failed.");
//                       //             }
//                       //           } catch (e) {
//                       //             Fluttertoast.showToast(msg: "Error: $e");
//                       //           }
//                       //         },
//                       //         child: Text("Approve")),
//                       //   ],
//                       // ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//
//         ));
//   }
// }
