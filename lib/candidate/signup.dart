import 'dart:convert';
import 'dart:io';
import 'package:ai_watcher/candidate/candidate_home.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../login.dart';

const _primary      = Color(0xFF194569);
const _primaryLight = Color(0xFF2A6096);
const _bg           = Color(0xFFF0F4F8);
const _card         = Colors.white;
const _text         = Color(0xFF0D1F2D);
const _sub          = Color(0xFF607D8B);
const _divider      = Color(0xFFE8EEF4);

void main() => runApp(candidate_signup(title: ''));

class candidate_signup extends StatefulWidget {
  const candidate_signup({super.key, required this.title});
  final String title;
  @override
  State<candidate_signup> createState() => _candidate_signupState();
}

class _candidate_signupState extends State<candidate_signup> {
  final _formKey = GlobalKey<FormState>();

  // Step control
  bool _regVerified   = false;
  bool _verifyLoading = false;

  final _regNumberController           = TextEditingController();
  final _nametextController            = TextEditingController();
  final _emailtextController           = TextEditingController();
  final _phonenotextController         = TextEditingController();
  final _placetextController           = TextEditingController();
  final _statetextController           = TextEditingController();
  final _citytextController            = TextEditingController();
  final _dobtextController             = TextEditingController();
  final _pintextController             = TextEditingController();
  final _passwordtextController        = TextEditingController();
  final _confirmpasswordtextController = TextEditingController();

  String gender = '';
  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;
  File? _selectedImage;

  // ── Verify registration number ────────────────────────────────────────
  Future<void> _verifyRegNumber() async {
    final reg = _regNumberController.text.trim();
    if (reg.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter registration number");
      return;
    }
    setState(() => _verifyLoading = true);

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      setState(() => _verifyLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$url/validate_reg_number/'),
        body: {'reg_number': reg},
      );
      final data = jsonDecode(response.body);

      if (data['status'] == 'ok') {
        setState(() {
          _regVerified = true;
          if ((data['name'] ?? '').isNotEmpty) {
            _nametextController.text = data['name'];
          }
          if ((data['email'] ?? '').isNotEmpty) {
            _emailtextController.text = data['email'];
          }
        });
        Fluttertoast.showToast(msg: "Registration number verified ✓");
      } else if (data['status'] == 'used') {
        Fluttertoast.showToast(
            msg: "This number has already been used for signup.");
      } else {
        Fluttertoast.showToast(msg: "Invalid registration number.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
    setState(() => _verifyLoading = false);
  }

  Future<void> _chooseImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    } else {
      Fluttertoast.showToast(msg: "No image selected");
    }
  }

  Future<void> _sendData() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    final uri     = Uri.parse('$url/candidatesignup/');
    var   request = http.MultipartRequest('POST', uri);

    request.fields['reg_number']      = _regNumberController.text.trim();
    request.fields['name']            = _nametextController.text;
    request.fields['email']           = _emailtextController.text;
    request.fields['phoneno']         = _phonenotextController.text;
    request.fields['place']           = _placetextController.text;
    request.fields['state']           = _statetextController.text;
    request.fields['city']            = _citytextController.text;
    request.fields['dob']             = _dobtextController.text;
    request.fields['pin']             = _pintextController.text;
    request.fields['password']        = _passwordtextController.text;
    request.fields['confirmpassword'] = _confirmpasswordtextController.text;
    request.fields['gender']          = gender;

    if (_selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('photo', _selectedImage!.path),
      );
    }

    try {
      var response = await request.send();
      var respStr  = await response.stream.bytesToString();
      var data     = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Account created successfully!");
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => LoginScreen(title: '')));
      } else {
        Fluttertoast.showToast(msg: data['message'] ?? "Submission failed.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  // ── Reusable field ────────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure   = false,
    bool hasToggle = false,
    bool readOnly  = false,
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
            color: readOnly ? _divider : _bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _primary.withOpacity(0.15)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            readOnly: readOnly,
            style: const TextStyle(fontSize: 14, color: _text),
            decoration: InputDecoration(
              hintText: readOnly ? null : 'Enter your ${label.toLowerCase()}',
              hintStyle:
              TextStyle(color: _sub.withOpacity(0.6), fontSize: 13),
              prefixIcon:
              Icon(icon, color: _primary.withOpacity(0.6), size: 20),
              suffixIcon: hasToggle
                  ? GestureDetector(
                onTap: onToggle,
                child: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _sub,
                  size: 20,
                ),
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
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
      padding: const EdgeInsets.only(bottom: 16, top: 8),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const CandidateHome()));
        return false;
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [

            // ── Gradient Header ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primary, _primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen(title: ''))),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(11),
                        border:
                        Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create Account',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        Text('Verify your registration number first',
                            style: TextStyle(
                                fontSize: 12, color: Colors.white60)),
                      ],
                    ),
                  ),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border:
                      Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.person_add_outlined,
                        color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            // ── Scrollable Form ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 60),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── STEP 1 : Registration Number ──────────────
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _regVerified
                                ? Colors.green.withOpacity(0.5)
                                : _divider,
                            width: _regVerified ? 2 : 1,
                          ),
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
                            _sectionHeader(
                              _regVerified
                                  ? 'Registration Verified ✓'
                                  : 'Step 1: Enter Registration Number',
                              _regVerified
                                  ? Icons.verified_outlined
                                  : Icons.badge_outlined,
                            ),
                            const Text(
                              'Enter the registration / application number '
                                  'provided by the admin.',
                              style: TextStyle(fontSize: 12, color: _sub),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _bg,
                                      borderRadius:
                                      BorderRadius.circular(14),
                                      border: Border.all(
                                          color:
                                          _primary.withOpacity(0.15)),
                                    ),
                                    child: TextFormField(
                                      controller: _regNumberController,
                                      enabled: !_regVerified,
                                      style: const TextStyle(
                                          fontSize: 14, color: _text),
                                      decoration: InputDecoration(
                                        hintText: 'e.g. APP2024001',
                                        hintStyle: TextStyle(
                                            color: _sub.withOpacity(0.6),
                                            fontSize: 13),
                                        prefixIcon: Icon(Icons.numbers,
                                            color:
                                            _primary.withOpacity(0.6),
                                            size: 20),
                                        border: InputBorder.none,
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                if (!_regVerified)
                                  GestureDetector(
                                    onTap: _verifyLoading
                                        ? null
                                        : _verifyRegNumber,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 16),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [_primary, _primaryLight],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                            _primary.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: _verifyLoading
                                          ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child:
                                        CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                          : const Text('Verify',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight:
                                              FontWeight.w700)),
                                    ),
                                  ),
                                if (_regVerified)
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color:
                                      Colors.green.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check_circle,
                                        color: Colors.green, size: 28),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── STEP 2 : Full form after verification ─────
                      if (_regVerified) ...[
                        const SizedBox(height: 20),

                        // Profile photo card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _divider),
                            boxShadow: [
                              BoxShadow(
                                  color: _primary.withOpacity(0.07),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _chooseImage,
                                child: Container(
                                  width: 100, height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: _primary.withOpacity(0.3),
                                        width: 2),
                                    color: _bg,
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: _selectedImage != null
                                      ? Image.file(_selectedImage!,
                                      fit: BoxFit.cover)
                                      : Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                          Icons.camera_alt_outlined,
                                          color: _primary
                                              .withOpacity(0.5),
                                          size: 28),
                                      const SizedBox(height: 4),
                                      Text('Photo',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: _primary
                                                  .withOpacity(
                                                  0.5))),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: _chooseImage,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: _primary.withOpacity(0.35),
                                        width: 1.2),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.upload_outlined,
                                          color: _primary, size: 16),
                                      const SizedBox(width: 6),
                                      const Text('Choose Image',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: _primary)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

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
                                  offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionHeader('Personal Information',
                                  Icons.person_outline),
                              _buildField(
                                controller: _nametextController,
                                label: 'Full Name',
                                icon: Icons.badge_outlined,
                                validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Name is required'
                                    : null,
                              ),
                              _buildField(
                                controller: _emailtextController,
                                label: 'Email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return 'Email is required';
                                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v))
                                    return 'Enter a valid email';
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: _phonenotextController,
                                label: 'Phone Number',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return 'Phone number is required';
                                  if (!RegExp(r'^[0-9]{10}$').hasMatch(v))
                                    return 'Enter valid 10-digit number';
                                  return null;
                                },
                              ),
                              _buildField(
                                controller: _dobtextController,
                                label: 'Date of Birth',
                                icon: Icons.cake_outlined,
                              ),
                              // Gender selector
                              const Text('Gender',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _text)),
                              const SizedBox(height: 10),
                              Row(
                                children:
                                ['Male', 'Female', 'Other'].map((g) {
                                  final selected = gender == g;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => gender = g),
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right:
                                            g == 'Other' ? 0 : 8),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? _primary.withOpacity(0.07)
                                              : _bg,
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          border: Border.all(
                                            color: selected
                                                ? _primary
                                                : _divider,
                                            width: selected ? 1.5 : 1,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              g == 'Male'
                                                  ? Icons.male
                                                  : g == 'Female'
                                                  ? Icons.female
                                                  : Icons.transgender,
                                              color: selected
                                                  ? _primary
                                                  : _sub,
                                              size: 20,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(g,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: selected
                                                        ? FontWeight.w700
                                                        : FontWeight.w400,
                                                    color: selected
                                                        ? _primary
                                                        : _sub)),
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
                                  offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionHeader('Address Details',
                                  Icons.location_on_outlined),
                              _buildField(
                                controller: _placetextController,
                                label: 'Place',
                                icon: Icons.place_outlined,
                                validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Place is required'
                                    : null,
                              ),
                              _buildField(
                                controller: _citytextController,
                                label: 'City',
                                icon: Icons.location_city_outlined,
                                validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'City is required'
                                    : null,
                              ),
                              _buildField(
                                controller: _statetextController,
                                label: 'State',
                                icon: Icons.map_outlined,
                                validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'State is required'
                                    : null,
                              ),
                              _buildField(
                                controller: _pintextController,
                                label: 'PIN Code',
                                icon: Icons.pin_outlined,
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return 'PIN is required';
                                  if (!RegExp(r'^[0-9]{6}$').hasMatch(v))
                                    return 'Enter valid 6-digit PIN';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Password card
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
                                  offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionHeader(
                                  'Security', Icons.lock_outline),
                              _buildField(
                                controller: _passwordtextController,
                                label: 'Password',
                                icon: Icons.lock_outline,
                                obscure: _obscurePassword,
                                hasToggle: true,
                                onToggle: () => setState(() =>
                                _obscurePassword = !_obscurePassword),
                                validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Password is required'
                                    : null,
                              ),
                              _buildField(
                                controller: _confirmpasswordtextController,
                                label: 'Confirm Password',
                                icon: Icons.lock_reset_outlined,
                                obscure: _obscureConfirmPassword,
                                hasToggle: true,
                                onToggle: () => setState(() =>
                                _obscureConfirmPassword =
                                !_obscureConfirmPassword),
                                validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Confirm password is required'
                                    : null,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Submit button
                        GestureDetector(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              if (gender.isEmpty) {
                                Fluttertoast.showToast(
                                    msg: "Please select gender");
                                return;
                              }
                              if (_selectedImage == null) {
                                Fluttertoast.showToast(
                                    msg: "Please choose a photo");
                                return;
                              }
                              _sendData();
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Please fix errors in the form");
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding:
                            const EdgeInsets.symmetric(vertical: 16),
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
                                Icon(Icons.check_circle_outline,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 10),
                                Text('Create Account',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Already have account
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => LoginScreen(title: ''))),
                            child: RichText(
                              text: const TextSpan(
                                text: 'Already have an account? ',
                                style:
                                TextStyle(fontSize: 13, color: _sub),
                                children: [
                                  TextSpan(
                                    text: 'Login',
                                    style: TextStyle(
                                        color: _primary,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      // ── end _regVerified ──────────────────────────
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