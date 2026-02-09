import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ViewProfile());
}

class ViewProfile extends StatelessWidget {
  const ViewProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'View Profile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const viewprofile(title: 'View Profile'),
    );
  }
}

class viewprofile extends StatefulWidget {
  const viewprofile({super.key, required this.title});

  final String title;

  @override
  State<viewprofile> createState() => _viewprofileState();
}

class _viewprofileState extends State<viewprofile> {
  _viewprofileState() {
    _send_data();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async { return true; },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF), // Match home page background
        appBar: AppBar(
          leading: BackButton(
            color: const Color(0xFF1E293B), // Dark blue
          ),
          backgroundColor: Colors.white, // White app bar
          elevation: 0,
          title: Text(
            widget.title,
            style: const TextStyle(
              color: Color(0xFF1E293B), // Dark blue text
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Profile Header with Gradient
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Profile Photo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: photo_.isNotEmpty
                            ? Image.network(
                          photo_,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.white,
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFF3B82F6),
                                  size: 50,
                                ),
                              ),
                        )
                            : Container(
                          color: Colors.white,
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF3B82F6),
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Name
                    Text(
                      name_,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Email
                    Text(
                      email_,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Examiner',
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

              const SizedBox(height: 30),

              // Personal Information Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Information Cards
                    _InfoCard(
                      icon: Icons.cake_outlined,
                      title: 'Date of Birth',
                      value: dob_,
                      color: const Color(0xFF3B82F6),
                    ),
                    _InfoCard(
                      icon: Icons.transgender_outlined,
                      title: 'Gender',
                      value: gender_,
                      color: const Color(0xFF10B981),
                    ),
                    _InfoCard(
                      icon: Icons.phone_outlined,
                      title: 'Phone Number',
                      value: phone_,
                      color: const Color(0xFFF59E0B),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Address Information Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Address Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Address Cards
                    _InfoCard(
                      icon: Icons.location_city_outlined,
                      title: 'City',
                      value: city_,
                      color: const Color(0xFF8B5CF6),
                    ),
                    _InfoCard(
                      icon: Icons.location_on_outlined,
                      title: 'State',
                      value: state_,
                      color: const Color(0xFFEF4444),
                    ),
                    _InfoCard(
                      icon: Icons.place_outlined,
                      title: 'Place',
                      value: place_,
                      color: const Color(0xFF3B82F6),
                    ),
                    _InfoCard(
                      icon: Icons.local_post_office_outlined,
                      title: 'Post Office',
                      value: post_,
                      color: const Color(0xFF10B981),
                    ),
                    _InfoCard(
                      icon: Icons.pin_outlined,
                      title: 'PIN Code',
                      value: pin_,
                      color: const Color(0xFFF59E0B),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Edit Profile Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Add edit profile functionality here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  String name_ = "";
  String dob_ = "";
  String gender_ = "";
  String email_ = "";
  String phone_ = "";
  String place_ = "";
  String post_ = "";
  String pin_ = "";
  String state_ = "";
  String city_ = "";
  String photo_ = "";

  void _send_data() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();
    String img = sh.getString('img_url').toString();

    final urls = Uri.parse('$url/examinerviewprofile/');
    try {
      final response = await http.post(urls, body: {
        'lid': lid
      });
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          String name = jsonDecode(response.body)['name'].toString();
          String dob = jsonDecode(response.body)['dob'].toString();
          String gender = jsonDecode(response.body)['gender'].toString();
          String email = jsonDecode(response.body)['email'].toString();
          String state = jsonDecode(response.body)['state'].toString();
          String phone = jsonDecode(response.body)['phoneno'].toString();
          String place = jsonDecode(response.body)['place'].toString();
          String post = jsonDecode(response.body)['post'].toString();
          String pin = jsonDecode(response.body)['pin'].toString();
          String city = jsonDecode(response.body)['city'].toString();
          String photo = img + jsonDecode(response.body)['photo'].toString();

          setState(() {
            name_ = name;
            dob_ = dob;
            gender_ = gender;
            email_ = email;
            phone_ = phone;
            place_ = place;
            post_ = post;
            state_ = state;
            pin_ = pin;
            city_ = city;
            photo_ = photo;
          });
        } else {
          Fluttertoast.showToast(msg: 'Not Found');
        }
      } else {
        Fluttertoast.showToast(msg: 'Network Error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}

// Custom Info Card Widget
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Not specified',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:fluttertoast/fluttertoast.dart';
//
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() {
//   runApp(const ViewProfile());
// }
//
// class ViewProfile extends StatelessWidget {
//   const ViewProfile({super.key});
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
//       home: const viewprofile(title: 'View Profile'),
//     );
//   }
// }
//
// class viewprofile extends StatefulWidget {
//   const viewprofile({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<viewprofile> createState() => _viewprofileState();
// }
//
// class _viewprofileState extends State<viewprofile> {
//
//   _viewprofileState()
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
//                     child: Text(state_),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(5),
//                     child: Text(place_),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(5),
//                     child: Text(post_),
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
//
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
//   String post_="";
//   String pin_="";
//   String state_="";
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
//     String img = sh.getString('img_url').toString();
//
//     final urls = Uri.parse('$url/examinerviewprofile/');
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
//           String state=jsonDecode(response.body)['state'].toString();
//           String phone=jsonDecode(response.body)['phoneno'].toString();
//           String place=jsonDecode(response.body)['place'].toString();
//           String post=jsonDecode(response.body)['post'].toString();
//           String pin=jsonDecode(response.body)['pin'].toString();
//           String city=jsonDecode(response.body)['city'].toString();
//           String photo=img+jsonDecode(response.body)['photo'].toString();
//
//           setState(() {
//
//             name_= name;
//             dob_= dob;
//             gender_= gender;
//             email_= email;
//             phone_= phone;
//             place_= place;
//             post_= post;
//             state_=state;
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
