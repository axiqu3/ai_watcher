// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:camera/camera.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: AttendInterview(title: ""),
//     );
//   }
// }
//
// class AttendInterview extends StatefulWidget {
//   const AttendInterview({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<AttendInterview> createState() => _AttendInterviewState();
// }
//
// class _AttendInterviewState extends State<AttendInterview> {
//   late CameraController _controller;
//   late List<CameraDescription> cameras;
//   int index = 0; // Current question index
//   String selectedOption = ""; // Selected option
//   List id_ = [], questions_ = [], answers_ = [], option1_ = [], option2_ = [], option3_ = [], option4_ = [];
//
//   @override
//   void initState() {
//     super.initState();
//     initializeCamera();
//     getData();
//   }
//
//   Future<void> initializeCamera() async {
//     cameras = await availableCameras();
//     _controller = CameraController(cameras[1], ResolutionPreset.medium);
//
//     await _controller.initialize();
//
//     if (!mounted) return;
//
//     setState(() {});
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void getData() async {
//     List id = [], Question = [], Answer = [], option1 = [], option2 = [], option3 = [], option4 = [];
//
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String urls = sh.getString('url').toString();
//       String url = '$urls/userviewquestion/';
//
//       final response = await http.post(Uri.parse(url), body: {});
//       if (response.statusCode == 200) {
//         String status = jsonDecode(response.body)['status'];
//         if (status == 'ok') {
//           var data = jsonDecode(response.body)['data'];
//
//           for (int i = 0; i < data.length; i++) {
//             id.add(data[i]['id'].toString());
//             Question.add(data[i]['Questions'].toString());
//             Answer.add(data[i]['Answer'].toString());
//             option1.add(data[i]['option1'].toString());
//             option2.add(data[i]['option2'].toString());
//             option3.add(data[i]['option3'].toString());
//             option4.add(data[i]['option4'].toString());
//           }
//           setState(() {
//             id_ = id;
//             questions_ = Question;
//             answers_ = Answer;
//             option1_ = option1;
//             option2_ = option2;
//             option3_ = option3;
//             option4_ = option4;
//           });
//         } else {
//           Fluttertoast.showToast(msg: "Not found");
//         }
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: e.toString());
//     }
//   }
//
//   Future<void> submitAnswer() async {
//     final image = await _controller.takePicture();
//     String img = "";
//
//     await image.readAsBytes().then((value) {
//       var bytes = Uint8List.fromList(value);
//       img = base64Encode(bytes);
//     }).catchError((onError) {
//       Fluttertoast.showToast(msg: "Exception while capturing image");
//     });
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String url = sh.getString('url').toString();
//     String lid = sh.getString('lid').toString();
//
//     final urls = Uri.parse('$url/addanswer/');
//     try {
//       final response = await http.post(urls, body: {
//         'qid': id_[index],
//         'lid': lid,
//         'answer': selectedOption,
//         'canswer': answers_[index],
//         'photo': img,
//       });
//
//       if (response.statusCode == 200) {
//         String status = jsonDecode(response.body)['status'];
//         if (status == 'ok') {
//           Fluttertoast.showToast(msg: 'Answer submitted');
//         } else {
//           Fluttertoast.showToast(msg: 'Submission failed');
//         }
//       } else {
//         Fluttertoast.showToast(msg: 'Network error');
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: e.toString());
//     }
//
//     // Navigate to next question
//     if (index < questions_.length - 1) {
//       setState(() {
//         index += 1;
//         selectedOption = ""; // Reset selected option
//       });
//     } else {
//       Fluttertoast.showToast(msg: "All questions completed");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Attend Interview'),
//       ),
//       body: Stack(
//         children: [
//           // Camera Preview
//           if (_controller.value.isInitialized)
//             Positioned.fill(
//               child: CameraPreview(_controller),
//             ),
//           // Question and options
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (questions_.isNotEmpty)
//                   Text(
//                     questions_[index],
//                     style: TextStyle(
//                       fontSize: 24.0,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 SizedBox(height: 16.0),
//                 if (questions_.isNotEmpty)
//                   Column(
//                     children: [
//                       RadioListTile(
//                         title: Text(option1_[index], style: TextStyle(color: Colors.white)),
//                         value: option1_[index],
//                         groupValue: selectedOption,
//                         onChanged: (value) {
//                           setState(() {
//                             selectedOption = value.toString();
//                           });
//                         },
//                       ),
//                       RadioListTile(
//                         title: Text(option2_[index], style: TextStyle(color: Colors.white)),
//                         value: option2_[index],
//                         groupValue: selectedOption,
//                         onChanged: (value) {
//                           setState(() {
//                             selectedOption = value.toString();
//                           });
//                         },
//                       ),
//                       RadioListTile(
//                         title: Text(option3_[index], style: TextStyle(color: Colors.white)),
//                         value: option3_[index],
//                         groupValue: selectedOption,
//                         onChanged: (value) {
//                           setState(() {
//                             selectedOption = value.toString();
//                           });
//                         },
//                       ),
//                       RadioListTile(
//                         title: Text(option4_[index], style: TextStyle(color: Colors.white)),
//                         value: option4_[index],
//                         groupValue: selectedOption,
//                         onChanged: (value) {
//                           setState(() {
//                             selectedOption = value.toString();
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 SizedBox(height: 16.0),
//                 ElevatedButton(
//                   onPressed: selectedOption.isNotEmpty ? submitAnswer : null,
//                   child: Text('Next'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }






// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:camera/camera.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: AttendInterview(title: ""),
//     );
//   }
// }
//
// class AttendInterview extends StatefulWidget {
//   const AttendInterview({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<AttendInterview> createState() => _AttendInterviewState();
// }
//
// class _AttendInterviewState extends State<AttendInterview> {
//   late CameraController _controller;
//   late List<CameraDescription> cameras;
//   String currentQuestion = "";
//   int questionIndex = 1;
//
//   @override
//   void initState() {
//     super.initState();
//     initializeCamera();
//     getData();
//   }
//
//   Future<void> initializeCamera() async {
//     cameras = await availableCameras();
//     _controller = CameraController(cameras[1], ResolutionPreset.medium);
//
//     await _controller.initialize();
//
//     if (!mounted) return;
//
//     setState(() {
//       // getData();
//
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   TextEditingController addanswer=new TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flutter Page Design'),
//       ),
//       body: Stack(
//         children: [
//           // Camera Preview
//           if (_controller.value.isInitialized)
//             Positioned.fill(
//               child: CameraPreview(_controller),
//             ),
//           // Content on top of the camera feed
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   questions_[index],
//                   style: TextStyle(
//                     fontSize: 24.0,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 8.0),
//                 Expanded(
//                   child: TextField(
//                     controller:addanswer ,
//                     maxLines: null, // Allows for multiline input
//                     decoration: InputDecoration(
//                       hintText: 'Answer',
//                       hintStyle: TextStyle(color: Colors.white),
//                       border: OutlineInputBorder(),
//                       filled: true,
//                       fillColor: Colors.black.withOpacity(0.5),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 16.0),
//                 ElevatedButton(
//                   onPressed: () async {
//
//
//
//                     final image = await _controller.takePicture();
//
//                     String img= "";
//
//                     await image.readAsBytes().then((value) {
//                       var bytes = Uint8List.fromList(value);
//                       print('reading of bytes is completed');
//
//
//                       String _encodedImage = base64Encode(bytes);
//                       img= _encodedImage.toString();
//
//
//
//                       Fluttertoast.showToast(msg: "Hi");
//                     }).catchError((onError) {
//
//                       Fluttertoast.showToast(msg: "Exception");
//                       print('Exception Error while reading audio from path:' +
//                           onError.toString());
//                     });
//
//
//
//
//
//                     // String complaint=addanswer.text;
//
//
//
//                     SharedPreferences sh = await SharedPreferences.getInstance();
//                     String url = sh.getString('url').toString();
//                     String lid = sh.getString('lid').toString();
//
//                     final urls = Uri.parse('$url/addanswer/');
//                     try {
//                       final response = await http.post(urls, body: {
//                         'qid':id_[index],
//                         'lid':lid,
//                         'answer':addanswer.text,
//                         'canswer':answers_[index],
//                         'photo':img
//
//
//
//                       });
//                       if (response.statusCode == 200) {
//                         String status = jsonDecode(response.body)['status'];
//                         if (status=='ok') {
//
//                         }
//
//                         else {
//                           Fluttertoast.showToast(msg: 'Not Found');
//                         }
//                       }
//                       else {
//                         Fluttertoast.showToast(msg: 'Network Error');
//                       }
//                     }
//                     catch (e){
//                       Fluttertoast.showToast(msg: e.toString());
//                     }
//
//
//
//
//
//                     if(index< questions_.length-1) {
//                       setState(() {
//                         index = index + 1;
//                       });
//                     }
//                     else
//                     {
//                       Fluttertoast.showToast(msg: "Question completed");
//                     }
//                     // Handle button press
//                   },
//                   child: Text('Next'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   List id_ = [], questions_ = [], answers_ = [],option1_ = [],option2_ = [],option3_ = [],option4_ = [];
//
//   int index=0;
//   void getData() async {
//     List id = [], Question = [], Answer = [], option1 = [],option2 = [],option3 = [],option4 = [];
//
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String urls = sh.getString('url').toString();
//       String iurl = sh.getString('img_url').toString();
//       String url = '$urls/userviewquestion/';
//
//       final response = await http.post(Uri.parse(url), body: {});
//       if (response.statusCode == 200) {
//         print(response.body);
//         String status = jsonDecode(response.body)['status'];
//         if (status == 'ok') {
//           var data = jsonDecode(response.body)['data'];
//
//           print(data);
//
//           for (int i = 0; i < data.length; i++) {
//             id.add(data[i]['id'].toString());
//             Question.add(data[i]['Questions'].toString());
//             Answer.add(data[i]['Answer'].toString());
//             option1.add(data[i] ['option1'].toString());
//             option2.add(data[i] ['option2'].toString());
//             option3.add(data[i] ['option3'].toString());
//             option4.add(data[i] ['option4'].toString());
//
//             // CATEGORY.add(data[i]['CATEGORY'].toString());
//           }
//           setState(() {
//             id_ = id;
//             questions_ = Question;
//             answers_ = Answer;
//             option1_ = option1;
//             option2_ = option2;
//             option3_ = option3;
//             option4_ = option4;
//             // CATEGORY_ = CATEGORY;
//           });
//         } else {
//           Fluttertoast.showToast(msg: "Not found");
//         }
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: e.toString());
//     }
//   }
// }
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:camera/camera.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: AttendInterview(title: ""),
//     );
//   }
// }
//
// class AttendInterview extends StatefulWidget {
//   const AttendInterview({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<AttendInterview> createState() => _AttendInterviewState();
// }
//
// class _AttendInterviewState extends State<AttendInterview> {
//   // _AttendInterviewState(){
//   //   getData();
//   // }
//   late CameraController _controller;
//   late List<CameraDescription> cameras;
//   int index = 0; // Current question index
//   String selectedOption = ""; // Selected option
//   List id_ = [], questions_ = [], answers_ = [], option1_ = [], option2_ = [], option3_ = [], option4_ = [];
//
//   @override
//   void initState() {
//     super.initState();
//     initializeCamera();
//     getData();
//   }
//
//   Future<void> initializeCamera() async {
//     cameras = await availableCameras();
//
//     // Select the front camera (selfie view)
//     CameraDescription frontCamera = cameras.firstWhere(
//             (camera) => camera.lensDirection == CameraLensDirection.front);
//
//     _controller = CameraController(frontCamera, ResolutionPreset.medium);
//
//     await _controller.initialize();
//
//     if (!mounted) return;
//
//     setState(() {});
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void getData() async {
//     List id = [], Question = [], Answer = [], option1 = [], option2 = [], option3 = [], option4 = [];
//
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String urls = sh.getString('url').toString();
//       String url = '$urls/userviewquestion/';
//
//       final response = await http.post(Uri.parse(url), body: {});
//       if (response.statusCode == 200) {
//         String status = jsonDecode(response.body)['status'];
//         if (status == 'ok') {
//           var data = jsonDecode(response.body)['data'];
//
//           for (int i = 0; i < data.length; i++) {
//             id.add(data[i]['id'].toString());
//             Question.add(data[i]['Questions'].toString());
//             Answer.add(data[i]['Answer'].toString());
//             option1.add(data[i]['option1'].toString());
//             option2.add(data[i]['option2'].toString());
//             option3.add(data[i]['option3'].toString());
//             option4.add(data[i]['option4'].toString());
//           }
//           setState(() {
//             id_ = id;
//             questions_ = Question;
//             answers_ = Answer;
//             option1_ = option1;
//             option2_ = option2;
//             option3_ = option3;
//             option4_ = option4;
//           });
//         } else {
//           Fluttertoast.showToast(msg: "Not found");
//         }
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: e.toString());
//     }
//   }
//
//   Future<void> submitAnswer() async {
//     final image = await _controller.takePicture();
//     String img = "";
//
//     await image.readAsBytes().then((value) {
//       var bytes = Uint8List.fromList(value);
//       img = base64Encode(bytes);
//     }).catchError((onError) {
//       Fluttertoast.showToast(msg: "Exception while capturing image");
//     });
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String url = sh.getString('url').toString();
//     String lid = sh.getString('lid').toString();
//
//     final urls = Uri.parse('$url/addanswer/');
//     try {
//       final response = await http.post(urls, body: {
//         'qid': id_[index],
//         'lid': lid,
//         'answer': selectedOption,
//         'canswer': answers_[index],
//         'photo': img,
//       });
//
//       if (response.statusCode == 200) {
//         String status = jsonDecode(response.body)['status'];
//         if (status == 'ok') {
//           Fluttertoast.showToast(msg: 'Answer submitted');
//         } else {
//           Fluttertoast.showToast(msg: 'Submission failed');
//         }
//       } else {
//         Fluttertoast.showToast(msg: 'Network error');
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: e.toString());
//     }
//
//     // Navigate to next question
//     if (index < questions_.length - 1) {
//       setState(() {
//         index += 1;
//         selectedOption = ""; // Reset selected option
//       });
//     } else {
//       Fluttertoast.showToast(msg: "All questions completed");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Attend Exam'),
//       ),
//       body: Column(
//         children: [
//           // Camera Preview in the top half of the screen
//           if (_controller.value.isInitialized)
//             Container(
//               height: MediaQuery.of(context).size.height / 2, // Half of the screen height
//               child: CameraPreview(_controller),
//             ),
//
//           // Question and options in the bottom half
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (questions_.isNotEmpty)
//                     Text(
//                       questions_[index],
//                       style: TextStyle(
//                         fontSize: 24.0,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   SizedBox(height: 16.0),
//                   if (questions_.isNotEmpty)
//                     Column(
//                       children: [
//                         RadioListTile(
//                           title: Text(option1_[index]),
//                           value: option1_[index],
//                           groupValue: selectedOption,
//                           onChanged: (value) {
//                             setState(() {
//                               selectedOption = value.toString();
//                             });
//                           },
//                         ),
//                         RadioListTile(
//                           title: Text(option2_[index]),
//                           value: option2_[index],
//                           groupValue: selectedOption,
//                           onChanged: (value) {
//                             setState(() {
//                               selectedOption = value.toString();
//                             });
//                           },
//                         ),
//                         RadioListTile(
//                           title: Text(option3_[index]),
//                           value: option3_[index],
//                           groupValue: selectedOption,
//                           onChanged: (value) {
//                             setState(() {
//                               selectedOption = value.toString();
//                             });
//                           },
//                         ),
//                         RadioListTile(
//                           title: Text(option4_[index]),
//                           value: option4_[index],
//                           groupValue: selectedOption,
//                           onChanged: (value) {
//                             setState(() {
//                               selectedOption = value.toString();
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   SizedBox(height: 16.0),
//                   ElevatedButton(
//                     onPressed: selectedOption.isNotEmpty ? submitAnswer : null,
//                     child: Text('Next'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AttendInterview(title: ""),
    );
  }
}

class AttendInterview extends StatefulWidget {
  const AttendInterview({super.key, required this.title});

  final String title;

  @override
  State<AttendInterview> createState() => _AttendInterviewState();
}

class _AttendInterviewState extends State<AttendInterview> {
  late CameraController _controller;
  late List<CameraDescription> cameras;
  int index = 0; // Current question index
  String selectedOption = ""; // Selected option
  bool isLoading = true; // Indicates if data is being loaded

  List id_ = [], questions_ = [], answers_ = [], option1_ = [], option2_ = [], option3_ = [], option4_ = [];

  @override
  void initState() {
    super.initState();
    initializeCamera();
    getData();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();

    // Select the front camera (selfie view)
    CameraDescription frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front);

    _controller = CameraController(frontCamera, ResolutionPreset.medium);

    await _controller.initialize();

    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void getData() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String urls = sh.getString('url').toString();
      String eid = sh.getString('eid').toString();
      String url = '$urls/userviewquestion/';

      final response = await http.post(Uri.parse(url), body: {
        'eid':eid
      });
      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          var data = jsonDecode(response.body)['data'];

          for (int i = 0; i < data.length; i++) {
            id_.add(data[i]['id'].toString());
            questions_.add(data[i]['questions'].toString());
            answers_.add(data[i]['correct_answer'].toString());
            option1_.add(data[i]['option1'].toString());
            option2_.add(data[i]['option2'].toString());
            option3_.add(data[i]['option3'].toString());
            option4_.add(data[i]['option4'].toString());
          }
          print(questions_[index]);
        } else {
          Fluttertoast.showToast(msg: "Questions not found");
        }
      }

      setState(() {
        isLoading = false; // Data loading complete
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
      setState(() {
        isLoading = false; // Stop loading on error
      });
    }
  }

  Future<void> submitAnswer() async {
    final image = await _controller.takePicture();
    String img = "";

    await image.readAsBytes().then((value) {
      var bytes = Uint8List.fromList(value);
      img = base64Encode(bytes);
    }).catchError((onError) {
      Fluttertoast.showToast(msg: "Exception while capturing image");
    });

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    String lid = sh.getString('lid').toString();

    final urls = Uri.parse('$url/user_addmark/');
    try {
      final response = await http.post(urls, body: {
        'eid':sh.getString("eid").toString(),
        'qid': id_[index],
        'lid': lid,
        'answer': selectedOption,
        'canswer': answers_[index],
        'photo': img,
      });

      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          Fluttertoast.showToast(msg: 'Answer submitted');
        } else {
          Fluttertoast.showToast(msg: 'Submission failed');
        }
      } else {
        Fluttertoast.showToast(msg: 'Network error');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }

    // Navigate to next question
    if (index < questions_.length - 1) {
      setState(() {
        index += 1;
        selectedOption = ""; // Reset selected option
      });
    } else {
      Fluttertoast.showToast(msg: "All questions completed");
      // Navigator.push(context, MaterialPageRoute(
      //   builder: (context) => correspondingmark(title: '',),));


    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EXAM TIME'),
        backgroundColor: Colors.indigo,
      ),
      body: isLoading
          ? SingleChildScrollView(
            child: Center(
            child: CircularProgressIndicator()),
          ) // Show loading spinner
          : Column(
        children: [
          // Camera Preview in the top half of the screen
          if (_controller.value.isInitialized)
            Container(
              height: MediaQuery.of(context).size.height / 2, // Half of the screen height
              child: CameraPreview(_controller),
            ),

          // Question and options in the bottom half
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // if (questions_.isNotEmpty)
                      Text(
                        questions_[index],
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    SizedBox(height: 6.0),
                    if (questions_.isNotEmpty)
                      Column(
                        children: [
                          RadioListTile(
                            title: Text(option1_[index]),
                            value: option1_[index],
                            groupValue: selectedOption,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value.toString();
                              });
                            },
                          ),
                          RadioListTile(
                            title: Text(option2_[index]),
                            value: option2_[index],
                            groupValue: selectedOption,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value.toString();
                              });
                            },
                          ),
                          RadioListTile(
                            title: Text(option3_[index]),
                            value: option3_[index],
                            groupValue: selectedOption,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value.toString();
                              });
                            },
                          ),
                          RadioListTile(
                            title: Text(option4_[index]),
                            value: option4_[index],
                            groupValue: selectedOption,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value.toString();
                              });
                            },
                          ),
                        ],
                      ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: selectedOption.isNotEmpty ? submitAnswer : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_forward), // Next icon
                          Text('NEXT'),
                          SizedBox(width: 15), // Space between text and icon

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
