import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

const _primary      = Color(0xFF194569);
const _primaryLight = Color(0xFF2A6096);
const _bg           = Color(0xFFF0F4F8);
const _text         = Color(0xFF0D1F2D);
const _sub          = Color(0xFF607D8B);
const _divider      = Color(0xFFE8EEF4);

class ViewNotification extends StatefulWidget {
  const ViewNotification({super.key});

  @override
  State<ViewNotification> createState() => _ViewNotificationState();
}

class _ViewNotificationState extends State<ViewNotification> {
  List<Map<String, dynamic>> notifications = [];
  int  _lastNid   = 0;
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    // Auto-poll every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchNotifications();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url') ?? '';
      String lid = sh.getString('lid') ?? '';

      var response = await http.post(
        Uri.parse('$url/view_notification/'),
        body: {
          'lid': lid,
          'nid': _lastNid.toString(),
        },
      );

      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'ok') {
        List newNotifs = jsonData['notifications'];
        if (newNotifs.isNotEmpty) {
          setState(() {
            for (var n in newNotifs) {
              notifications.insert(0, {
                'nid':     n['nid'].toString(),
                'message': n['message'],
                'time':    TimeOfDay.now().format(context),
              });
              // Update last seen nid
              if (n['nid'] > _lastNid) _lastNid = n['nid'];
            }
          });
        }
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearAll() {
    setState(() => notifications.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [

          // ── Header ────────────────────────────────────────────────────
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
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
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
                  child: Text('Live Notifications',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),

                // Notification count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${notifications.length} New',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(width: 8),

                // Clear button
                GestureDetector(
                  onTap: _clearAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Text('Clear All',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),

          // ── Live indicator ────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Auto-refreshing every 10 seconds',
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),

          // ── Notification List ─────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                child: CircularProgressIndicator(color: _primary))
                : notifications.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 64,
                      color: _sub.withOpacity(0.35)),
                  const SizedBox(height: 12),
                  const Text('No new notifications',
                      style: TextStyle(color: _sub, fontSize: 15)),
                  const SizedBox(height: 6),
                  const Text('Waiting for proctor activity...',
                      style: TextStyle(color: _sub, fontSize: 12)),
                ],
              ),
            )
                : RefreshIndicator(
              color: _primary,
              onRefresh: _fetchNotifications,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                physics: const BouncingScrollPhysics(),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _divider),
                      boxShadow: [
                        BoxShadow(
                          color: _primary.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // Icon
                          Container(
                            width: 46, height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEDED),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                                Icons.privacy_tip_rounded,
                                color: Color(0xFFEF4444),
                                size: 24),
                          ),

                          const SizedBox(width: 12),

                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notif['message'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _text,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(children: [
                                  const Icon(Icons.tag,
                                      size: 13, color: _sub),
                                  const SizedBox(width: 4),
                                  Text('Activity ID: ${notif['nid']}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: _sub,
                                          fontWeight: FontWeight.w500)),
                                ]),
                                const SizedBox(height: 4),
                                Row(children: [
                                  const Icon(Icons.access_time,
                                      size: 13, color: _sub),
                                  const SizedBox(width: 4),
                                  Text('Received at ${notif['time']}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: _sub)),
                                ]),
                              ],
                            ),
                          ),

                          // New badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEDED),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('NEW',
                                style: TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}