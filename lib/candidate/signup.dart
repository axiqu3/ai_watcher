import 'dart:convert';
import 'dart:io';
import 'package:ai_watcher/candidate/candidate_home.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../login.dart';



void main() {
  runApp( candidate_signup(title: '',));
}

class candidate_signup extends StatefulWidget {
  const candidate_signup({super.key, required this.title});

  final String title;
  @override
  State<candidate_signup> createState() => _candidate_signupState();

}
class _candidate_signupState extends State<candidate_signup> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nametextController = TextEditingController();
  final TextEditingController _emailtextController = TextEditingController();
  final TextEditingController _phonenotextController = TextEditingController();
  final TextEditingController _placetextController = TextEditingController();
  final TextEditingController _statetextController = TextEditingController();
  final TextEditingController _citytextController = TextEditingController();
  final TextEditingController _dobtextController = TextEditingController();
  final TextEditingController _pintextController = TextEditingController();
  final TextEditingController _passwordtextController = TextEditingController();
  final TextEditingController _confirmpasswordtextController = TextEditingController();

  String gender = '';

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
    String name = _nametextController.text;
    String email = _emailtextController.text;
    String phone = _phonenotextController.text;
    String place = _placetextController.text;
    String state = _statetextController.text;
    String city = _citytextController.text;
    String dob = _dobtextController.text;
    String pin = _pintextController.text;
    String password = _passwordtextController.text;
    String confirmpassword = _confirmpasswordtextController.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');

    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    final uri = Uri.parse('$url/candidatesignup/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['phoneno'] = phone;
    request.fields['place'] = place;
    request.fields['state'] = state;
    request.fields['city'] = city;
    request.fields['dob'] = dob;
    request.fields['pin'] = pin;
    request.fields['password'] = password;
    request.fields['confirmpassword'] = confirmpassword;
    request.fields['gender'] = gender;

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
    }

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Submitted successfully.");

        Navigator.push(context, MaterialPageRoute(
          builder: (context) =>login(title: '',),));

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
          MaterialPageRoute(builder: (context) => const CandidateHome()),
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
                _selectedImage != null
                    ? Image.file(_selectedImage!, height: 150)
                    : const Text("No Image Selected"),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _chooseImage,
                  child: const Text("Choose Image"),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nametextController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Your Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailtextController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Your Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phonenotextController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Your Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                      return 'Enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Text("Male"),
                    Radio(
                      value: "Male",
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value.toString();
                        });
                      },
                    ),
                  ],
                ),


                Row(
                  children: [
                    Text("Female"),
                    Radio(
                      value: "female",
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value.toString();
                        });
                      },
                    ),
                  ],
                ),


                Row(
                  children: [
                    Text("Other"),
                    Radio(
                      value: "other",
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value.toString();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _placetextController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Your place',
                    border: OutlineInputBorder(),
                  ),
                  // keyboardType: TextInputType.place,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'place is required';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 10),
                TextFormField(
                  controller: _statetextController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Your state',
                    border: OutlineInputBorder(),
                  ),
                  // keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'state is required';
                    }
                    return null;
                  },
                ),const SizedBox(height: 10),
                TextFormField(
                  controller: _citytextController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Your city',
                    border: OutlineInputBorder(),
                  ),
                  // keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'city is required';
                    }
                    return null;
                  },
                ),const SizedBox(height: 10),
                TextFormField(
                  controller: _dobtextController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Your dob',
                    border: OutlineInputBorder(),
                  ),
                  // keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _pintextController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Your pin',
                    border: OutlineInputBorder(),
                  ),
                  // keyboardType: TextInputType.place,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'pin is required';
                    }
                    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                      return 'Enter a valid pin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordtextController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Your password',
                    border: OutlineInputBorder(),
                  ),
                  // keyboardType: TextInputType.place,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _confirmpasswordtextController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Your confirmpassword',
                    border: OutlineInputBorder(),
                  ),
                  // keyboardType: TextInputType.place,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'confirmpassword is required';
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
