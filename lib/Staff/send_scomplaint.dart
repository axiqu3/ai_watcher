import 'dart:convert';
import 'dart:io';
import 'package:ai_watcher/Staff/view_question.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'candidate_home.dart';
import 'viewreply.dart';

void main() {
  runApp(CandidateSentReplay(title: ''));
}

// ─── Theme ────────────────────────────────────────────────────────────────────
const _primary      = Color(0xFF194569);
const _primaryLight = Color(0xFF2A6096);
const _bg           = Color(0xFFF0F4F8);
const _card         = Colors.white;
const _text         = Color(0xFF0D1F2D);
const _sub          = Color(0xFF607D8B);
const _divider      = Color(0xFFE8EEF4);
// ─────────────────────────────────────────────────────────────────────────────

class CandidateSentReplay extends StatefulWidget {
  const CandidateSentReplay({super.key, required this.title});

  final String title;

  @override
  State<CandidateSentReplay> createState() => _CandidateSentReplayState();
}

class _CandidateSentReplayState extends State<CandidateSentReplay> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _complainttextController = TextEditingController();

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
    String ucomplaint = _complainttextController.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('lid').toString();

    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    final uri = Uri.parse('$url/usersentcomplaints/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['complaint'] = ucomplaint;
    request.fields['lid'] = lid!;

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Sent Complaint successfully.");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => viewreplypage(title: '')),
        );
      } else {
        Fluttertoast.showToast(msg: "Sent Complaint failed.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const viewreplypage(title: '')),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            // ── Gradient Header ──────────────────────────────────────────
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
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const viewreplypage(title: '')),
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
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Submit Complaint',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        Text('We\'ll look into your concern',
                            style: TextStyle(fontSize: 12, color: Colors.white60)),
                      ],
                    ),
                  ),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.flag_outlined,
                        color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Info banner ──────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _primary.withOpacity(0.12)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_primary, _primaryLight],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Icon(Icons.info_outline,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Describe your issue clearly. Our team will respond as soon as possible.',
                                style: TextStyle(
                                    fontSize: 13, color: _text, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Complaint card ───────────────────────────────
                      Container(
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
                            // Card header
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _primary.withOpacity(0.03),
                                borderRadius: const BorderRadius.only(
                                  topLeft:  Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                border: const Border(
                                    bottom: BorderSide(color: _divider, width: 1)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [_primary, _primaryLight],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: const Icon(Icons.edit_note_outlined,
                                        color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Your Complaint',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: _text)),
                                ],
                              ),
                            ),

                            // Text field
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: TextFormField(
                                controller: _complainttextController,
                                maxLines: 6,
                                style: const TextStyle(
                                    fontSize: 14, color: _text, height: 1.5),
                                decoration: InputDecoration(
                                  hintText: 'Describe your complaint in detail...',
                                  hintStyle: TextStyle(
                                      color: _sub.withOpacity(0.7), fontSize: 14),
                                  filled: true,
                                  fillColor: _bg,
                                  contentPadding: const EdgeInsets.all(14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: _primary.withOpacity(0.15)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: _primary.withOpacity(0.15)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: _primary, width: 1.5),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 1.2),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 1.5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Complaint is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
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
                              Icon(Icons.send_rounded,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 10),
                              Text('Submit Complaint',
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
// import 'candidate_home.dart';
// import 'viewreply.dart';
//
//
//
// void main() {
//   runApp( CandidateSentReplay(title: '',));
// }
//
// class CandidateSentReplay extends StatefulWidget {
//   const CandidateSentReplay({super.key, required this.title});
//
//   final String title;
//   @override
//   State<CandidateSentReplay> createState() => _CandidateSentReplayState();
//
// }
// class _CandidateSentReplayState extends State<CandidateSentReplay> {
//
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _complainttextController = TextEditingController();
//
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
//     String ucomplaint = _complainttextController.text;
//
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String? url = sh.getString('url');
//     String? lid = sh.getString('lid').toString();
//
//     if (url == null) {
//       Fluttertoast.showToast(msg: "Server URL not found.");
//       return;
//     }
//
//     final uri = Uri.parse('$url/usersentcomplaints/');
//     var request = http.MultipartRequest('POST', uri);
//     request.fields['complaint'] = ucomplaint;
//     request.fields['lid'] = lid;
//
//
//     // if (_selectedImage != null) {
//     //   request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
//     // }
//
//     try {
//       var response = await request.send();
//       var respStr = await response.stream.bytesToString();
//       var data = jsonDecode(respStr);
//
//       if (response.statusCode == 200 && data['status'] == 'ok') {
//         Fluttertoast.showToast(msg: "Sent Complaint successfully.");
//         Navigator.push(context, MaterialPageRoute(builder: (context)=>viewreplypage(title: '',)));
//       } else {
//         Fluttertoast.showToast(msg: "Sent Complaint failed.");
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
//           MaterialPageRoute(builder: (context) => const viewreplypage(title: '',)),
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
//                   controller: _complainttextController,
//                   maxLines: 2,
//                   decoration: const InputDecoration(
//
//                     labelText: 'Enter Your Complaint',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Compaint is required';
//                     }
//                     return null;
//                   },
//                 ),
//
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
