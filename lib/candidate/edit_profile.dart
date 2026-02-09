
import 'dart:convert';
import 'dart:io';
import 'package:ai_watcher/candidate/candidate_home.dart';
import 'package:ai_watcher/candidate/viewprofile.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../login.dart';

void main() {
  runApp(UserEditProfilepages(title: ''));
}

class UserEditProfilepages extends StatefulWidget {
  const UserEditProfilepages({super.key, required this.title});

  final String title;
  @override
  State<UserEditProfilepages> createState() => _UserEditProfilepagesState();
}

class _UserEditProfilepagesState extends State<UserEditProfilepages> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nametextController = TextEditingController();
  final TextEditingController _emailtextController = TextEditingController();
  final TextEditingController _phonenotextController = TextEditingController();
  final TextEditingController _placetextController = TextEditingController();
  final TextEditingController _statetextController = TextEditingController();
  final TextEditingController _citytextController = TextEditingController();
  final TextEditingController _dobtextController = TextEditingController();
  final TextEditingController _pintextController = TextEditingController();

  String gender = '';
  String photo_ = '';

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

  _UserEditProfilepagesState() {
    _get_data();
  }

  void _get_data() async {
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
          String name = jsonDecode(response.body)['name'].toString();
          String dob = jsonDecode(response.body)['dob'].toString();
          String genderr = jsonDecode(response.body)['gender'].toString();
          String email = jsonDecode(response.body)['email'].toString();
          String phone = jsonDecode(response.body)['phoneno'].toString();
          String place = jsonDecode(response.body)['place'].toString();
          String state = jsonDecode(response.body)['state'].toString();
          String pin = jsonDecode(response.body)['pin'].toString();
          String city = jsonDecode(response.body)['city'].toString();
          String photo = img + jsonDecode(response.body)['photo'].toString();

          setState(() {
            _nametextController.text = name;
            _dobtextController.text = dob;
            gender = genderr;
            _emailtextController.text = email;
            _phonenotextController.text = phone;
            _placetextController.text = place;
            _statetextController.text = state;
            _pintextController.text = pin;
            _citytextController.text = city;
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

  Future<void> _sendData() async {
    String name = _nametextController.text;
    String email = _emailtextController.text;
    String phone = _phonenotextController.text;
    String place = _placetextController.text;
    String state = _statetextController.text;
    String city = _citytextController.text;
    String dob = _dobtextController.text;
    String pin = _pintextController.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('lid').toString();

    if (url == null) {
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    final uri = Uri.parse('$url/candidateeditprofile/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['phoneno'] = phone;
    request.fields['place'] = place;
    request.fields['state'] = state;
    request.fields['city'] = city;
    request.fields['dob'] = dob;
    request.fields['pin'] = pin;

    request.fields['gender'] = gender;
    request.fields['lid'] = lid;

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
    }

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Submitted successfully.");

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserEditProfilepages(title: '',),
            ));
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E3A8A)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CandidateHome()),
              );
            },
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              color: Color(0xFF1E3A8A),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Profile Image Section
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFFE0E7FF),
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (photo_.isNotEmpty ? NetworkImage(photo_) : null) as ImageProvider?,
                        child: _selectedImage == null && photo_.isEmpty
                            ? const Icon(Icons.person, size: 60, color: Color(0xFF3B82F6))
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _chooseImage,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A8A),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Name Field
                _buildTextField(
                  controller: _nametextController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                _buildTextField(
                  controller: _emailtextController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
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
                const SizedBox(height: 16),

                // Phone Field
                _buildTextField(
                  controller: _phonenotextController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
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
                const SizedBox(height: 20),

                // Gender Selection
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.wc_outlined, color: Colors.grey[600], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Gender',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildGenderOption('Male'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGenderOption('female'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGenderOption('other'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // DOB Field
                _buildTextField(
                  controller: _dobtextController,
                  label: 'Date of Birth',
                  icon: Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 16),

                // Place Field
                _buildTextField(
                  controller: _placetextController,
                  label: 'Place',
                  icon: Icons.location_on_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Place is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // City Field
                _buildTextField(
                  controller: _citytextController,
                  label: 'City',
                  icon: Icons.location_city_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'City is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // State Field
                _buildTextField(
                  controller: _statetextController,
                  label: 'State',
                  icon: Icons.map_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'State is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // PIN Field
                _buildTextField(
                  controller: _pintextController,
                  label: 'PIN Code',
                  icon: Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'PIN is required';
                    }
                    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                      return 'Enter a valid 6-digit PIN';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Submit Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E3A8A).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _sendData();
                      } else {
                        Fluttertoast.showToast(msg: "Please fix errors in the form");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: const Color(0xFF3B82F6)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildGenderOption(String value) {
    final isSelected = gender == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          gender = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            value == 'female' ? 'Female' : value == 'other' ? 'Other' : 'Male',
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}








// import 'dart:convert';
// import 'dart:io';
// import 'package:ai_watcher/candidate/candidate_home.dart';
// import 'package:ai_watcher/candidate/viewprofile.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
//
// import '../login.dart';
//
//
//
// void main() {
//   runApp( UserEditProfilepages(title: '',));
// }
//
// class UserEditProfilepages extends StatefulWidget {
//   const UserEditProfilepages({super.key, required this.title});
//
//   final String title;
//   @override
//   State<UserEditProfilepages> createState() => _UserEditProfilepagesState();
//
// }
// class _UserEditProfilepagesState extends State<UserEditProfilepages> {
//
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   final TextEditingController _nametextController = TextEditingController();
//   final TextEditingController _emailtextController = TextEditingController();
//   final TextEditingController _phonenotextController = TextEditingController();
//   final TextEditingController _placetextController = TextEditingController();
//   final TextEditingController _statetextController = TextEditingController();
//   final TextEditingController _citytextController = TextEditingController();
//   final TextEditingController _dobtextController = TextEditingController();
//   final TextEditingController _pintextController = TextEditingController();
//
//
//   String gender = '';
//   String photo_ = '';
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
//   _UserEditProfilepagesState(){
//     _get_data();
//   }
//
//
//
//
//   void _get_data() async{
//
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String url = sh.getString('url').toString();
//     String lid = sh.getString('lid').toString();
//     String img = sh.getString('img_url') ?? '';
//
//
//     final urls = Uri.parse('$url/candidateviewprofile/');
//     try {
//       final response = await http.post(urls, body: {
//         'lid':lid
//
//       });
//       if (response.statusCode == 200) {
//         String status = jsonDecode(response.body)['status'];
//         if (status=='ok') {
//           String name=jsonDecode(response.body)['name'].toString();
//           String dob=jsonDecode(response.body)['dob'].toString();
//           String genderr=jsonDecode(response.body)['gender'].toString();
//           String email=jsonDecode(response.body)['email'].toString();
//           String phone=jsonDecode(response.body)['phoneno'].toString();
//           String place=jsonDecode(response.body)['place'].toString();
//           String state=jsonDecode(response.body)['state'].toString();
//           String pin=jsonDecode(response.body)['pin'].toString();
//           String city=jsonDecode(response.body)['city'].toString();
//           String photo=img +jsonDecode(response.body)['photo'].toString();
//
//           setState(() {
//
//             _nametextController.text= name;
//             _dobtextController.text= dob;
//             gender= genderr;
//             _emailtextController.text= email;
//             _phonenotextController.text= phone;
//             _placetextController.text= place;
//             _statetextController.text= state;
//             _pintextController.text= pin;
//             _citytextController.text= city;
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
//
//
//
//
//   Future<void> _sendData() async {
//     String name = _nametextController.text;
//     String email = _emailtextController.text;
//     String phone = _phonenotextController.text;
//     String place = _placetextController.text;
//     String state = _statetextController.text;
//     String city = _citytextController.text;
//     String dob = _dobtextController.text;
//     String pin = _pintextController.text;
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
//     final uri = Uri.parse('$url/candidateeditprofile/');
//     var request = http.MultipartRequest('POST', uri);
//     request.fields['name'] = name;
//     request.fields['email'] = email;
//     request.fields['phoneno'] = phone;
//     request.fields['place'] = place;
//     request.fields['state'] = state;
//     request.fields['city'] = city;
//     request.fields['dob'] = dob;
//     request.fields['pin'] = pin;
//
//     request.fields['gender'] = gender;
//     request.fields['lid'] = lid;
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
//
//         Navigator.push(context, MaterialPageRoute(
//           builder: (context) =>UserEditProfilepages(title: '',),));
//
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
//           MaterialPageRoute(builder: (context) => const UserEditProfilepages(title: '',)),
//         );
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Edit Profile'),
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
//                 _selectedImage != null
//                     ? Image.file(_selectedImage!, height: 150)
//                     : Image(image: NetworkImage(photo_),width: 50,),
//                 const SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: _chooseImage,
//                   child: const Text("Choose Image"),
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: _nametextController,
//                   decoration: const InputDecoration(
//                     labelText: 'Enter Your Name',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Name is required';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _emailtextController,
//                   decoration: const InputDecoration(
//                     labelText: 'Enter Your Email',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Email is required';
//                     }
//                     if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
//                       return 'Enter a valid email';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _phonenotextController,
//                   decoration: const InputDecoration(
//                     labelText: 'Enter Your Phone Number',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.phone,
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Phone number is required';
//                     }
//                     if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
//                       return 'Enter a valid 10-digit phone number';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 10),
//
//                 Row(
//                   children: [
//                     Text("Male"),
//                     Radio(
//                       value: "Male",
//                       groupValue: gender,
//                       onChanged: (value) {
//                         setState(() {
//                           gender = value.toString();
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//
//
//                 Row(
//                   children: [
//                     Text("Female"),
//                     Radio(
//                       value: "female",
//                       groupValue: gender,
//                       onChanged: (value) {
//                         setState(() {
//                           gender = value.toString();
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//
//
//                 Row(
//                   children: [
//                     Text("Other"),
//                     Radio(
//                       value: "other",
//                       groupValue: gender,
//                       onChanged: (value) {
//                         setState(() {
//                           gender = value.toString();
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _placetextController,
//                   decoration: const InputDecoration(
//                     labelText: 'Enter Your place',
//                     border: OutlineInputBorder(),
//                   ),
//                   // keyboardType: TextInputType.place,
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'place is required';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _statetextController,
//                   decoration: const InputDecoration(
//                     labelText: 'Enter Your state',
//                     border: OutlineInputBorder(),
//                   ),
//                   // keyboardType: TextInputType.phone,
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'state is required';
//                     }
//                     return null;
//                   },
//                 ),const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _citytextController,
//                   decoration: const InputDecoration(
//                     labelText: 'Enter Your city',
//                     border: OutlineInputBorder(),
//                   ),
//                   // keyboardType: TextInputType.phone,
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'city is required';
//                     }
//                     return null;
//                   },
//                 ),const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _dobtextController,
//                   decoration: const InputDecoration(
//                     labelText: 'Enter Your dob',
//                     border: OutlineInputBorder(),
//                   ),
//                   // keyboardType: TextInputType.phone,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _pintextController,
//                   decoration: const InputDecoration(
//                     labelText: 'Enter Your pin',
//                     border: OutlineInputBorder(),
//                   ),
//                   // keyboardType: TextInputType.place,
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'pin is required';
//                     }
//                     if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
//                       return 'Enter a valid pin';
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
