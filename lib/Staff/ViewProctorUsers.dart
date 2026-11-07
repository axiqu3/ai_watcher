import 'dart:convert';

import 'package:ai_watcher/Staff/ViewproctorActivities.dart';
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

class ViewProctorUsers extends StatefulWidget {
  const ViewProctorUsers({super.key, required this.title});
  final String title;

  @override
  State<ViewProctorUsers> createState() => _ViewProctorUsersState();
}

class _ViewProctorUsersState extends State<ViewProctorUsers> {
  List<String> userList         = [];
  List<String> filteredUserList = [];
  Map<String, int> userActivityCount = {};
  bool _loading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url') ?? '';
      String exam = sh.getString('eid') ?? '';
      String apiUrl = '$urls/viewproctoractivities/';

      var response = await http.post(Uri.parse(apiUrl), body: {'exam': exam});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        Map<String, int> countMap = {};
        for (var item in jsonData['data']) {
          String user = item['user'].toString();
          countMap[user] = (countMap[user] ?? 0) + 1;
        }
        setState(() {
          userActivityCount = countMap;
          userList          = countMap.keys.toList();
          filteredUserList  = userList;
          _loading          = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      print("Error: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
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
                            onTap: () => Navigator.pop(context),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title.isNotEmpty
                                      ? widget.title
                                      : 'Proctor Activities',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white),
                                ),
                                const Text('Select a candidate to view activities',
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
                            child: const Icon(Icons.people_outline,
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
                              filteredUserList = userList
                                  .where((u) => u
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                                  .toList();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search candidates...',
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

                      // ── Count badge ────────────────────────────────
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
                            const Icon(Icons.people_outline,
                                color: Colors.white70, size: 15),
                            const SizedBox(width: 6),
                            Text(
                              '${filteredUserList.length} candidate${filteredUserList.length == 1 ? '' : 's'}',
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

            // ── User list ─────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(
                child: CircularProgressIndicator(color: _primary),
              )
                  : filteredUserList.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline,
                        size: 64,
                        color: _sub.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    Text('No candidates found',
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
                itemCount: filteredUserList.length,
                itemBuilder: (context, index) {
                  final userName = filteredUserList[index];
                  final count =
                      userActivityCount[userName] ?? 0;

                  return GestureDetector(
                    onTap: () {
                      // Navigate to proctor activities with this user pre-selected
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => viewproctoractivities(
                            title: '',
                            preSelectedUser: userName,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(18),
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
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [

                            // Avatar
                            Container(
                              width: 46, height: 46,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_primary, _primaryLight],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius:
                                BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  userName.isNotEmpty
                                      ? userName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            // Name + activity count
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(userName,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: _text)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        width: 16, height: 16,
                                        decoration: BoxDecoration(
                                          color: _primary
                                              .withOpacity(0.08),
                                          borderRadius:
                                          BorderRadius.circular(
                                              4),
                                        ),
                                        child: Icon(
                                            Icons
                                                .visibility_outlined,
                                            color: _primary,
                                            size: 10),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '$count activit${count == 1 ? 'y' : 'ies'}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: _sub,
                                            fontWeight:
                                            FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Arrow
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: _primary.withOpacity(0.06),
                                borderRadius:
                                BorderRadius.circular(9),
                                border: Border.all(
                                    color:
                                    _primary.withOpacity(0.12)),
                              ),
                              child: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: _primary,
                                  size: 13),
                            ),
                          ],
                        ),
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