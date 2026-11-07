import 'package:ai_watcher/candidate/edit_profile.dart';
import 'package:ai_watcher/candidate/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  runApp(const UserVIewProfilepages());
}

class UserVIewProfilepages extends StatelessWidget {
  const UserVIewProfilepages({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'View Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const UserVIewProfilepagespages(title: 'View Profile'),
    );
  }
}

class UserVIewProfilepagespages extends StatefulWidget {
  const UserVIewProfilepagespages({super.key, required this.title});
  final String title;

  @override
  State<UserVIewProfilepagespages> createState() => _UserVIewProfilepagespagesState();
}

class _UserVIewProfilepagespagesState extends State<UserVIewProfilepagespages> {

  _UserVIewProfilepagespagesState() {
    _send_data();
  }

  String name_   = "";
  String dob_    = "";
  String gender_ = "";
  String email_  = "";
  String phone_  = "";
  String place_  = "";
  String state_  = "";
  String pin_    = "";
  String city_   = "";
  String photo_  = "";

  void _send_data() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();
    String img = sh.getString('img_url') ?? '';

    final urls = Uri.parse('$url/candidateviewprofile/');
    try {
      final response = await http.post(urls, body: {'lid': lid});
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          String name   = jsonDecode(response.body)['name'].toString();
          String dob    = jsonDecode(response.body)['dob'].toString();
          String gender = jsonDecode(response.body)['gender'].toString();
          String email  = jsonDecode(response.body)['email'].toString();
          String phone  = jsonDecode(response.body)['phoneno'].toString();
          String place  = jsonDecode(response.body)['place'].toString();
          String state  = jsonDecode(response.body)['state'].toString();
          String pin    = jsonDecode(response.body)['pin'].toString();
          String city   = jsonDecode(response.body)['city'].toString();
          String photo  = img + jsonDecode(response.body)['photo'].toString();

          setState(() {
            name_   = name;
            dob_    = dob;
            gender_ = gender;
            email_  = email;
            phone_  = phone;
            place_  = place;
            state_  = state;
            pin_    = pin;
            city_   = city;
            photo_  = photo;
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
                        onTap: () => Navigator.pop(context,
                       MaterialPageRoute(
                          builder: (_) => const SettingsPage()),
                      ),
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
                      // ✅ Edit icon → EditProfilePage
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EditProfilePage()),
                        ),
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: const Icon(Icons.edit_outlined,
                              color: Colors.white, size: 18),
                        ),
                      ),
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

                  // Gender + DOB pills
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (gender_.isNotEmpty)
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
                              const Icon(Icons.person_outline,
                                  color: Colors.white70, size: 13),
                              const SizedBox(width: 5),
                              Text(gender_,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      if (gender_.isNotEmpty && dob_.isNotEmpty)
                        const SizedBox(width: 8),
                      if (dob_.isNotEmpty)
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

                    // Contact card
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
                          _sectionHeader('Contact Information', Icons.contact_phone_outlined),
                          _infoRow(Icons.email_outlined, 'Email', email_),
                          _infoRow(Icons.phone_outlined, 'Phone', phone_),
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
                          _infoRow(Icons.place_outlined,         'Place', place_),
                          _infoRow(Icons.location_city_outlined, 'City',  city_),
                          _infoRow(Icons.map_outlined,           'State', state_),
                          _infoRow(Icons.pin_outlined,           'PIN',   pin_),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ✅ Edit Profile button → EditProfilePage
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfilePage()),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_primary, _primaryLight],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _primary.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                            SizedBox(width: 10),
                            Text('Edit Profile',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}