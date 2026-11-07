import 'dart:convert';

import 'package:ai_watcher/Staff/add_question.dart';
import 'package:ai_watcher/Staff/edit_question.dart';
import 'package:ai_watcher/Staff/staff_home.dart';
import 'package:ai_watcher/Staff/viewallocatedexam.dart';
import 'package:ai_watcher/chat.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../Staff/svideochat.dart';

void main() {
  runApp(const ViewHouseApp());
}

class ViewHouseApp extends StatelessWidget {
  const ViewHouseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ViewExamRequest(title: 'View Users'),
    );
  }
}

// ─── Theme ────────────────────────────────────────────────────────────────────
const _primary      = Color(0xFF194569);
const _primaryMid   = Color(0xFF1E5A8A);
const _primaryLight = Color(0xFF2A6096);
const _sky          = Color(0xFF4A9ECA);
const _pearl        = Color(0xFFE8F4FC);
const _bg           = Color(0xFFF0F5FA);
const _card         = Colors.white;
const _text         = Color(0xFF0D1F2D);
const _sub          = Color(0xFF5A7A8F);
const _divider      = Color(0xFFDCE8F0);
// ─────────────────────────────────────────────────────────────────────────────

class ViewExamRequest extends StatefulWidget {
  const ViewExamRequest({super.key, required this.title});
  final String title;

  @override
  State<ViewExamRequest> createState() => _ViewExamRequestState();
}

class _ViewExamRequestState extends State<ViewExamRequest> {
  List<Map<String, dynamic>> users         = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<String>               nameSuggestions = [];

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
      String img  = sh.getString('img_url') ?? '';
      String eid  = sh.getString('eid') ?? '';
      String apiUrl = '$urls/viewrequestexam/';

      var response = await http.post(Uri.parse(apiUrl), body: {'eid': eid});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List<Map<String, dynamic>> tempList = [];
        for (var item in jsonData['data']) {
          tempList.add({
            'id'       : item['id'].toString(),
            'date'     : item['date'].toString(),
            'status'   : item['status'].toString(),
            'name'     : item['name'].toString(),
            'email'    : item['email'].toString(),
            'gender'   : item['gender'].toString(),
            'phoneno'  : item['phoneno'].toString(),
            'place'    : item['place'].toString(),
            'state'    : item['state'].toString(),
            'city'     : item['city'].toString(),
            'dob'      : item['dob'].toString(),
            'pin'      : item['pin'].toString(),
            'photo'    : img + item['photo'].toString(),
            'examname' : item['examname'].toString(),
            'startdate': item['startdate'].toString(),
            'starttime': item['starttime'].toString(),
            'enddate'  : item['enddate'].toString(),
            'endtime'  : item['endtime'].toString(),
            'ulid'     : item['ulid'].toString(),
          });
        }
        setState(() {
          users = tempList;
          filteredUsers = tempList
              .where((user) => user['date']
              .toString()
              .toLowerCase()
              .contains(searchValue.toLowerCase()))
              .toList();
          nameSuggestions =
              users.map((e) => e['date'].toString()).toSet().toList();
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  // ── Status helpers ──────────────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return const Color(0xFF1A7A6E);
      case 'pending':  return const Color(0xFFB85C00);
      case 'rejected': return const Color(0xFFC0392B);
      default:         return _sub;
    }
  }

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return const Color(0xFFE6F7F5);
      case 'pending':  return const Color(0xFFFFF3E0);
      case 'rejected': return const Color(0xFFFFEBEE);
      default:         return const Color(0xFFF0F5FA);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Icons.check_circle_outline_rounded;
      case 'pending':  return Icons.hourglass_top_rounded;
      case 'rejected': return Icons.cancel_outlined;
      default:         return Icons.info_outline;
    }
  }

  // ── Section label ───────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3, height: 14,
          decoration: BoxDecoration(
            color: _sky,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: _primary,
            letterSpacing: 0.9,
          ),
        ),
      ],
    );
  }

  // ── Info row widget ─────────────────────────────────────────────────────────
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              color: _sub,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(icon, size: 12, color: _sky),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _text,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Action button ───────────────────────────────────────────────────────────
  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool outline = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(11),
          border: outline ? Border.all(color: color, width: 1.5) : null,
          boxShadow: outline
              ? null
              : [
            BoxShadow(
              color: color.withOpacity(0.28),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: outline ? color : Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: outline ? color : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StaffHome()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primary, _primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  // Glow
                  Positioned(
                    top: -30, right: -30,
                    child: Container(
                      width: 160, height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [_sky.withOpacity(0.18), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back + title
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const viewallocatedexam(title: '',)),
                            ),
                            child: Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.2)),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Exam Requests',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                Text(
                                  'Review and manage exam applications',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Count badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Text(
                              '${filteredUsers.length} total',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Search bar
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded,
                                color: Colors.white60, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Search by date…',
                                  hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 13),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (v) => viewUsers(v),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  viewUsers('');
                                },
                                child: const Icon(Icons.close,
                                    color: Colors.white54, size: 16),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── List ────────────────────────────────────────────────────────
            Expanded(
              child: filteredUsers.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 68, height: 68,
                      decoration: BoxDecoration(
                        color: _pearl,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.inbox_outlined,
                        color: _primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'No requests found',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Exam requests will appear here',
                      style: TextStyle(fontSize: 12, color: _sub),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user   = filteredUsers[index];
                  final status = user['status'].toString();
                  return _buildRequestCard(user, status);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Request Card ─────────────────────────────────────────────────────────────
  Widget _buildRequestCard(Map<String, dynamic> user, String status) {
    // Initials fallback
    final nameParts = (user['name'] as String).trim().split(' ');
    final initials  = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : (user['name'] as String).substring(0, 2).toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Card header ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.03),
              borderRadius: const BorderRadius.only(
                topLeft:  Radius.circular(22),
                topRight: Radius.circular(22),
              ),
              border: const Border(
                bottom: BorderSide(color: _divider, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Avatar with initials fallback
                Container(
                  width: 54, height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _primary.withOpacity(0.18), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: _primaryMid,
                    backgroundImage: NetworkImage(user['photo']),
                    onBackgroundImageError: (_, __) {},
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & exam
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _text,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.description_outlined,
                              size: 11, color: _sub),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              user['examname'],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11, color: _sub),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusBg(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _statusColor(status),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _statusColor(status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Details grid ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _infoRow(Icons.email_outlined,  'Email',  user['email'])),
                    Expanded(child: _infoRow(Icons.phone_outlined,  'Phone',  user['phoneno'])),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _infoRow(Icons.wc_outlined,    'Gender', user['gender'])),
                    Expanded(child: _infoRow(Icons.cake_outlined,  'DOB',    user['dob'])),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _infoRow(Icons.location_on_outlined,   'Place', user['place'])),
                    Expanded(child: _infoRow(Icons.location_city_outlined, 'City',  user['city'])),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _infoRow(Icons.map_outlined,       'State', user['state'])),
                    Expanded(child: _infoRow(Icons.pin_drop_outlined,  'PIN',   user['pin'])),
                  ],
                ),
              ],
            ),
          ),

          // ── Exam timing ─────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: _primary.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.event_note_outlined,
                      color: _primary, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['examname'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '▶ ${user['startdate']}  ${user['starttime']}   ◼ ${user['enddate']}  ${user['endtime']}',
                        style: const TextStyle(fontSize: 10, color: _sub),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'APPLIED',
                      style: TextStyle(
                          fontSize: 9,
                          color: _sub,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4),
                    ),
                    Text(
                      user['date'],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _text,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Action buttons ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [

                // Approve
                if (status == 'pending')
                  _actionBtn(
                    label: 'Approve',
                    icon: Icons.check_circle_outline_rounded,
                    color: const Color(0xFF1A7A6E),
                    onTap: () async {
                      SharedPreferences sh =
                      await SharedPreferences.getInstance();
                      String? url = sh.getString('url');
                      if (url == null) {
                        Fluttertoast.showToast(msg: "Server URL not found.");
                        return;
                      }
                      final uri = Uri.parse('$url/approve_examrequest/');
                      var request = http.MultipartRequest('POST', uri);
                      request.fields['erid'] = user['id'].toString();
                      try {
                        var response = await request.send();
                        var respStr = await response.stream.bytesToString();
                        var data = jsonDecode(respStr);
                        if (response.statusCode == 200 &&
                            data['status'] == 'ok') {
                          Fluttertoast.showToast(
                              msg: "Approved successfully.");
                          viewUsers("");
                        } else {
                          Fluttertoast.showToast(msg: "Submission failed.");
                        }
                      } catch (e) {
                        Fluttertoast.showToast(msg: "Error: $e");
                      }
                    },
                  ),

                // Reject
                if (status == 'pending')
                  _actionBtn(
                    label: 'Reject',
                    icon: Icons.cancel_outlined,
                    color: const Color(0xFFC0392B),
                    onTap: () async {
                      SharedPreferences sh =
                      await SharedPreferences.getInstance();
                      String? url = sh.getString('url');
                      if (url == null) {
                        Fluttertoast.showToast(msg: "Server URL not found.");
                        return;
                      }
                      final uri = Uri.parse('$url/reject_examrequest/');
                      var request = http.MultipartRequest('POST', uri);
                      request.fields['erid'] = user['id'].toString();
                      try {
                        var response = await request.send();
                        var respStr = await response.stream.bytesToString();
                        var data = jsonDecode(respStr);
                        if (response.statusCode == 200 &&
                            data['status'] == 'ok') {
                          Fluttertoast.showToast(msg: "Rejected successfully.");
                          viewUsers("");
                        } else {
                          Fluttertoast.showToast(msg: "Submission failed.");
                        }
                      } catch (e) {
                        Fluttertoast.showToast(msg: "Error: $e");
                      }
                    },
                    outline: true,
                  ),

                // Chat
                if (status == 'Approved')
                  _actionBtn(
                    label: 'Chat',
                    icon: Icons.chat_bubble_outline_rounded,
                    color: _primary,
                    onTap: () async {
                      SharedPreferences sh =
                      await SharedPreferences.getInstance();
                      sh.setString('toid', user['ulid'].toString());
                      sh.setString('agrname', user['name'].toString());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MyChatPage(title: '')),
                      );
                    },
                  ),

                // Video Call
                if (status == 'Approved')
                  _actionBtn(
                    label: 'Video Call',
                    icon: Icons.video_call_outlined,
                    color: _primaryLight,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const sAgoraVideoCall()),
                      );
                    },
                    outline: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}