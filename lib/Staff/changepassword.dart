import 'dart:convert';
import 'dart:io';
import 'package:ai_watcher/Staff/view_question.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../login.dart';
import 'staff_home.dart';




class changepassword extends StatefulWidget {
  const changepassword({super.key});



  @override
  State<changepassword> createState() => _changepasswordState();

}
class _changepasswordState extends State<changepassword> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentpasswordcontroller = TextEditingController();
  final TextEditingController _newpasswordcontroller = TextEditingController();
  final TextEditingController _confirmpasswordcontroller = TextEditingController();
  

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }


  Future<void> _sendData() async {
    String currentpassword= _currentpasswordcontroller.text;
    String newpassword = _newpasswordcontroller.text;
    String confirmpassword = _confirmpasswordcontroller.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? exam = sh.getString('exam');
    String? lid = sh.getString('lid');

    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    final uri = Uri.parse('$url/app_changepassword/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['currentpassword'] = currentpassword;
    request.fields['newpassword'] = newpassword;
    request.fields['confirmpassword'] = confirmpassword;
    request.fields['lid'] = lid.toString();

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Password changed successfully.");
        Navigator.push(context, MaterialPageRoute(builder: (context)=>login(title: '',)));
      } else {
        Fluttertoast.showToast(msg: " Incorrect Password.");
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
          title: Text(""),
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
                  controller: _currentpasswordcontroller,
                  maxLines: 1,
                  decoration: const InputDecoration(

                    labelText: 'Enter Your current Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Question is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _newpasswordcontroller,
                  maxLines: 1,
                  decoration: const InputDecoration(

                    labelText: 'Enter Your New Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Question is required';
                    }
                    return null;
                  },
                ),

                TextFormField(
                  controller: _confirmpasswordcontroller,
                  maxLines: 1,
                  decoration: const InputDecoration(

                    labelText: 'Enter Your Re enter password',
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
