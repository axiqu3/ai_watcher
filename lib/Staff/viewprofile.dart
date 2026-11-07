import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Theme (same as candidate & video call pages) ─────────────────────────────
const _primary      = Color(0xFF194569);
const _primaryLight = Color(0xFF2A6096);
const _bg           = Color(0xFFF0F4F8);
const _card         = Colors.white;
const _text         = Color(0xFF0D1F2D);
const _sub          = Color(0xFF607D8B);
const _divider      = Color(0xFFE8EEF4);
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  runApp(const ViewProfile());
}

class ViewProfile extends StatelessWidget {
  const ViewProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'View Profile',
      debugShowCheckedModeBanner: false,
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
    sendData();
  }

  String name_   = "";
  String dob_    = "";
  String gender_ = "";
  String email_  = "";
  String phone_  = "";
  String place_  = "";
  String post_   = "";
  String pin_    = "";
  String state_  = "";
  String city_   = "";
  String photo_  = "";

  // ── Info row helper ───────────────────────────────────────────────────────
  Widget _infoRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primary.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: _primary, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: _sub, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '—' : value,
                  style: const TextStyle(
                      fontSize: 14, color: _text, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ────────────────────────────────────────────────────────
  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, top: 4),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [_primary, _primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [

            // ── Gradient Header with avatar ──────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 30),
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
              child: Column(
                children: [
                  // Top bar
                  Row(
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
                      const Expanded(
                        child: Center(
                          child: Text('My Profile',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                      ),
                      // Edit icon placeholder (add navigation if needed)
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white24,
                      backgroundImage: photo_.isNotEmpty
                          ? NetworkImage(photo_)
                          : null,
                      child: photo_.isEmpty
                          ? const Icon(Icons.person, color: Colors.white, size: 40)
                          : null,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    name_.isEmpty ? 'Loading...' : name_,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email_.isEmpty ? '' : email_,
                    style: TextStyle(
                        fontSize: 13, color: Colors.white.withOpacity(0.7)),
                  ),

                  const SizedBox(height: 14),

                  // Role badge + DOB pills
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_user_outlined,
                                color: Colors.white70, size: 13),
                            SizedBox(width: 5),
                            Text('Examiner',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      if (dob_.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.cake_outlined,
                                  color: Colors.white70, size: 13),
                              const SizedBox(width: 5),
                              Text(dob_,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ── Profile details ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Personal Info card
                    Container(
                      padding: const EdgeInsets.all(18),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader('Personal Information', Icons.person_outline),
                          _infoRow(Icons.cake_outlined,        'Date of Birth', dob_),
                          _infoRow(Icons.transgender_outlined, 'Gender',        gender_),
                          _infoRow(Icons.phone_outlined,       'Phone',         phone_),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Address card
                    Container(
                      padding: const EdgeInsets.all(18),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader('Address Details', Icons.location_on_outlined),
                          _infoRow(Icons.place_outlined,              'Place',       place_),
                          _infoRow(Icons.location_city_outlined,      'City',        city_),
                          _infoRow(Icons.map_outlined,                'State',       state_),
                          _infoRow(Icons.local_post_office_outlined,  'Post Office', post_),
                          _infoRow(Icons.pin_outlined,                'PIN Code',    pin_),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendData() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();
    String img = sh.getString('img_url') ?? '';

    final urls = Uri.parse('$url/examinerviewprofile/');
    try {
      final response = await http.post(urls, body: {'lid': lid});
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          setState(() {
            name_   = jsonDecode(response.body)['name'].toString();
            dob_    = jsonDecode(response.body)['dob'].toString();
            gender_ = jsonDecode(response.body)['gender'].toString();
            email_  = jsonDecode(response.body)['email'].toString();
            phone_  = jsonDecode(response.body)['phoneno'].toString();
            place_  = jsonDecode(response.body)['place'].toString();
            post_   = jsonDecode(response.body)['post'].toString();
            state_  = jsonDecode(response.body)['state'].toString();
            pin_    = jsonDecode(response.body)['pin'].toString();
            city_   = jsonDecode(response.body)['city'].toString();
            photo_  = img + jsonDecode(response.body)['photo'].toString();
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