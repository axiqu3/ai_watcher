import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'candidate_home.dart';
import 'edit_profile.dart';

class UserVIewProfilepages extends StatefulWidget {
  const UserVIewProfilepages({super.key});

  @override
  State<UserVIewProfilepages> createState() => _UserVIewProfilepagesState();
}

class _UserVIewProfilepagesState extends State<UserVIewProfilepages> {
  bool _isLoading = true;

  String name = "";
  String dob = "";
  String gender = "";
  String email = "";
  String phone = "";
  String place = "";
  String state = "";
  String pin = "";
  String city = "";
  String photo = "";

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
        String status = data['status'] ?? '';

        if (status == 'ok') {
          setState(() {
            name = data['name']?.toString() ?? 'Not available';
            dob = data['dob']?.toString() ?? 'Not available';
            gender = data['gender']?.toString() ?? 'Not available';
            email = data['email']?.toString() ?? 'Not available';
            phone = data['phoneno']?.toString() ?? 'Not available';
            place = data['place']?.toString() ?? 'Not available';
            state = data['state']?.toString() ?? 'Not available';
            pin = data['pin']?.toString() ?? 'Not available';
            city = data['city']?.toString() ?? 'Not available';
            photo = imgBaseUrl + (data['photo']?.toString() ?? '');
          });
        } else {
          Fluttertoast.showToast(msg: "Profile not found");
        }
      } else {
        Fluttertoast.showToast(msg: "Network Error: ${response.statusCode}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CandidateHome()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: _isLoading
              ? const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF3B82F6),
            ),
          )
              : SingleChildScrollView(
            child: Column(
              children: [
                // Header Section with Navy Blue Background
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1E3A8A),
                        Color(0xFF3B82F6),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Back Button Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CandidateHome(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  'My Profile',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Profile Picture
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: photo.isNotEmpty
                              ? NetworkImage(photo)
                              : null,
                          child: photo.isEmpty
                              ? const Icon(
                            Icons.person,
                            size: 70,
                            color: Color(0xFF3B82F6),
                          )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name
                      Text(
                        name.isEmpty ? "Candidate" : name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Exam Candidate",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),

                // Profile Details Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Info Cards
                      _buildInfoCard(
                        icon: Icons.email_outlined,
                        label: "Email",
                        value: email,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.phone_outlined,
                        label: "Phone",
                        value: phone,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.cake_outlined,
                        label: "Date of Birth",
                        value: dob,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.person_outline,
                        label: "Gender",
                        value: gender,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        icon: Icons.location_on_outlined,
                        label: "Address",
                        value: "$place, $city, $state - $pin",
                        isMultiline: true,
                      ),

                      const SizedBox(height: 30),

                      // Edit Profile Button
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserEditProfilepages(
                                  title: '',
                                ),
                              ),
                            ).then((_) {
                              _fetchProfileData();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF3B82F6),
                                  Color(0xFF2563EB),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.edit_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Edit Profile",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3B82F6),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? "Not available" : value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                  maxLines: isMultiline ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// import 'candidate_home.dart';
// import 'edit_profile.dart'; // Assuming this is your edit profile page
//
// class UserVIewProfilepages extends StatefulWidget {
//   const UserVIewProfilepages({super.key});
//
//   @override
//   State<UserVIewProfilepages> createState() => _UserVIewProfilepagesState();
// }
//
// class _UserVIewProfilepagesState extends State<UserVIewProfilepages> {
//   bool _isLoading = true;
//
//   String name = "";
//   String dob = "";
//   String gender = "";
//   String email = "";
//   String phone = "";
//   String place = "";
//   String state = "";
//   String pin = "";
//   String city = "";
//   String photo = "";
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchProfileData();
//   }
//
//   Future<void> _fetchProfileData() async {
//     setState(() => _isLoading = true);
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String? url = sh.getString('url');
//     String? lid = sh.getString('lid');
//     String? imgBaseUrl = sh.getString('img_url') ?? '';
//
//     if (url == null || lid == null) {
//       Fluttertoast.showToast(msg: "Server URL or login ID not found.");
//       setState(() => _isLoading = false);
//       return;
//     }
//
//     final uri = Uri.parse('$url/candidateviewprofile/');
//
//     try {
//       final response = await http.post(uri, body: {'lid': lid});
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         String status = data['status'] ?? '';
//
//         if (status == 'ok') {
//           setState(() {
//             name = data['name']?.toString() ?? 'Not available';
//             dob = data['dob']?.toString() ?? 'Not available';
//             gender = data['gender']?.toString() ?? 'Not available';
//             email = data['email']?.toString() ?? 'Not available';
//             phone = data['phoneno']?.toString() ?? 'Not available';
//             place = data['place']?.toString() ?? 'Not available';
//             state = data['state']?.toString() ?? 'Not available';
//             pin = data['pin']?.toString() ?? 'Not available';
//             city = data['city']?.toString() ?? 'Not available';
//             photo = imgBaseUrl + (data['photo']?.toString() ?? '');
//           });
//         } else {
//           Fluttertoast.showToast(msg: "Profile not found");
//         }
//       } else {
//         Fluttertoast.showToast(msg: "Network Error: ${response.statusCode}");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error: $e");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope( onWillPop: ()async{
//       Navigator.push(context, MaterialPageRoute(builder: (context)=>CandidateHome()));
//       return false;
//     },
//       child: Scaffold(
//         body: Stack(
//           children: [
//             // Premium Gradient Background
//             Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Color(0xFF0047AB),
//                     Color(0xFF0066FF),
//                   ],
//                 ),
//               ),
//             ),
//
//             // Subtle Wave Decoration
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: ClipPath(
//                 clipper: WaveClipper(),
//                 child: Container(
//                   height: 220,
//                   color: Colors.white.withOpacity(0.15),
//                 ),
//               ),
//             ),
//
//             // Main Content
//             SafeArea(
//               child: _isLoading
//                   ? const Center(child: CircularProgressIndicator(color: Colors.white))
//                   : SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 40),
//
//                     // Profile Header
//                     Center(
//                       child: Column(
//                         children: [
//                           // Profile Picture with Shadow
//                           Container(
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.3),
//                                   blurRadius: 20,
//                                   offset: const Offset(0, 10),
//                                 ),
//                               ],
//                             ),
//                             child: CircleAvatar(
//                               radius: 70,
//                               backgroundColor: Colors.white,
//                               backgroundImage: photo.isNotEmpty
//                                   ? NetworkImage(photo)
//                                   : null,
//                               child: photo.isEmpty
//                                   ? const Icon(
//                                 Icons.person,
//                                 size: 80,
//                                 color: Color(0xFF0066FF),
//                               )
//                                   : null,
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             name.isEmpty ? "Candidate" : name,
//                             style: const TextStyle(
//                               fontSize: 32,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                               letterSpacing: 1.2,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             "Exam Candidate",
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.white70,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 50),
//
//                     // Profile Card
//                     Container(
//                       padding: const EdgeInsets.all(32),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(28),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.2),
//                             blurRadius: 25,
//                             offset: const Offset(0, 15),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildProfileInfoRow(
//                             icon: Icons.email_outlined,
//                             label: "Email",
//                             value: email,
//                           ),
//                           const Divider(height: 32),
//                           _buildProfileInfoRow(
//                             icon: Icons.phone_outlined,
//                             label: "Phone",
//                             value: phone,
//                           ),
//                           const Divider(height: 32),
//                           _buildProfileInfoRow(
//                             icon: Icons.cake_outlined,
//                             label: "Date of Birth",
//                             value: dob,
//                           ),
//                           const Divider(height: 32),
//                           _buildProfileInfoRow(
//                             icon: Icons.person_outline,
//                             label: "Gender",
//                             value: gender,
//                           ),
//                           const Divider(height: 32),
//                           _buildProfileInfoRow(
//                             icon: Icons.location_on_outlined,
//                             label: "Address",
//                             value: "$place, $city, $state - $pin",
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 40),
//
//                     // Edit Profile Button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const UserEditProfilepages(title: '',),
//                             ),
//                           ).then((_) {
//                             // Refresh profile after editing
//                             _fetchProfileData();
//                           });
//                         },
//                         icon: const Icon(Icons.edit, size: 20),
//                         label: const Text(
//                           "Edit Profile",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFFF8C00),
//                           foregroundColor: Colors.white,
//                           elevation: 8,
//                           shadowColor: Colors.orangeAccent,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 40),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProfileInfoRow({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, color: const Color(0xFF0066FF), size: 28),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 value.isEmpty ? "Not available" : value,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF0047AB),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // Reusable Wave Clipper (same as login/change password)
// class WaveClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     var path = Path();
//     path.lineTo(0, size.height - 60);
//     var firstControlPoint = Offset(size.width / 4, size.height);
//     var firstEndPoint = Offset(size.width / 2, size.height - 40);
//     path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
//         firstEndPoint.dx, firstEndPoint.dy);
//
//     var secondControlPoint = Offset(3 * size.width / 4, size.height - 80);
//     var secondEndPoint = Offset(size.width, size.height - 60);
//     path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
//         secondEndPoint.dx, secondEndPoint.dy);
//
//     path.lineTo(size.width, 0);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
//









//
// import 'package:ai_watcher/candidate/edit_profile.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() {
//   runApp(const MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: UserVIewProfilepagespages(title: 'Profile'),
//   ));
// }
//
// class UserVIewProfilepagespages extends StatefulWidget {
//   final String title;
//
//   const UserVIewProfilepagespages({super.key, required this.title});
//
//   @override
//   State<UserVIewProfilepagespages> createState() => _UserVIewProfilepagespagesState();
// }
//
// class _UserVIewProfilepagespagesState extends State<UserVIewProfilepagespages> {
//   String name_ = '';
//   String dob_ = '';
//   String gender_ = '';
//   String email_ = '';
//   String phone_ = '';
//   String place_ = '';
//   String state_ = '';
//   String pin_ = '';
//   String city_ = '';
//   String photo_ = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _send_data();
//   }
//
//   Future<void> _send_data() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String url = sh.getString('url') ?? '';
//     String lid = sh.getString('lid') ?? '';
//     String imgBase = sh.getString('img_url') ?? '';
//
//     if (url.isEmpty || lid.isEmpty) {
//       Fluttertoast.showToast(msg: 'Configuration error');
//       return;
//     }
//
//     final uri = Uri.parse('$url/candidateviewprofile/');
//     try {
//       final response = await http.post(uri, body: {'lid': lid});
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == 'ok') {
//           setState(() {
//             name_ = data['name']?.toString() ?? 'N/A';
//             dob_ = data['dob']?.toString() ?? 'N/A';
//             gender_ = data['gender']?.toString() ?? 'N/A';
//             email_ = data['email']?.toString() ?? 'N/A';
//             phone_ = data['phoneno']?.toString() ?? 'N/A';
//             place_ = data['place']?.toString() ?? 'N/A';
//             state_ = data['state']?.toString() ?? 'N/A';
//             pin_ = data['pin']?.toString() ?? 'N/A';
//             city_ = data['city']?.toString() ?? 'N/A';
//             photo_ = imgBase + (data['photo']?.toString() ?? '');
//           });
//         } else {
//           Fluttertoast.showToast(msg: 'Profile not found');
//         }
//       } else {
//         Fluttertoast.showToast(msg: 'Network error');
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: 'Error: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'My Profile',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF1E1E2F),
//               Color(0xFF2A2A4A),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             child: Column(
//               children: [
//                 // Profile Header
//                 _buildProfileHeader(),
//
//                 const SizedBox(height: 24),
//
//                 // Info Cards
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Column(
//                     children: [
//                       _buildInfoCard(
//                         icon: Icons.person_outline_rounded,
//                         label: 'Full Name',
//                         value: name_,
//                       ),
//                       _buildInfoCard(
//                         icon: Icons.cake_outlined,
//                         label: 'Date of Birth',
//                         value: dob_,
//                       ),
//                       _buildInfoCard(
//                         icon: Icons.transgender_outlined,
//                         label: 'Gender',
//                         value: gender_,
//                       ),
//                       _buildInfoCard(
//                         icon: Icons.email_outlined,
//                         label: 'Email',
//                         value: email_,
//                       ),
//                       _buildInfoCard(
//                         icon: Icons.phone_android_outlined,
//                         label: 'Phone',
//                         value: phone_,
//                       ),
//                       _buildInfoCard(
//                         icon: Icons.location_on_outlined,
//                         label: 'Address',
//                         value: '$place_, $city_, $state_ $pin_',
//                         multiLine: true,
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 80), // Space for FAB
//               ],
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => UserVIewProfilepages(title: "Edit Profile"),
//             ),
//           ).then((_) {
//             // Refresh profile after editing
//             _send_data();
//           });
//         },
//         icon: const Icon(Icons.edit),
//         label: const Text('Edit Profile'),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         foregroundColor: Colors.white,
//         elevation: 8,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       ),
//     );
//   }
//
//   Widget _buildProfileHeader() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
//       child: Column(
//         children: [
//           Hero(
//             tag: 'profile_avatar',
//             child: CircleAvatar(
//               radius: 70,
//               backgroundColor: Colors.white.withOpacity(0.15),
//               child: CircleAvatar(
//                 radius: 66,
//                 backgroundColor: Colors.white.withOpacity(0.2),
//                 backgroundImage: photo_.isNotEmpty ? NetworkImage(photo_) : null,
//                 child: photo_.isEmpty
//                     ? const Icon(Icons.person, size: 60, color: Colors.white70)
//                     : null,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             name_.isNotEmpty ? name_ : 'Loading...',
//             style: const TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               letterSpacing: 0.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoCard({
//     required IconData icon,
//     required String label,
//     required String value,
//     bool multiLine = false,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.1)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.15),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: ListTile(
//         leading: Icon(
//           icon,
//           color: Theme.of(context).colorScheme.primary,
//           size: 28,
//         ),
//         title: Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white70,
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         subtitle: Text(
//           value.isEmpty ? 'N/A' : value,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//           maxLines: multiLine ? 2 : 1,
//           overflow: TextOverflow.ellipsis,
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//       ),
//     );
//   }
// }
//





// import 'package:ai_watcher/candidate/edit_profile.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:fluttertoast/fluttertoast.dart';
//
// import 'package:shared_preferences/shared_preferences.dart';
//
//
// void main() {
//   runApp(const UserVIewProfilepages());
// }
//
// class UserVIewProfilepages extends StatelessWidget {
//   const UserVIewProfilepages({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'View Profile',
//       theme: ThemeData(
//
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const UserVIewProfilepagespages(title: 'View Profile'),
//     );
//   }
// }
//
// class UserVIewProfilepagespages extends StatefulWidget {
//   const UserVIewProfilepagespages({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<UserVIewProfilepagespages> createState() => _UserVIewProfilepagespagesState();
// }
//
// class _UserVIewProfilepagespagesState extends State<UserVIewProfilepagespages> {
//
//   _UserVIewProfilepagespagesState()
//   {
//     _send_data();
//   }
//   @override
//   Widget build(BuildContext context) {
//
//
//
//     return WillPopScope(
//       onWillPop: () async{ return true; },
//       child: Scaffold(
//         appBar: AppBar(
//           leading: BackButton( ),
//           backgroundColor: Theme.of(context).colorScheme.primary,
//           title: Text(widget.title),
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//
//
//               CircleAvatar(backgroundImage: NetworkImage(photo_),radius: 50,),
//               Column(
//                 children: [
//                   // Image(image: NetworkImage(photo_),height: 200,width: 200,),
//                   Padding(
//                     padding: EdgeInsets.all(5),
//                   child: Text(name_),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(5),
//                     child: Text(dob_),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(5),
//                     child: Text(gender_),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(5),
//                     child: Text(email_),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(5),
//                     child: Text(phone_),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(5),
//                     child: Text(place_),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(5),
//                     child: Text(state_),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(5),
//                     child: Text(pin_),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(5),
//                     child: Text(city_),
//                   ),
//
//                 ],
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(context, MaterialPageRoute(
//                     builder: (context) => UserVIewProfilepages(title: "Edit Profile"),));
//                 },
//                 child: Text("Edit Profile"),
//               ),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//
//   String name_="";
//   String dob_="";
//   String gender_="";
//   String email_="";
//   String phone_="";
//   String place_="";
//   String state_="";
//   String pin_="";
//   String city_="";
//   String photo_="";
//
//   void _send_data() async{
//
//
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String url = sh.getString('url').toString();
//     String lid = sh.getString('lid').toString();
//     String img = sh.getString('img_url') ?? '';
//
//
//     final urls = Uri.parse('$url/candidateviewprofile/');
//     try {
//       final response = await http.post(urls, body: {
//       'lid':lid
//
//
//
//       });
//       if (response.statusCode == 200) {
//         String status = jsonDecode(response.body)['status'];
//         if (status=='ok') {
//           String name=jsonDecode(response.body)['name'].toString();
//           String dob=jsonDecode(response.body)['dob'].toString();
//           String gender=jsonDecode(response.body)['gender'].toString();
//           String email=jsonDecode(response.body)['email'].toString();
//           String phone=jsonDecode(response.body)['phoneno'].toString();
//           String place=jsonDecode(response.body)['place'].toString();
//           String state=jsonDecode(response.body)['state'].toString();
//           String pin=jsonDecode(response.body)['pin'].toString();
//           String city=jsonDecode(response.body)['city'].toString();
//           String photo=img +jsonDecode(response.body)['photo'].toString();
//
//           setState(() {
//
//             name_= name;
//             dob_= dob;
//             gender_= gender;
//             email_= email;
//             phone_= phone;
//             place_= place;
//             state_= state;
//             pin_= pin;
//             city_= city;
//             photo_= photo;
//           });
//
//
//
//
//
//         }else {
//           Fluttertoast.showToast(msg: 'Not Found');
//         }
//       }
//       else {
//         Fluttertoast.showToast(msg: 'Network Error');
//       }
//     }
//     catch (e){
//       Fluttertoast.showToast(msg: e.toString());
//     }
//   }
// }
