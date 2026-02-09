import 'dart:convert';
import 'dart:io';
import 'package:ai_watcher/Staff/view_question.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'staff_home.dart';



void main() {
  runApp( add_question(title: '',));
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
  final TextEditingController _opt1textController = TextEditingController();
  final TextEditingController _opt2textController = TextEditingController();
  final TextEditingController _opt3textController = TextEditingController();
  final TextEditingController _opt4textController = TextEditingController();
  final TextEditingController _anstextController = TextEditingController();

  File? _selectedImage;
  Future<void> _chooseImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
    else {
      Fluttertoast.showToast(msg: "No image selected");
    }
  }

  Future<void> _sendData() async {
    String uquestion = _questiontextController.text;
    String uopt1 = _opt1textController.text;
    String uopt2 = _opt2textController.text;
    String uopt3 = _opt3textController.text;
    String uopt4 = _opt4textController.text;
    String uans = _anstextController.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? exam = sh.getString('exam');

    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    final uri = Uri.parse('$url/examineraddquestion/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['question'] = uquestion;
    request.fields['option1'] = uopt1;
    request.fields['option2'] = uopt2;
    request.fields['option3'] = uopt3;
    request.fields['option4'] = uopt4;
    request.fields['answer'] = uans;
    request.fields['aid'] = exam.toString();

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
    }

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Submitted successfully.");
        Navigator.push(context, MaterialPageRoute(builder: (context)=>view_question(title: '',)));
      } else {
        Fluttertoast.showToast(msg: "Submission failed.");
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
          MaterialPageRoute(builder: (context) => const staff_home()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // _selectedImage != null
                //     ? Image.file(_selectedImage!, height: 150)
                //     : const Text("No Image Selected"),
                // const SizedBox(height: 10),
                // ElevatedButton(
                //   onPressed: _chooseImage,
                //   child: const Text("Choose Image"),
                // ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _questiontextController,
                  maxLines: 2,
                  decoration: const InputDecoration(

                    labelText: 'Enter Your Question',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Question is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  onTap: (){
                    setState(() {
                      _anstextController.text=_opt1textController.text;
                    });
                  },
                  controller: _opt1textController,
                  maxLines: 2,
                  decoration: const InputDecoration(

                    labelText: 'Enter Your Option1',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Option1 is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  onTap: (){
                    setState(() {
                      _anstextController.text=_opt2textController.text;
                    });
                  },
                  controller: _opt2textController,
                  maxLines: 2,
                  decoration: const InputDecoration(

                    labelText: 'Enter Your Option2',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Option2 is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  onTap: (){
                    setState(() {
                      _anstextController.text=_opt3textController.text;
                    });
                  },
                  controller: _opt3textController,
                  maxLines: 2,
                  decoration: const InputDecoration(

                    labelText: 'Enter Your Option3',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Option3 is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  onTap: (){
                    setState(() {
                      _anstextController.text=_opt4textController.text;
                    });
                  },
                  controller: _opt4textController,
                  maxLines: 2,
                  decoration: const InputDecoration(

                    labelText: 'Enter Your Option4',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Option4 is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  readOnly: true,
                  controller: _anstextController,
                  maxLines: 2,
                  decoration: const InputDecoration(

                    labelText: 'Enter Your Answer',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Answer is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _sendData();
                    } else {
                      Fluttertoast.showToast(msg: "Please fix errors in the form");
                    }
                  },
                  child: const Text("Submit"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
