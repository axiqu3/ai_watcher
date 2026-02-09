// import 'dart:async';
// import 'dart:convert';
// import 'package:ai_watcher/Staff/view_alerts.dart';
// import 'package:ai_watcher/Staff/view_candidates.dart';
// import 'package:ai_watcher/Staff/viewallocatedexam.dart';
// import 'package:ai_watcher/Staff/viewprofile.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../login.dart';
// import 'changepassword.dart';
//
// void main() {
//   runApp(const MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: staff_home(),
//   ));
// }
//
// class staff_home extends StatefulWidget {
//   const staff_home({super.key});
//
//   @override
//   State<staff_home> createState() => _staff_homeState();
// }
//
// class _staff_homeState extends State<staff_home> {
//   _staff_homeState() {
//     _get_data();
//   }
//
//   String name_ = '';
//   String photo_ = '';
//   int _currentIndex = 0;
//
//
//
//
//   String _lastMessage = "";
//   Timer? _timer;
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//
//
//   @override
//   void initState() {
//     super.initState();
//
//     Timer.periodic(const Duration(seconds: 5), (timer) {
//       _fetchnotifi();
//     });
//   }
//
//
//   Future<void> _fetchnotifi() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String url = sh.getString('url') ?? '';
//     String lid = sh.getString('lid') ?? '';
//
//     if (url.isEmpty || lid.isEmpty) return;
//     String nid="0";
//     if(sh.containsKey("nid")==false) {}
//     else{
//       nid=sh.getString('nid').toString();
//     }
//
//
//     final uri = Uri.parse('$url/view_notification/');
//     try {
//       final response = await http.post(uri, body: {'lid': lid});
//
//       if (response.statusCode == 200) {
//         var jsondata = json.decode(response.body);
//
//         if (jsondata['status'] == 'ok') {
//           final response = await http.post(
//             uri,
//             body: {
//               'lid': lid,
//               'nid': sh.getString('nid') ?? '0',
//             },
//           );
//
//
//           final notifications = jsondata['notifications'] as List<dynamic>;
//           for (var n in notifications) {
//             String message = n['message'] ?? 'New notification';
//
//             if (message != _lastMessage) {
//               _lastMessage = message;
//               callbackDispatcher(message);
//               showAlertDialog(context, message);
//             }
//           }
//
//         } else {
//           Fluttertoast.showToast(msg: 'No new notifications');
//         }
//       } else {
//         Fluttertoast.showToast(msg: 'Network Error');
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: e.toString());
//     }
//   }
//
//
//   void callbackDispatcher(String message) {
//     print("hiii");
//     FlutterLocalNotificationsPlugin flip =
//     new FlutterLocalNotificationsPlugin();
//     var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
//     var settings = new InitializationSettings(android: android);
//     flip.initialize(settings);
//     _showNotificationWithDefaultSound(flip, message);
//   }
//
//
//
//   Future<void> _showNotificationWithDefaultSound(
//       FlutterLocalNotificationsPlugin flip, String message) async {
//     var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'rescue_channel_id',
//       'Rescue Notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//
//     var platformChannelSpecifics =
//     NotificationDetails(android: androidPlatformChannelSpecifics);
//
//     await flip.show(
//       0,
//       'Notification',
//       message,
//       platformChannelSpecifics,
//       payload: 'Default_Sound',
//     );
//   }
//
//   void showAlertDialog(BuildContext context, String message) {
//     if (!mounted) return;
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) {
//         return AlertDialog(
//           title: const Text('Notification'),
//           content: Text(message),
//           actions: [
//             ElevatedButton(
//               onPressed: () => Navigator.pop(ctx),
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
//   void _get_data() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String url = sh.getString('url').toString();
//     String lid = sh.getString('lid').toString();
//     String img = sh.getString('img_url').toString();
//
//     final urls = Uri.parse('$url/examinerviewprofile/');
//     try {
//       final response = await http.post(urls, body: {
//         'lid': lid
//       });
//       if (response.statusCode == 200) {
//         String status = jsonDecode(response.body)['status'];
//         if (status == 'ok') {
//           String name = jsonDecode(response.body)['name'].toString();
//           String photo = img + jsonDecode(response.body)['photo'].toString();
//
//           setState(() {
//             name_ = name;
//             photo_ = photo;
//           });
//         } else {
//           Fluttertoast.showToast(msg: 'Not Found');
//         }
//       } else {
//         Fluttertoast.showToast(msg: 'Network Error');
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: e.toString());
//     }
//   }

import 'dart:async';
import 'dart:convert';
import 'package:ai_watcher/Staff/view_alerts.dart';
import 'package:ai_watcher/Staff/view_candidates.dart';
import 'package:ai_watcher/Staff/viewallocatedexam.dart';
import 'package:ai_watcher/Staff/viewprofile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../login.dart';
import 'changepassword.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: staff_home(),
  ));
}

class staff_home extends StatefulWidget {
  const staff_home({super.key});

  @override
  State<staff_home> createState() => _staff_homeState();
}

class _staff_homeState extends State<staff_home> {
  String name_ = '';
  String photo_ = '';
  int _currentIndex = 0;

  String _lastMessage = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _get_data();

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchnotifi();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchnotifi() async {
    if (!mounted) return;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url') ?? '';
    String lid = sh.getString('lid') ?? '';
    String nid = sh.getString('nid') ?? '0';

    if (url.isEmpty || lid.isEmpty) return;

    final uri = Uri.parse('$url/view_notification/');

    try {
      final response = await http.post(
        uri,
        body: {'lid': lid, 'nid': nid},
      );

      if (response.statusCode != 200) return;

      var jsondata = json.decode(response.body);

      if (jsondata['status'] != 'ok') return;

      final notifications = jsondata['notifications'] as List<dynamic>;

      if (notifications.isEmpty) return;

      final latest = notifications.last;
      String message = latest['message'] ?? 'New notification';
      String newNid = latest['nid'].toString();

      if (message != _lastMessage) {
        _lastMessage = message;
        await sh.setString('nid', newNid);

        callbackDispatcher(message);
        showAlertDialog(context, message);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void callbackDispatcher(String message) {
    FlutterLocalNotificationsPlugin flip =
    FlutterLocalNotificationsPlugin();

    var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var settings = InitializationSettings(android: android);
    flip.initialize(settings);

    _showNotificationWithDefaultSound(flip, message);
  }

  Future<void> _showNotificationWithDefaultSound(
      FlutterLocalNotificationsPlugin flip, String message) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'rescue_channel_id',
      'Rescue Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flip.show(
      0,
      'Notification',
      message,
      platformChannelSpecifics,
    );
  }

  void showAlertDialog(BuildContext context, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Notification'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _get_data() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url') ?? '';
    String lid = sh.getString('lid') ?? '';
    String img = sh.getString('img_url') ?? '';

    if (url.isEmpty || lid.isEmpty) return;

    final urls = Uri.parse('$url/examinerviewprofile/');

    try {
      final response = await http.post(urls, body: {'lid': lid});

      if (response.statusCode != 200) return;

      var jsondata = jsonDecode(response.body);

      if (jsondata['status'] == 'ok') {
        setState(() {
          name_ = jsondata['name'].toString();
          photo_ = img + jsondata['photo'].toString();
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF), // Light blue background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi ${name_.isNotEmpty ? name_.split(' ').first : 'Examiner'}!',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B), // Dark blue
                              ),
                            ),
                            const Text(
                              'Good Morning',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B), // Medium blue-gray
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: photo_.isNotEmpty
                                ? Image.network(photo_, fit: BoxFit.cover)
                                : Container(
                              color: const Color(0xFF3B82F6), // Blue
                              child: const Icon(Icons.person, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search',
                                hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                              ),
                              style: TextStyle(color: Color(0xFF1E293B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Welcome Section - UPDATED to Dark Blue Theme
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E293B), Color(0xFF334155)], // Dark blue gradient
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome to AI Watcher!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage exam sessions & monitor candidates',
                              style: const TextStyle(
                                color: Color(0xFFE2E8F0), // Light gray-blue
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'View Dashboard',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.security_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Actions Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'view all',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Quick Actions Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1,
                  children: [
                    _DashboardActionCard(
                      title: 'Profile',
                      icon: Icons.person_outline,
                      color: const Color(0xFF3B82F6), // Blue
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => viewprofile(title: '')),
                        );
                      },
                    ),
                    _DashboardActionCard(
                      title: 'Exams',
                      icon: Icons.assignment_outlined,
                      color: const Color(0xFF3B82F6), // Blue
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => viewallocatedexam(title: '')),
                        );
                      },
                    ),
                    _DashboardActionCard(
                      title: 'Candidates',
                      icon: Icons.people_outline,
                      color: const Color(0xFF3B82F6), // Blue
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => view_candidates(title: '')),
                        );
                      },
                    ),
                    _DashboardActionCard(
                      title: 'Alerts',
                      icon: Icons.notifications_outlined,
                      color: const Color(0xFF3B82F6), // Blue
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => view_alerts(title: "")),
                        );
                      },
                    ),
                    _DashboardActionCard(
                      title: 'Password',
                      icon: Icons.lock_outline,
                      color: const Color(0xFF3B82F6), // Blue
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => changepassword()),
                        );
                      },
                    ),
                    _DashboardActionCard(
                      title: 'Logout',
                      icon: Icons.logout,
                      color: const Color(0xFF3B82F6), // Blue
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => login(title: "")),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Active Sessions Header - UPDATED for Exam Management
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Active Exam Sessions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'view all',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Exam Sessions Grid - UPDATED for your project
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Today's Sessions
                    const Row(
                      children: [
                        Text(
                          'Today\'s Sessions',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ExamSessionCard(
                            title: 'AI Proctoring',
                            progress: 75,
                            status: 'Live',
                            color: const Color(0xFF3B82F6), // Blue
                            icon: Icons.monitor_heart_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ExamSessionCard(
                            title: 'Candidate Verification',
                            progress: 60,
                            status: 'In Progress',
                            color: const Color(0xFF10B981), // Green
                            icon: Icons.verified_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Upcoming Sessions
                    const Row(
                      children: [
                        Text(
                          'Upcoming Sessions',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ExamSessionCard(
                            title: 'Alert Review',
                            progress: 40,
                            status: 'Pending',
                            color: const Color(0xFFF59E0B), // Orange
                            icon: Icons.warning_amber_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ExamSessionCard(
                            title: 'Exam Analysis',
                            progress: 90,
                            status: 'Reports',
                            color: const Color(0xFF8B5CF6), // Purple
                            icon: Icons.analytics_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar - White and Blue Theme
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF3B82F6), // Blue
          unselectedItemColor: const Color(0xFF94A3B8), // Gray-blue
          selectedLabelStyle: const TextStyle(fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          elevation: 0,
          items: [
            // Home
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  _currentIndex == 0 ? Icons.home_filled : Icons.home_outlined,
                  size: 24,
                ),
              ),
              label: 'Home',
            ),
            // Message
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  _currentIndex == 1 ? Icons.message : Icons.message_outlined,
                  size: 24,
                ),
              ),
              label: 'Message',
            ),
            // Profile
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  _currentIndex == 2 ? Icons.person : Icons.person_outlined,
                  size: 24,
                ),
              ),
              label: 'Profile',
            ),
            // Settings
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  _currentIndex == 3 ? Icons.settings : Icons.settings_outlined,
                  size: 24,
                ),
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Dashboard Action Card
class _DashboardActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Exam Session Card Widget - UPDATED for your project
class _ExamSessionCard extends StatelessWidget {
  final String title;
  final int progress;
  final String status;
  final Color color;
  final IconData icon;

  const _ExamSessionCard({
    required this.title,
    required this.progress,
    required this.status,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Monitoring: $progress%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}
