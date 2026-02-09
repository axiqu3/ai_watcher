import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'candidate/candidate_home.dart';
import 'candidate/signup.dart';
import 'Staff/staff_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch:Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),
      home: const login(title: 'Login'),
    );
  }
}

class login extends StatefulWidget {
  const login({super.key, required this.title});
  final String title;

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient blob
          Container(
            color: Colors.white,
          ),
          // Decorative gradient blob in top-left
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFE9D5FF).withOpacity(0.6),
                    const Color(0xFFF3E8FF).withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 280),

                  // Login Title
                  const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle with signup link
                  Row(
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const candidate_signup(title: ''),
                            ),
                          );
                        },
                        child: const Text(
                          "sign up",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF8B5CF6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // Email Field (styled as phone field in reference)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 12),
                          child: Icon(Icons.email_outlined,
                            color: Colors.grey[400],
                            size: 22,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 12),
                          child: Icon(Icons.lock_outline,
                            color: Colors.grey[400],
                            size: 22,
                          ),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: TextButton(
                            onPressed: () {
                              // Add forgot password logic
                            },
                            child: const Text(
                              "FORGOT",
                              style: TextStyle(
                                color: Color(0xFF8B5CF6),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login Button (aligned right)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF9333EA)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 150),

                  // Social Login Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(Icons.apple, Colors.black),
                      const SizedBox(width: 16),
                      _buildSocialButton(Icons.facebook, const Color(0xFF1877F2)),
                      const SizedBox(width: 16),
                      _buildSocialButton(Icons.g_mobiledata, const Color(0xFFDB4437)),
                      const SizedBox(width: 16),
                      _buildSocialButton(Icons.flutter_dash, const Color(0xFF1DA1F2)),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 28),
        onPressed: () {
          // Add social login logic
          Fluttertoast.showToast(msg: "Social login coming soon");
        },
      ),
    );
  }

  Future<void> _sendData() async {
    setState(() => _isLoading = true);

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all fields");
      setState(() => _isLoading = false);
      return;
    }

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');

    if (url == null || url.isEmpty) {
      Fluttertoast.showToast(msg: "Server URL not set");
      setState(() => _isLoading = false);
      return;
    }

    final uri = Uri.parse('$url/Applogin_post/');

    try {
      final response = await http.post(uri, body: {
        'Username': email,
        'Password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String status = data['status'].toString();

        if (status == 'ok') {
          String lid = data['lid'].toString();
          String type = data['type'].toString();

          sh.setString("lid", lid);

          Fluttertoast.showToast(msg: "Login Successful");

          if (type == 'examiner') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const staff_home()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CandidateHome()),
            );
          }
        } else {
          Fluttertoast.showToast(msg: "Invalid credentials");
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
}










// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// import 'candidate/candidate_home.dart';
// import 'candidate/signup.dart';
// import 'Staff/staff_home.dart'; // Assuming this is your staff home import
//
// // Optional: Add Google Fonts for premium typography
// // Add to pubspec.yaml: google_fonts: ^6.2.1
// // import 'package:google_fonts/google_fonts.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         scaffoldBackgroundColor: Colors.transparent,
//         textTheme: const TextTheme(
//           bodyLarge: TextStyle(color: Colors.white),
//           bodyMedium: TextStyle(color: Colors.white70),
//         ),
//       ),
//       home: const login(title: 'Login'),
//     );
//   }
// }
//
// class login extends StatefulWidget {
//   const login({super.key, required this.title});
//   final String title;
//
//   @override
//   State<login> createState() => _loginState();
// }
//
// class _loginState extends State<login> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background Gradient + Wave
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Color(0xFF0047AB),
//                   Color(0xFF0066FF),
//                 ],
//               ),
//             ),
//           ),
//           // Subtle wave at bottom
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: ClipPath(
//               clipper: WaveClipper(),
//               child: Container(
//                 height: 180,
//                 color: Colors.white.withOpacity(0.2),
//               ),
//             ),
//           ),
//           // Main Content
//           SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 32.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 60),
//
//                   // App Logo / Title
//                   Center(
//                     child: Column(
//                       children: [
//                         // Placeholder for logo (add your image in assets)
//                         // const Icon(Icons.school, size: 80, color: Colors.white),
//                         const SizedBox(height: 16),
//                         Text(
//                           "ExamPro",
//                           style: TextStyle(
//                             fontSize: 42,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                             letterSpacing: 1.2,
//                             // fontFamily: 'GoogleFonts.poppins().fontFamily', // optional
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "Secure Online Examination Platform",
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.white70,
//                             // fontFamily: 'GoogleFonts.poppins().fontFamily',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 60),
//
//                   // Login Card
//                   Container(
//                     padding: const EdgeInsets.all(32),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(24),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           blurRadius: 20,
//                           offset: const Offset(0, 10),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Welcome Back",
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF0047AB),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         const Text(
//                           "Login to start your exam",
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         const SizedBox(height: 32),
//
//                         // Email Field
//                         TextField(
//                           controller: _emailController,
//                           keyboardType: TextInputType.emailAddress,
//                           decoration: InputDecoration(
//                             labelText: "Email",
//                             prefixIcon: const Icon(Icons.email_outlined),
//                             filled: true,
//                             fillColor: Colors.grey[100],
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide.none,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(color: Color(0xFF0066FF), width: 2),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//
//                         // Password Field
//                         TextField(
//                           controller: _passwordController,
//                           obscureText: true,
//                           decoration: InputDecoration(
//                             labelText: "Password",
//                             prefixIcon: const Icon(Icons.lock_outline),
//                             filled: true,
//                             fillColor: Colors.grey[100],
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide.none,
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(color: Color(0xFF0066FF), width: 2),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//
//                         // Forgot Password
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: TextButton(
//                             onPressed: () {
//                               // Add forgot password logic
//                             },
//                             child: const Text(
//                               "Forgot Password?",
//                               style: TextStyle(
//                                 color: Color(0xFF0066FF),
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//
//                         // Login Button
//                         SizedBox(
//                           width: double.infinity,
//                           height: 56,
//                           child: ElevatedButton(
//                             onPressed: _isLoading ? null : _sendData,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.transparent,
//                               shadowColor: Colors.blueAccent,
//                               elevation: 8,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                             ),
//                             child: Ink(
//                               decoration: BoxDecoration(
//                                 gradient: const LinearGradient(
//                                   colors: [Color(0xFFFF6B00), Color(0xFFFF8C00)],
//                                 ),
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               child: Container(
//                                 alignment: Alignment.center,
//                                 child: _isLoading
//                                     ? const CircularProgressIndicator(color: Colors.white)
//                                     : const Text(
//                                   "Login",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 32),
//
//                   // Register Prompt
//                   Center(
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Text(
//                           "Don't have an account? ",
//                           style: TextStyle(color: Colors.white70),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => const candidate_signup(title: '',),
//                               ),
//                             );
//                           },
//                           child: const Text(
//                             "Register",
//                             style: TextStyle(
//                               color: Color(0xFFFF8C00),
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _sendData() async {
//     setState(() => _isLoading = true);
//
//     String email = _emailController.text.trim();
//     String password = _passwordController.text.trim();
//
//     if (email.isEmpty || password.isEmpty) {
//       Fluttertoast.showToast(msg: "Please fill all fields");
//       setState(() => _isLoading = false);
//       return;
//     }
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String? url = sh.getString('url');
//
//     if (url == null || url.isEmpty) {
//       Fluttertoast.showToast(msg: "Server URL not set");
//       setState(() => _isLoading = false);
//       return;
//     }
//
//     final uri = Uri.parse('$url/Applogin_post/');
//
//     try {
//       final response = await http.post(uri, body: {
//         'Username': email,
//         'Password': password,
//       });
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         String status = data['status'].toString();
//
//         if (status == 'ok') {
//           String lid = data['lid'].toString();
//           String type = data['type'].toString();
//
//           sh.setString("lid", lid);
//
//           Fluttertoast.showToast(msg: "Login Successful");
//
//           if (type == 'examiner') {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const staff_home()),
//             );
//           } else {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const CandidateHome()),
//             );
//           }
//         } else {
//           Fluttertoast.showToast(msg: "Invalid credentials");
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
// }
//
// // Custom Wave Clipper
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
//
//




















//
// import 'dart:convert';
// import 'package:ai_watcher/Staff/staff_home.dart';
// import 'package:ai_watcher/candidate/candidate_home.dart';
// import 'package:ai_watcher/main.dart';
// import 'package:ai_watcher/candidate/candidate_home.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// import 'candidate/signup.dart';
//
//
// void main() {
//   runApp(const MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: login(title: 'Login'),
//   ));
// }
//
// class login extends StatefulWidget {
//   const login({super.key, required this.title});
//   final String title;
//
//   @override
//   State<login> createState() => _loginState();
// }
//
// class _loginState extends State<login> {
//   final TextEditingController _usernametextController = TextEditingController();
//   final TextEditingController _passwordtextController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//         onWillPop: () async {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const MyHomePage(title: '',)),
//       );
//       return false; // Prevent default pop
//     },
//     child:Scaffold(
//       backgroundColor: const Color(0xFFEFF3FF), // Light blue background
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Top Shape and Logo
//             Stack(
//               children: [
//                 Container(
//                   height: 180,
//                   decoration: const BoxDecoration(
//                     color: Color(0xFF0047AB),
//                     borderRadius:
//                     BorderRadius.only(bottomLeft: Radius.circular(80)),
//                   ),
//                 ),
//                 const Positioned(
//                   top: 100,
//                   left: 20,
//                   child: Text(
//                     'loginnn',
//                     style: TextStyle(
//                         fontSize: 32,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 40),
//
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text("Email id",
//                       style:
//                       TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                   const SizedBox(height: 10),
//                   TextField(
//                     controller: _usernametextController,
//                     decoration: InputDecoration(
//                       hintText: "Enter your email",
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide.none),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   const Text("Password",
//                       style:
//                       TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                   const SizedBox(height: 10),
//                   TextField(
//                     controller: _passwordtextController,
//                     obscureText: true,
//                     decoration: InputDecoration(
//                       hintText: "Enter password",
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide.none),
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//
//                   // Login Button
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _send_data,
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         backgroundColor: Colors.orange,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                       child: const Text("Login",
//                           style: TextStyle(color: Colors.white, fontSize: 16)),
//                     ),
//                   ),
//
//                   const SizedBox(height: 10),
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: TextButton(
//                       onPressed: () {},
//                       child: const Text("Forgot Password ?",
//                           style: TextStyle(color: Colors.black87)),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//
//                   // Divider
//                   Row(children: const <Widget>[
//                     Expanded(child: Divider()),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 8),
//                       child: Text("or"),
//                     ),
//                     Expanded(child: Divider()),
//                   ]),
//                   const SizedBox(height: 20),
//
//                   // Facebook Button
//                   // SizedBox(
//                   //   width: double.infinity,
//                   //   child: ElevatedButton.icon(
//                   //     onPressed: () {},
//                   //     icon: const Icon(Icons.facebook, color: Colors.white),
//                   //     label: const Text("Log in with Facebook"),
//                   //     style: ElevatedButton.styleFrom(
//                   //         backgroundColor: const Color(0xFF1877F2),
//                   //         padding: const EdgeInsets.symmetric(vertical: 14),
//                   //         shape: RoundedRectangleBorder(
//                   //             borderRadius: BorderRadius.circular(8))),
//                   //   ),
//                   // ),
//                   const SizedBox(height: 30),
//
//                   // Register Prompt
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children:  [
//                       Text("Don't have an account? ",
//                           style: TextStyle(color: Colors.black87)),
//
//                       TextButton(onPressed: (){
//                         Navigator.push(context, MaterialPageRoute(
//                           builder: (context) =>candidate_signup(title: '',),));
//                       }, child: Text("Register",
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.orange)))
//                     ],
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     ));
//   }
//
//   void _send_data() async {
//     String uname = _usernametextController.text;
//     String password = _passwordtextController.text;
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String url = sh.getString('url').toString();
//
//     final urls = Uri.parse('$url/Applogin_post/');
//     try {
//       final response = await http.post(urls, body: {
//         'Username': uname,
//         'Password': password,
//       });
//       if (response.statusCode == 200) {
//         Fluttertoast.showToast(msg: 'helooo');
//         String status = jsonDecode(response.body)['status'].toString();
//         String type = jsonDecode(response.body)['type'].toString();
//         if (status =='ok') {
//           Fluttertoast.showToast(msg: 'hiiii');
//
//           String lid = jsonDecode(response.body)['lid'].toString();
//           sh.setString("lid", lid).toString();
//           if(type=='examiner'){
//
//             Fluttertoast.showToast(msg: 'examiner');
//
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => staff_home()),
//             );
//           }
//           else{
//
//             Fluttertoast.showToast(msg: 'candidate');
//
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => candidate_home()),
//             );
//           }
//
//
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
// }
