import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// ─── Theme (same as all pages) ────────────────────────────────────────────────
const _primary      = Color(0xFF194569);
const _primaryLight = Color(0xFF2A6096);
const _bg           = Color(0xFFF0F4F8);
const _card         = Colors.white;
const _text         = Color(0xFF0D1F2D);
const _sub          = Color(0xFF607D8B);
const _divider      = Color(0xFFE8EEF4);
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  runApp(const EditProfileApp());
}

class EditProfileApp extends StatelessWidget {
  const EditProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: _bg,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),
      home: const EditProfilePage(),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController  = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController  = TextEditingController();
  final TextEditingController _dobController   = TextEditingController();
  final TextEditingController _pinController   = TextEditingController();

  String gender        = '';
  String _currentPhoto = '';
  File?  _selectedImage;
  bool   _isLoading    = false;
  bool   _isSaving     = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url').toString();
      String lid = sh.getString('lid').toString();
      String img = sh.getString('img_url') ?? '';

      final uri = Uri.parse('$url/candidateviewprofile/');
      final response = await http.post(uri, body: {'lid': lid});

      if (response.statusCode == 200) {
        final data    = jsonDecode(response.body);
        String status = data['status'].toString();

        if (status == 'ok') {
          setState(() {
            _nameController.text  = data['name'].toString();
            _emailController.text = data['email'].toString();
            _phoneController.text = data['phoneno'].toString();
            _placeController.text = data['place'].toString();
            _stateController.text = data['state'].toString();
            _cityController.text  = data['city'].toString();
            _dobController.text   = data['dob'].toString();
            _pinController.text   = data['pin'].toString();
            gender                = data['gender'].toString();
            _currentPhoto         = img + data['photo'].toString();
          });
        } else {
          Fluttertoast.showToast(msg: 'Profile not found');
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error loading profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _chooseImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    } else {
      Fluttertoast.showToast(msg: "No image selected");
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(msg: "Please fix errors in the form");
      return;
    }

    setState(() => _isSaving = true);

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? url = sh.getString('url');
      String lid  = sh.getString('lid').toString();

      if (url == null) {
        Fluttertoast.showToast(msg: "Server URL not found.");
        return;
      }

      final uri     = Uri.parse('$url/candidateeditprofile/');
      var   request = http.MultipartRequest('POST', uri);

      request.fields['lid']     = lid;
      request.fields['name']    = _nameController.text;
      request.fields['email']   = _emailController.text;
      request.fields['phoneno'] = _phoneController.text;
      request.fields['place']   = _placeController.text;
      request.fields['state']   = _stateController.text;
      request.fields['city']    = _cityController.text;
      request.fields['dob']     = _dobController.text;
      request.fields['pin']     = _pinController.text;
      request.fields['gender']  = gender;

      if (_selectedImage != null) {
        request.files.add(
            await http.MultipartFile.fromPath('photo', _selectedImage!.path));
      }

      var response = await request.send();
      var respStr  = await response.stream.bytesToString();
      var data     = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Profile updated successfully.");
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: "Update failed. Please try again.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure   = false,
    bool hasToggle = false,
    VoidCallback? onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: _text)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _primary.withOpacity(0.15)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: _text),
            decoration: InputDecoration(
              hintText: 'Enter your ${label.toLowerCase()}',
              hintStyle: TextStyle(color: _sub.withOpacity(0.6), fontSize: 13),
              prefixIcon: Icon(icon, color: _primary.withOpacity(0.6), size: 20),
              suffixIcon: hasToggle
                  ? GestureDetector(
                onTap: onToggle,
                child: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: _sub, size: 20,
                ),
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              errorStyle: const TextStyle(fontSize: 11),
            ),
            validator: validator,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 4),
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _primary))
            : Column(
          children: [

            // ── Gradient Header ──────────────────────────────────
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
                          child: Text('Edit Profile',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                      ),
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: const Icon(Icons.edit_outlined,
                            color: Colors.white, size: 18),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tappable avatar
                  GestureDetector(
                    onTap: _chooseImage,
                    child: Stack(
                      children: [
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
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (_currentPhoto.isNotEmpty
                                ? NetworkImage(_currentPhoto) as ImageProvider
                                : null),
                            child: (_selectedImage == null && _currentPhoto.isEmpty)
                                ? const Icon(Icons.person, color: Colors.white, size: 40)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 2, right: 2,
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_primary, _primaryLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    _nameController.text.isEmpty ? 'Your Name' : _nameController.text,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text('Tap photo to change',
                      style: TextStyle(
                          fontSize: 12, color: Colors.white.withOpacity(0.6))),
                ],
              ),
            ),

            // ── Form ────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 60),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Personal info card
                      Container(
                        padding: const EdgeInsets.all(20),
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
                            _buildField(
                              controller: _nameController,
                              label: 'Full Name',
                              icon: Icons.badge_outlined,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Name is required';
                                return null;
                              },
                            ),
                            _buildField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Email is required';
                                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) return 'Enter a valid email';
                                return null;
                              },
                            ),
                            _buildField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Phone number is required';
                                if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) return 'Enter a valid 10-digit number';
                                return null;
                              },
                            ),
                            _buildField(
                              controller: _dobController,
                              label: 'Date of Birth',
                              icon: Icons.cake_outlined,
                            ),
                            const Text('Gender',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600, color: _text)),
                            const SizedBox(height: 10),
                            Row(
                              children: ['Male', 'Female', 'Other'].map((g) {
                                final selected = gender == g || gender == g.toLowerCase();
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => gender = g),
                                    child: Container(
                                      margin: EdgeInsets.only(right: g == 'Other' ? 0 : 8),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: selected ? _primary.withOpacity(0.07) : _bg,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: selected ? _primary : _divider,
                                          width: selected ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            g == 'Male' ? Icons.male : g == 'Female' ? Icons.female : Icons.transgender,
                                            color: selected ? _primary : _sub, size: 20,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(g,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                                                  color: selected ? _primary : _sub)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Address card
                      Container(
                        padding: const EdgeInsets.all(20),
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
                            _buildField(
                              controller: _placeController,
                              label: 'Place',
                              icon: Icons.place_outlined,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Place is required';
                                return null;
                              },
                            ),
                            _buildField(
                              controller: _cityController,
                              label: 'City',
                              icon: Icons.location_city_outlined,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'City is required';
                                return null;
                              },
                            ),
                            _buildField(
                              controller: _stateController,
                              label: 'State',
                              icon: Icons.map_outlined,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'State is required';
                                return null;
                              },
                            ),
                            _buildField(
                              controller: _pinController,
                              label: 'PIN Code',
                              icon: Icons.pin_outlined,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'PIN is required';
                                if (!RegExp(r'^[0-9]{6}$').hasMatch(v)) return 'Enter a valid 6-digit PIN';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Save button
                      GestureDetector(
                        onTap: _isSaving ? null : _saveChanges,
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
                          child: _isSaving
                              ? const Center(
                            child: SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            ),
                          )
                              : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_outlined, color: Colors.white, size: 18),
                              SizedBox(width: 10),
                              Text('Save Changes',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Cancel button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: _primary.withOpacity(0.25), width: 1.5),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close_rounded, color: _primary, size: 18),
                              SizedBox(width: 10),
                              Text('Cancel',
                                  style: TextStyle(
                                      color: _primary,
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
            ),
          ],
        ),
      ),
    );
  }
}