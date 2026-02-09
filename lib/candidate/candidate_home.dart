import 'dart:convert';
import 'package:ai_watcher/candidate/viewexam.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'changepassword.dart';
import 'upcomingExam.dart';
import 'viewprofile.dart';
import '../login.dart';

class CandidateHome extends StatefulWidget {
  const CandidateHome({super.key});

  @override
  State<CandidateHome> createState() => _CandidateHomeState();
}

class _CandidateHomeState extends State<CandidateHome> {
  String name = 'Candidate';
  String photo = '';
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    setState(() => _isLoading = true);

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('lid');
    String? imgBaseUrl = sh.getString('img_url') ?? '';

    if (url == null || lid == null) {
      Fluttertoast.showToast(msg: "Server URL or login ID not found.");
      setState(() => _isLoading = false);
      return;
    }

    final uri = Uri.parse('$url/candidateviewprofile/');

    try {
      final response = await http.post(uri, body: {'lid': lid});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          setState(() {
            name = data['name']?.toString() ?? 'Candidate';
            photo = imgBaseUrl + (data['photo']?.toString() ?? '');
          });
        } else {
          Fluttertoast.showToast(msg: "Profile not found");
        }
      } else {
        Fluttertoast.showToast(msg: "Network Error");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate based on selection
    switch (index) {
      case 0:
      // Already on Home
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const viewexam(title: '')),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserVIewProfilepages()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Stack(
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: 100, // Space for bottom nav
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Menu Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.apps,
                          color: Color(0xFF1E3A8A),
                          size: 24,
                        ),
                      ),
                      // Home text
                      const Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      // Notification Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            const Icon(
                              Icons.notifications_outlined,
                              color: Color(0xFF1E3A8A),
                              size: 24,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Greeting
                  Text(
                    'Hi ${name.split(' ').first}!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Good Morning',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey[400]),
                        const SizedBox(width: 12),
                        Text(
                          'Search',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Welcome Card with Illustration
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Welcome!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Let's schedule your\nprojects",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Placeholder for illustration
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E7FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.school_outlined,
                            size: 40,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ongoing Projects',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      Text(
                        'view all',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Project Cards Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      _buildProjectCard(
                        title: 'View Profile',
                        subtitle: 'Profile',
                        date: 'May 26, 2022',
                        progress: 0.8,
                        color: const Color(0xFF1E3A8A),
                        icon: Icons.person_outline,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserVIewProfilepages(),
                            ),
                          );
                        },
                      ),
                      _buildProjectCard(
                        title: 'Upcoming',
                        subtitle: 'Exams',
                        date: 'May 26, 2022',
                        progress: 0.5,
                        color: Colors.white,
                        icon: Icons.event_available,
                        isLight: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UpcomingExam(),
                            ),
                          );
                        },
                      ),
                      _buildProjectCard(
                        title: 'Exams',
                        subtitle: 'Marketing',
                        date: 'May 26, 2022',
                        progress: 0.6,
                        color: Colors.white,
                        icon: Icons.description_outlined,
                        isLight: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const viewexam(title: ''),
                            ),
                          );
                        },
                      ),
                      _buildProjectCard(
                        title: 'Password',
                        subtitle: 'User Manager',
                        date: 'May 26, 2022',
                        progress: 0.5,
                        color: Colors.white,
                        icon: Icons.lock_outline,
                        isLight: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserChangePassword(),
                            ),
                          );
                        },
                      ),
                      _buildProjectCard(
                        title: 'Logout',
                        subtitle: 'User Manager',
                        date: 'May 26, 2022',
                        progress: 0.5,
                        color: Colors.white,
                        icon: Icons.lock_outline,
                        isLight: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const login(title: '',),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const viewexam(title: '')),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomAppBar(
          color: Colors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  index: 0,
                ),
                _buildBottomNavItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'My task',
                  index: 1,
                ),
                const SizedBox(width: 40), // Space for FAB
                _buildBottomNavItem(
                  icon: Icons.payment_outlined,
                  label: 'Payment',
                  index: 2,
                ),
                _buildBottomNavItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[400],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[400],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard({
    required String title,
    required String subtitle,
    required String date,
    required double progress,
    required Color color,
    required IconData icon,
    bool isLight = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: isLight
              ? Border.all(color: Colors.grey[200]!)
              : null,
          boxShadow: [
            BoxShadow(
              color: isLight
                  ? Colors.black.withOpacity(0.05)
                  : color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 11,
                    color: isLight ? Colors.grey : Colors.white70,
                  ),
                ),
                Icon(
                  Icons.more_vert,
                  size: 18,
                  color: isLight ? Colors.grey : Colors.white70,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isLight
                    ? const Color(0xFFE0E7FF)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isLight ? const Color(0xFF3B82F6) : Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isLight ? const Color(0xFF1E3A8A) : Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isLight ? Colors.grey : Colors.white70,
              ),
            ),
            const Spacer(),
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 11,
                        color: isLight ? Colors.grey : Colors.white70,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isLight ? const Color(0xFF1E3A8A) : Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isLight
                        ? Colors.grey[200]
                        : Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isLight ? const Color(0xFF3B82F6) : Colors.white,
                    ),
                    minHeight: 6,
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







// // import 'dart:convert';
// //
// // import 'package:ai_watcher/candidate/upcomingExam.dart';
// // import 'package:ai_watcher/candidate/viewexam.dart';
// // import 'package:ai_watcher/candidate/viewprofile.dart';
// // import 'package:flutter/material.dart';
// // import 'package:fluttertoast/fluttertoast.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // import '../Staff/changepassword.dart';
// // import '../login.dart';
// //
// //
// // void main() {
// //   runApp(const MaterialApp(
// //     debugShowCheckedModeBanner: false,
// //     home: candidate_home(),
// //   ));
// // }
// //
// // class candidate_home extends StatefulWidget {
// //   const candidate_home({super.key});
// //
// //   @override
// //   State<candidate_home> createState() => _candidate_homeState();
// // }
// //
// // class _candidate_homeState extends State<candidate_home> {
// //
// //   _candidate_homeState(){
// //     _send_data();
// //   }
// //
// //   String name_='';
// //   String photo_='';
// //
// //
// //   void _send_data() async{
// //
// //
// //
// //     SharedPreferences sh = await SharedPreferences.getInstance();
// //     String url = sh.getString('url').toString();
// //     String lid = sh.getString('lid').toString();
// //     String img = sh.getString('img_url') ?? '';
// //
// //
// //     final urls = Uri.parse('$url/candidateviewprofile/');
// //     try {
// //       final response = await http.post(urls, body: {
// //         'lid':lid
// //
// //
// //
// //       });
// //       if (response.statusCode == 200) {
// //         String status = jsonDecode(response.body)['status'];
// //         if (status=='ok') {
// //           String name=jsonDecode(response.body)['name'].toString();
// //           String photo=img +jsonDecode(response.body)['photo'].toString();
// //
// //           setState(() {
// //
// //             name_= name;
// //             photo_= photo;
// //           });
// //
// //
// //
// //
// //
// //         }else {
// //           Fluttertoast.showToast(msg: 'Not Found');
// //         }
// //       }
// //       else {
// //         Fluttertoast.showToast(msg: 'Network Error');
// //       }
// //     }
// //     catch (e){
// //       Fluttertoast.showToast(msg: e.toString());
// //     }
// //   }
// //
// //
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       // drawer: const Drawer(
// //       //   child: DrawerContent(),
// //       // ),
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         iconTheme: const IconThemeData(color: Colors.black87),
// //         // actions: const [
// //         //   Icon(Icons.notifications_none),
// //         //   SizedBox(width: 16),
// //         // ],
// //       ),
// //       backgroundColor: const Color(0xFFF5F6FA),
// //       body: Padding(
// //         padding: const EdgeInsets.all(20.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //              Row(
// //               children: [
// //                 CircleAvatar(
// //                   backgroundImage: NetworkImage(photo_),
// //                   radius: 25,
// //                 ),
// //                 SizedBox(width: 12),
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       name_,
// //                       style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
// //                     ),
// //                     Text(
// //                       'What do you want to do today?',
// //                       style: TextStyle(color: Colors.black54,fontSize: 8),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 30),
// //             Container(
// //               padding: const EdgeInsets.all(20),
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(20),
// //               ),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: const [
// //                   Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(''),
// //                       SizedBox(height: 6),
// //                       Text(
// //                         '',
// //                         style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
// //                       ),
// //                     ],
// //                   ),
// //                   Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(''),
// //                       SizedBox(height: 6),
// //                       Text(
// //                         '',
// //                         style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
// //                       ),
// //
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             const SizedBox(height: 25),
// //             const Text(
// //               'Quick Actions',
// //               style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
// //             ),
// //             const SizedBox(height: 15),
// //             Expanded(
// //               child: GridView.count(
// //                 crossAxisCount: 2,
// //                 crossAxisSpacing: 15,
// //                 mainAxisSpacing: 15,
// //                 children: [
// //                   ActionCard(
// //                     title: 'View Profile',
// //                     color: Colors.pinkAccent,
// //                     icon: Icons.verified_user,
// //                     onTap: () {
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(builder: (context) => UserVIewProfilepages(title: '')),
// //                       );
// //                     },
// //                   ),
// //
// //
// //                   ActionCard(
// //                     title: 'Change password',
// //                     color: Colors.deepPurple,
// //                     icon: Icons.table_view_outlined,
// //                     onTap: () {
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(builder: (context) => changepassword()),
// //                       );
// //                     },
// //                   ),
// //
// //                   ActionCard(
// //                     title: ' View UpcomingExam',
// //                     color: Colors.deepPurple,
// //                     icon: Icons.table_view_outlined,
// //                     onTap: () {
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(builder: (context) => upc_exam(title: '',)),
// //                       );
// //                     },
// //                   ),
// //
// //
// //                   ActionCard(
// //                     title: ' Logout',
// //                     color: Colors.deepPurple,
// //                     icon: Icons.table_view_outlined,
// //                     onTap: () {
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(builder: (context) => login(title: '',)),
// //                       );
// //                     },
// //                   ),
// //                 ],
// //               ),
// //             ),
// //
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class ActionCard extends StatelessWidget {
// //   final String title;
// //   final Color color;
// //   final IconData icon;
// //   final VoidCallback? onTap; // ADD this
// //
// //   const ActionCard({
// //     super.key,
// //     required this.title,
// //     required this.color,
// //     required this.icon,
// //     this.onTap, // ADD this
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap, // USE this
// //       child: Container(
// //         padding: const EdgeInsets.all(16),
// //         decoration: BoxDecoration(
// //           color: color.withOpacity(0.1),
// //           borderRadius: BorderRadius.circular(20),
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             CircleAvatar(
// //               backgroundColor: color,
// //               child: Icon(icon, color: Colors.white),
// //             ),
// //             const SizedBox(height: 10),
// //             Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// //
// // class DrawerContent extends StatefulWidget {
// //   const DrawerContent({super.key});
// //
// //   @override
// //   State<DrawerContent> createState() => _DrawerContentState();
// // }
// //
// // class _DrawerContentState extends State<DrawerContent> {
// //   void showDrawerMessage(String message) {
// //     Navigator.pop(context); // Close drawer
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text(message)),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return ListView(
// //       padding: EdgeInsets.zero,
// //       children: [
// //         const DrawerHeader(
// //           decoration: BoxDecoration(color: Colors.blue),
// //           child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
// //         ),
// //         ListTile(
// //           leading: const Icon(Icons.dashboard),
// //           title: const Text('Dashboard'),
// //           onTap: () => showDrawerMessage('Dashboard selected'),
// //         ),
// //         ListTile(
// //           leading: const Icon(Icons.receipt),
// //           title: const Text('Add User'),
// //           onTap: () => showDrawerMessage('Bills selected'),
// //         ),
// //         ListTile(
// //           leading: const Icon(Icons.send),
// //           title: const Text('Transfers'),
// //           onTap: () => showDrawerMessage('Transfers selected'),
// //         ),
// //         ListTile(
// //           leading: const Icon(Icons.settings),
// //           title: const Text('Settings'),
// //           onTap: () => showDrawerMessage('Settings selected'),
// //         ),
// //       ],
// //     );
// //   }
// // }
