import 'dart:convert';
import 'dart:io';
import 'package:ai_watcher/Staff/view_question.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'staff_home.dart';

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
  runApp(const add_question(title: ''));
}

class add_question extends StatefulWidget {
  const add_question({super.key, required this.title});
  final String title;

  @override
  State<add_question> createState() => _add_questionState();
}

class _add_questionState extends State<add_question> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _questiontextController = TextEditingController();
  final TextEditingController _opt1textController     = TextEditingController();
  final TextEditingController _opt2textController     = TextEditingController();
  final TextEditingController _opt3textController     = TextEditingController();
  final TextEditingController _opt4textController     = TextEditingController();
  final TextEditingController _anstextController      = TextEditingController();

  File? _selectedImage;

  Future<void> _chooseImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      Fluttertoast.showToast(msg: "No image selected");
    }
  }

  Future<void> _sendData() async {
    String uquestion = _questiontextController.text;
    String uopt1     = _opt1textController.text;
    String uopt2     = _opt2textController.text;
    String uopt3     = _opt3textController.text;
    String uopt4     = _opt4textController.text;
    String uans      = _anstextController.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url  = sh.getString('url');
    String? exam = sh.getString('exam');

    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    final uri     = Uri.parse('$url/examineraddquestion/');
    var   request = http.MultipartRequest('POST', uri);
    request.fields['question'] = uquestion;
    request.fields['option1']  = uopt1;
    request.fields['option2']  = uopt2;
    request.fields['option3']  = uopt3;
    request.fields['option4']  = uopt4;
    request.fields['answer']   = uans;
    request.fields['aid']      = exam.toString();

    if (_selectedImage != null) {
      request.files.add(
          await http.MultipartFile.fromPath('photo', _selectedImage!.path));
    }

    try {
      var response = await request.send();
      var respStr  = await response.stream.bytesToString();
      var data     = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Submitted successfully.");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => view_question(title: '')));
      } else {
        Fluttertoast.showToast(msg: "Submission failed.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
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
                end: Alignment.bottomRight,
              ),
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

  // ── Input field ───────────────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: _text)),
        const SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            color: readOnly ? _primary.withOpacity(0.05) : _bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: readOnly
                  ? _primary.withOpacity(0.25)
                  : _primary.withOpacity(0.15),
            ),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            style: const TextStyle(fontSize: 14, color: _text),
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle:
              TextStyle(color: _sub.withOpacity(0.6), fontSize: 13),
              prefixIcon:
              Icon(icon, color: _primary.withOpacity(0.6), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              errorStyle: const TextStyle(fontSize: 11),
            ),
            validator: validator,
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ── Option tile with tap-to-select-as-answer ──────────────────────────────
  Widget _buildOptionTile({
    required String label,
    required TextEditingController controller,
    required String optionLetter,
  }) {
    final isSelected = _anstextController.text.isNotEmpty &&
        _anstextController.text == controller.text &&
        controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: _text)),
        const SizedBox(height: 7),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Option letter badge
            Container(
              width: 40, height: 40,
              margin: const EdgeInsets.only(top: 2, right: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                  colors: [_primary, _primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: isSelected ? null : _bg,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: isSelected ? _primary : _divider,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: Text(optionLetter,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : _sub)),
              ),
            ),

            // Text field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? _primary.withOpacity(0.05) : _bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? _primary : _primary.withOpacity(0.15),
                    width: isSelected ? 1.6 : 1,
                  ),
                ),
                child: TextFormField(
                  controller: controller,
                  maxLines: 2,
                  // ── onTap: original logic — set answer = this option ──
                  onTap: () {
                    setState(() {
                      _anstextController.text = controller.text;
                    });
                  },
                  onChanged: (v) {
                    // If this option is currently selected as answer, update answer too
                    if (_anstextController.text == v ||
                        _anstextController.text.isEmpty) {
                      setState(() {});
                    } else {
                      setState(() {});
                    }
                  },
                  style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? _primary : _text,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal),
                  decoration: InputDecoration(
                    hintText: 'Type option $optionLetter...',
                    hintStyle: TextStyle(
                        color: _sub.withOpacity(0.6), fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    suffixIcon: isSelected
                        ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.check_circle_rounded,
                          color: _primary, size: 20),
                    )
                        : null,
                    errorStyle: const TextStyle(fontSize: 11),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Option $optionLetter is required';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const staff_home()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [

            // ── Gradient Header ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 28),
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
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -30, right: -20,
                    child: Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8, right: 35,
                    child: Container(
                      width: 55, height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back + title
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const staff_home()),
                            ),
                            child: Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.2)),
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
                                Text('Add Question',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                                Text('Fill in question and options below',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white60)),
                              ],
                            ),
                          ),
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2)),
                            ),
                            child: const Icon(Icons.quiz_outlined,
                                color: Colors.white, size: 20),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Tip banner ───────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.touch_app_outlined,
                                color: Colors.white70, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tap any option field to set it as the correct answer',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Form body ─────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 60),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Question card ────────────────────────────────
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
                            _sectionHeader('Question', Icons.help_outline_rounded),
                            _buildField(
                              controller: _questiontextController,
                              label: 'Question Text',
                              icon: Icons.edit_note_rounded,
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty)
                                  return 'Question is required';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Options card ─────────────────────────────────
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
                            _sectionHeader(
                                'Options  •  Tap to mark as Answer',
                                Icons.list_alt_outlined),

                            _buildOptionTile(
                              label: 'Option A',
                              controller: _opt1textController,
                              optionLetter: 'A',
                            ),
                            _buildOptionTile(
                              label: 'Option B',
                              controller: _opt2textController,
                              optionLetter: 'B',
                            ),
                            _buildOptionTile(
                              label: 'Option C',
                              controller: _opt3textController,
                              optionLetter: 'C',
                            ),
                            _buildOptionTile(
                              label: 'Option D',
                              controller: _opt4textController,
                              optionLetter: 'D',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Selected answer display card ──────────────────
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _primary.withOpacity(0.06),
                              _primaryLight.withOpacity(0.04),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: _primary.withOpacity(0.18)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                gradient: _anstextController.text.isNotEmpty
                                    ? const LinearGradient(
                                  colors: [_primary, _primaryLight],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                                    : null,
                                color: _anstextController.text.isEmpty
                                    ? _divider
                                    : null,
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Icon(
                                _anstextController.text.isNotEmpty
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked,
                                color: _anstextController.text.isNotEmpty
                                    ? Colors.white
                                    : _sub,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Correct Answer',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: _sub)),
                                  const SizedBox(height: 4),
                                  Text(
                                    _anstextController.text.isNotEmpty
                                        ? _anstextController.text
                                        : 'Tap an option above to select answer',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                      _anstextController.text.isNotEmpty
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: _anstextController.text.isNotEmpty
                                          ? _primary
                                          : _sub.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Hidden answer validator field
                      Opacity(
                        opacity: 0,
                        child: SizedBox(
                          height: 0,
                          child: TextFormField(
                            controller: _anstextController,
                            readOnly: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return 'Answer is required';
                              return null;
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Submit button ────────────────────────────────
                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            _sendData();
                          } else {
                            Fluttertoast.showToast(
                                msg: "Please fix errors in the form");
                          }
                        },
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
                              Icon(Icons.check_circle_outline,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 10),
                              Text('Submit Question',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Cancel button ────────────────────────────────
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const staff_home()),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: _primary.withOpacity(0.25),
                                width: 1.5),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close_rounded,
                                  color: _primary, size: 18),
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









// import 'dart:convert';
// import 'dart:io';
// import 'package:ai_watcher/Staff/view_question.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
//
// import 'staff_home.dart';
//
//
//
// void main() {
//   runApp( add_question(title: '',));
// }
//
// class add_question extends StatefulWidget {
//   const add_question({super.key, required this.title});
//
//   final String title;
//   @override
//   State<add_question> createState() => _add_questionState();
//
// }
// class _add_questionState extends State<add_question> {
//
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _questiontextController = TextEditingController();
//   final TextEditingController _opt1textController = TextEditingController();
//   final TextEditingController _opt2textController = TextEditingController();
//   final TextEditingController _opt3textController = TextEditingController();
//   final TextEditingController _opt4textController = TextEditingController();
//   final TextEditingController _anstextController = TextEditingController();
//
//   File? _selectedImage;
//   Future<void> _chooseImage() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     }
//     else {
//       Fluttertoast.showToast(msg: "No image selected");
//     }
//   }
//
//   Future<void> _sendData() async {
//     String uquestion = _questiontextController.text;
//     String uopt1 = _opt1textController.text;
//     String uopt2 = _opt2textController.text;
//     String uopt3 = _opt3textController.text;
//     String uopt4 = _opt4textController.text;
//     String uans = _anstextController.text;
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String? url = sh.getString('url');
//     String? exam = sh.getString('exam');
//
//     if (url == null) {
//       Fluttertoast.showToast(msg: "Server URL not found.");
//       return;
//     }
//
//     final uri = Uri.parse('$url/examineraddquestion/');
//     var request = http.MultipartRequest('POST', uri);
//     request.fields['question'] = uquestion;
//     request.fields['option1'] = uopt1;
//     request.fields['option2'] = uopt2;
//     request.fields['option3'] = uopt3;
//     request.fields['option4'] = uopt4;
//     request.fields['answer'] = uans;
//     request.fields['aid'] = exam.toString();
//
//     if (_selectedImage != null) {
//       request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
//     }
//
//     try {
//       var response = await request.send();
//       var respStr = await response.stream.bytesToString();
//       var data = jsonDecode(respStr);
//
//       if (response.statusCode == 200 && data['status'] == 'ok') {
//         Fluttertoast.showToast(msg: "Submitted successfully.");
//         Navigator.push(context, MaterialPageRoute(builder: (context)=>view_question(title: '',)));
//       } else {
//         Fluttertoast.showToast(msg: "Submission failed.");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const staff_home()),
//         );
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(widget.title),
//           centerTitle: true,
//           backgroundColor: Theme.of(context).colorScheme.primary,
//           foregroundColor: Colors.white,
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 // _selectedImage != null
//                 //     ? Image.file(_selectedImage!, height: 150)
//                 //     : const Text("No Image Selected"),
//                 // const SizedBox(height: 10),
//                 // ElevatedButton(
//                 //   onPressed: _chooseImage,
//                 //   child: const Text("Choose Image"),
//                 // ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: _questiontextController,
//                   maxLines: 2,
//                   decoration: const InputDecoration(
//
//                     labelText: 'Enter Your Question',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Question is required';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   onTap: (){
//                     setState(() {
//                       _anstextController.text=_opt1textController.text;
//                     });
//                   },
//                   controller: _opt1textController,
//                   maxLines: 2,
//                   decoration: const InputDecoration(
//
//                     labelText: 'Enter Your Option1',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Option1 is required';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   onTap: (){
//                     setState(() {
//                       _anstextController.text=_opt2textController.text;
//                     });
//                   },
//                   controller: _opt2textController,
//                   maxLines: 2,
//                   decoration: const InputDecoration(
//
//                     labelText: 'Enter Your Option2',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Option2 is required';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   onTap: (){
//                     setState(() {
//                       _anstextController.text=_opt3textController.text;
//                     });
//                   },
//                   controller: _opt3textController,
//                   maxLines: 2,
//                   decoration: const InputDecoration(
//
//                     labelText: 'Enter Your Option3',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Option3 is required';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   onTap: (){
//                     setState(() {
//                       _anstextController.text=_opt4textController.text;
//                     });
//                   },
//                   controller: _opt4textController,
//                   maxLines: 2,
//                   decoration: const InputDecoration(
//
//                     labelText: 'Enter Your Option4',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Option4 is required';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   readOnly: true,
//                   controller: _anstextController,
//                   maxLines: 2,
//                   decoration: const InputDecoration(
//
//                     labelText: 'Enter Your Answer',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Answer is required';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       _sendData();
//                     } else {
//                       Fluttertoast.showToast(msg: "Please fix errors in the form");
//                     }
//                   },
//                   child: const Text("Submit"),
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size.fromHeight(50),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
