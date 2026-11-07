import 'dart:convert';

import 'package:ai_watcher/Staff/add_question.dart';
import 'package:ai_watcher/Staff/edit_question.dart';
import 'package:ai_watcher/Staff/staff_home.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
      home: viewproctoractivities(title: 'View Users'),
    );
  }
}

class viewproctoractivities extends StatefulWidget {
  const viewproctoractivities({super.key, required this.title, this.preSelectedUser});
  final String title;
  final String? preSelectedUser;

  @override
  State<viewproctoractivities> createState() => _viewproctoractivitiesState();
}

class _viewproctoractivitiesState extends State<viewproctoractivities> {
  List<Map<String, dynamic>> users         = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<String> userList                    = [];

  String? _selectedUser;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedUser = widget.preSelectedUser;
    viewUsers("");
  }

  Future<void> viewUsers(String searchValue) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String exam = sh.getString('eid') ?? '';
      String apiUrl = '$urls/viewproctoractivities/';

      var response = await http.post(Uri.parse(apiUrl), body: {'exam': exam});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'id':           item['id'],
            'date':         item['date'],
            'activitytype': item['activitytype'],
            'activity':     item['activity'],
            'user':         item['user'],
          });
        }
        setState(() {
          users    = tempList;
          userList = tempList.map((e) => e['user'].toString()).toSet().toList();
          _applyFilter(searchValue);
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  void _applyFilter(String searchValue) {
    filteredUsers = users.where((u) {
      final matchSearch = u['activity']
          .toString()
          .toLowerCase()
          .contains(searchValue.toLowerCase());
      final matchUser =
          _selectedUser == null || u['user'].toString() == _selectedUser;
      return matchSearch && matchUser;
    }).toList();
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'warning':   return Colors.orange;
      case 'violation': return Colors.red;
      case 'info':      return _primaryLight;
      default:          return _primary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'warning':   return Icons.warning_amber_rounded;
      case 'violation': return Icons.gpp_bad_outlined;
      case 'info':      return Icons.info_outline_rounded;
      default:          return Icons.fiber_manual_record;
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: _primary, size: 13),
          ),
          const SizedBox(width: 10),
          Text('$label: ',
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: _sub)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: _text, height: 1.4)),
          ),
        ],
      ),
    );
  }

  // ── User picker tile ──────────────────────────────────────────────────────
  Widget _userTile({
    required String name,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _primary.withOpacity(0.07) : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isSelected ? _primary.withOpacity(0.3) : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                  colors: [_primary, _primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: isSelected ? null : _bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: isSelected ? Colors.white : _sub, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? _primary : _text)),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: _primary, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Bottom sheet user picker ──────────────────────────────────────────────
  void _showUserPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: const BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.only(
              topLeft:  Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: _divider,
                    borderRadius: BorderRadius.circular(2)),
              ),

              // Sheet header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_primary, _primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.people_outline,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select User',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _text)),
                          Text('Filter activities by user',
                              style: TextStyle(
                                  fontSize: 12, color: _sub)),
                        ],
                      ),
                    ),
                    if (_selectedUser != null)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedUser = null;
                            _applyFilter(_searchController.text);
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Text('Clear',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.withOpacity(0.8))),
                        ),
                      ),
                  ],
                ),
              ),

              Divider(color: _divider, height: 1),

              // All users option
              _userTile(
                name: 'All Users',
                icon: Icons.people_outline,
                isSelected: _selectedUser == null,
                onTap: () {
                  setState(() {
                    _selectedUser = null;
                    _applyFilter(_searchController.text);
                  });
                  Navigator.pop(context);
                },
              ),

              // Individual users
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: userList.length,
                  itemBuilder: (context, i) {
                    final name = userList[i];
                    return _userTile(
                      name: name,
                      icon: Icons.person_outline_rounded,
                      isSelected: _selectedUser == name,
                      onTap: () {
                        setState(() {
                          _selectedUser = name;
                          _applyFilter(_searchController.text);
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
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

                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(context,
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
                                Text('Proctor Activities',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                                Text('Monitor exam session activities',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white60)),
                              ],
                            ),
                          ),
                          // ── User filter icon button ──────────────
                          GestureDetector(
                            onTap: _showUserPicker,
                            child: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: _selectedUser != null
                                    ? Colors.white.withOpacity(0.35)
                                    : Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Icon(
                                _selectedUser != null
                                    ? Icons.person_rounded
                                    : Icons.people_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
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
                            setState(() => _applyFilter(value));
                          },
                          decoration: InputDecoration(
                            hintText: 'Search activities...',
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

                      // ── Count + active user chip ───────────────────
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
                                const Icon(Icons.format_list_numbered,
                                    color: Colors.white70, size: 15),
                                const SizedBox(width: 6),
                                Text(
                                  '${filteredUsers.length} activit${filteredUsers.length == 1 ? 'y' : 'ies'}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedUser != null) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedUser = null;
                                    _applyFilter(_searchController.text);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color:
                                        Colors.white.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.person_rounded,
                                          color: Colors.white, size: 14),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          _selectedUser!,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.close,
                                          color: Colors.white70, size: 14),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Activities List ───────────────────────────────────────
            Expanded(
              child: filteredUsers.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility_off_outlined,
                        size: 64, color: _sub.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text('No activities found',
                        style: TextStyle(
                            fontSize: 15,
                            color: _sub.withOpacity(0.6),
                            fontWeight: FontWeight.w500)),
                    if (_selectedUser != null) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedUser = null;
                            _applyFilter(_searchController.text);
                          });
                        },
                        child: const Text('Clear filter',
                            style: TextStyle(
                                fontSize: 13,
                                color: _primary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  final typeColor =
                  _typeColor(user['activitytype'].toString());
                  final typeIcon =
                  _typeIcon(user['activitytype'].toString());

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
                          Row(
                            children: [
                              Container(
                                width: 38, height: 38,
                                decoration: BoxDecoration(
                                  color: typeColor.withOpacity(0.12),
                                  borderRadius:
                                  BorderRadius.circular(11),
                                  border: Border.all(
                                      color:
                                      typeColor.withOpacity(0.3)),
                                ),
                                child: Icon(typeIcon,
                                    color: typeColor, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['activitytype'].toString(),
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: typeColor),
                                    ),
                                    Text(
                                      user['date'].toString(),
                                      style: const TextStyle(
                                          fontSize: 11, color: _sub),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _primary.withOpacity(0.08),
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                                child: Text('#${index + 1}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: _primary)),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          Divider(color: _divider, height: 1),
                          const SizedBox(height: 12),

                          _infoRow(Icons.description_outlined,
                              'Activity',
                              user['activity'].toString()),
                          _infoRow(Icons.person_outline_rounded,
                              'User', user['user'].toString()),
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
//       home: viewproctoractivities(title: 'View Users'),
//     );
//   }
// }
//
// class viewproctoractivities extends StatefulWidget {
//   const viewproctoractivities({super.key, required this.title});
//   final String title;
//
//   @override
//   State<viewproctoractivities> createState() => _viewproctoractivitiesState();
// }
//
// class _viewproctoractivitiesState extends State<viewproctoractivities> {
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
//       String exam = sh.getString('eid') ?? '';
//       String apiUrl = '$urls/viewproctoractivities/';
//
//       var response = await http.post(Uri.parse(apiUrl), body: {'exam': exam});
//       var jsonData = json.decode(response.body);
//
//       if (jsonData['status'] == 'ok') {
//         List<Map<String, dynamic>> tempList = [];
//         for (var item in jsonData['data']) {
//           tempList.add({
//             'id': item['id'],
//             'date': item['date'],
//             'activitytype': item['activitytype'],
//             'activity': item['activity'],
//             'user': item['user'],
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
//
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("date: ${user['date']}"),
//                       Text("activitytype: ${user['activitytype']}"),
//                       Text("activity: ${user['activity']}"),
//                       Text("user: ${user['user']}"),
//
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