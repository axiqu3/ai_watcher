// import 'dart:async';
// import 'dart:convert';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'candidate_home.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:permission_handler/permission_handler.dart';
//
//
// class attendexam extends StatefulWidget {
//   const attendexam({super.key});
//
//   @override
//   State<attendexam> createState() => _attendexamState();
// }
//
// class _attendexamState extends State<attendexam> {
//   CameraController? _cameraController;
//   List<CameraDescription>? cameras;
//
//   List<Map<String, dynamic>> users = [];
//   List<String> selectedAnswers = [];
//   int index = 0;
//
//   String question = "";
//   String option1 = "", option2 = "", option3 = "", option4 = "";
//   String answer = "";
//   String grp = "";
//
//   FlutterSoundRecorder recorder = FlutterSoundRecorder();
//   bool isRecorderInitialized = false;
//   StreamSubscription? _recorderSubscription;
//
//
//   @override
//   void initState() {
//     super.initState();
//     initializeCamera();
//     viewUsers();
//     initRecorderAndStartListening();
//
//
//     Timer.periodic(Duration(seconds: 10), (timer) {
//
//
//
//     },);
//   }
//
//
//
//
//   Future<void> initRecorderAndStartListening() async {
//     try {
//       await recorder.openRecorder();
//       await recorder.setSubscriptionDuration(const Duration(milliseconds: 200));
//       isRecorderInitialized = true;
//
//       _recorderSubscription = recorder.onProgress!.listen((event) async {
//         double decibels = event.decibels ?? 0.0;
//         if (decibels > 60) {
//           await notifyNoiseDetected();
//         }
//       });
//
//       await recorder.startRecorder(
//         toFile: 'temp.aac',
//         codec: Codec.aacMP4,
//       );
//     } catch (e) {
//       Fluttertoast.showToast(msg: 'Recorder init error: $e');
//     }
//   }
//
//   Future<void> notifyNoiseDetected() async {
//     try {
//       SharedPreferences sh = await SharedPreferences.getInstance();
//       String url = sh.getString('url') ?? '';
//       String eid = sh.getString('qeid') ?? '';
//       String sid = sh.getString('lid') ?? '';
//
//       if (url.isEmpty || eid.isEmpty || sid.isEmpty) return;
//
//       final response = await http.post(Uri.parse('$url/noice_Detection/'), body: {
//         'eid': eid,
//         'lid': sid,
//       });
//
//       if (response.statusCode == 200) {
//         String status = jsonDecode(response.body)['status'];
//         Fluttertoast.showToast(msg: status == 'ok' ? 'Noise detected event sent' : 'Noise detection failed');
//       } else {
//         Fluttertoast.showToast(msg: 'Network error during noise detection');
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: 'Error sending noise detection: $e');
//     }
//   }
//
//   Future<void> requestMicPermission() async {
//     if (!await Permission.microphone.isGranted) {
//       await Permission.microphone.request();
//     }
//   }
//
//
//
//
//
//
//
//
//
//
//
//   Future<void> _faceDetect() async {
//
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String? url = sh.getString('url');
//     String? img = sh.getString('img_url');
//     String? lid = sh.getString('lid');
//
//     if (url == null) {
//       Fluttertoast.showToast(msg: "Server URL not found.");
//       return;
//     }
//
//     final uri = Uri.parse('$url/app_changepassword/');
//     var request = http.MultipartRequest('POST', uri);
//     request.fields['lid'] = lid.toString();
//
//     try {
//       var response = await request.send();
//       var respStr = await response.stream.bytesToString();
//       var data = jsonDecode(respStr);
//
//       if (response.statusCode == 200 && data['status'] == 'ok') {
//         Fluttertoast.showToast(msg: "Password changed successfully.");
//       } else {
//         Fluttertoast.showToast(msg: " Incorrect Password.");
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error: $e");
//     }
//   }
//
//
//   Future<void> detect() async {
//     final image = await _cameraController?.takePicture();
//
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String? url = sh.getString('url');
//     String? exam = sh.getString('qeid');
//     String? lid = sh.getString('lid');
//
//     if (url == null) return;
//
//     int mark = (grp == answer) ? 1 : 0; // ✅ CORE LOGIC
//
//     final uri = Uri.parse('$url/user_addmark/');
//     var request = http.MultipartRequest('POST', uri);
//
//     request.fields['eid'] = exam.toString();
//     request.fields['lid'] = lid.toString();
//     request.fields['answer'] = grp.toString(); // selected answer
//     request.fields['mark'] = mark.toString(); // 1 or 0
//
//     request.files.add(
//       await http.MultipartFile.fromPath('photo', image!.path),
//     );
//
//     var response = await request.send();
//     var respStr = await response.stream.bytesToString();
//     var data = jsonDecode(respStr);
//
//     if (response.statusCode == 200 && data['status'] == 'ok') {
//       Fluttertoast.showToast(msg: "Submitted successfully");
//     } else {
//       Fluttertoast.showToast(msg: "Submission failed");
//     }
//   }
//
//
//
//   Future<void> initializeCamera() async {
//     cameras = await availableCameras();
//
//     // FORCE FRONT CAMERA
//     CameraDescription frontCam = cameras!.firstWhere(
//             (cam) => cam.lensDirection == CameraLensDirection.front,
//         orElse: () => cameras!.first);
//
//     _cameraController = CameraController(
//       frontCam,
//       ResolutionPreset.low, // Reduced resolution
//       enableAudio: false,
//     );
//
//     await _cameraController!.initialize();
//     if (mounted) setState(() {});
//   }
//
//   Future<void> viewUsers() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String url = sh.getString('url') ?? '';
//     String exam = sh.getString('exam') ?? '';
//     String apiUrl = '$url/studentviewquestion/';
//
//     var response = await http.post(Uri.parse(apiUrl), body: {'exam': exam});
//     var jsonData = json.decode(response.body);
//
//     if (jsonData['status'] == 'ok') {
//       users = List<Map<String, dynamic>>.from(jsonData['data']);
//       loadQuestion();
//     }
//   }
//
//   void loadQuestion() {
//     setState(() {
//       question = users[index]['question'];
//       option1 = users[index]['option1'];
//       option2 = users[index]['option2'];
//       option3 = users[index]['option3'];
//       option4 = users[index]['option4'];
//       answer = users[index]['answer'];
//       grp = option1;
//     });
//   }
//
//   void nextQuestion() {
//
//     detect();
//     selectedAnswers.add(grp);
//
//     if (index < users.length - 1) {
//       index++;
//       loadQuestion();
//     } else {
//       Fluttertoast.showToast(msg: "Exam Completed!");
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const CandidateHome()),
//       );
//     }
//   }
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.inactive) {
//
//       _send_data();
//
//       if (isRecorderInitialized) {
//         recorder.stopRecorder();
//       }
//     }
//
//     if (state == AppLifecycleState.resumed) {
//       initRecorderAndStartListening(); // restart mic
//     }
//   }
//
//
//
//   void _send_data() async {
//     SharedPreferences sh = await SharedPreferences.getInstance();
//     String url = sh.getString('url') ?? '';
//     String lid = sh.getString('lid') ?? '';
//     String eid = sh.getString('qeid') ?? '';
//     if (url.isEmpty || lid.isEmpty || eid.isEmpty) return;
//
//     try {
//       final response = await http.post(Uri.parse('$url/app_switching/'), body: {'sid': lid, 'eid': eid});
//       if (response.statusCode == 200 && jsonDecode(response.body)['status'] == 'ok') {
//         Fluttertoast.showToast(msg: 'App switch logged. Closing exam.');
//       } else {
//         Fluttertoast.showToast(msg: 'Switch event failed');
//       }
//     } catch (e) {
//       Fluttertoast.showToast(msg: e.toString());
//     }
//   }
//
//
//
//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     _recorderSubscription?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//
//       onWillPop: () async {
//
//         try {
//           SharedPreferences sh = await SharedPreferences.getInstance();
//           String url = sh.getString('url') ?? '';
//           String eid = sh.getString('qeid') ?? '';
//           String sid = sh.getString('lid') ?? '';
//
//           if (url.isEmpty || eid.isEmpty || sid.isEmpty) ;
//
//           final response = await http.post(Uri.parse('$url/back_action/'), body: {
//             'eid': eid,
//             'lid': sid,
//           });
//
//           if (response.statusCode == 200) {
//             String status = jsonDecode(response.body)['status'];
//             Fluttertoast.showToast(msg: status == 'ok' ? 'Back action detected event sent' : 'Back action detection failed');
//           } else {
//             Fluttertoast.showToast(msg: 'Network error during back action detection');
//           }
//         } catch (e) {
//           Fluttertoast.showToast(msg: 'Error sending back action detection: $e');
//         }
//
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("Attend Exam"),
//           backgroundColor: Theme.of(context).colorScheme.primary,
//           foregroundColor: Colors.white,
//           centerTitle: true,
//         ),
//
//         body: Column(
//           children: [
//             SizedBox(
//               height: 150, // 🔹 Reduced camera size
//               width: 200,
//               child: _cameraController != null &&
//                   _cameraController!.value.isInitialized
//                   ? Transform(
//                 alignment: Alignment.center,
//                 transform: Matrix4.rotationY(3.14159), // 🔹 Fix Mirror Reverse
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: CameraPreview(_cameraController!),
//                 ),
//               )
//                   : const Center(child: CircularProgressIndicator()),
//             ),
//
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Q${index + 1}. $question",
//                       style: const TextStyle(
//                           fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 18),
//
//                     optionButton(option1),
//                     optionButton(option2),
//                     optionButton(option3),
//                     optionButton(option4),
//
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: nextQuestion,
//                       style: ElevatedButton.styleFrom(
//                           minimumSize: const Size.fromHeight(50)),
//                       child: Text(index == users.length - 1
//                           ? "Finish"
//                           : "Next"),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget optionButton(String opt) {
//     return Row(
//       children: [
//         Radio(
//           value: opt,
//           groupValue: grp,
//           onChanged: (value) {
//             setState(() => grp = value.toString());
//           },
//
//         ),
//         Text(opt),
//       ],
//     );
//   }
// }
//
//


import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'candidate_home.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class attendexam extends StatefulWidget {
  const attendexam({super.key});

  @override
  State<attendexam> createState() => _attendexamState();
}

class _attendexamState extends State<attendexam>
    with WidgetsBindingObserver {

  CameraController? _cameraController;
  List<CameraDescription>? cameras;

  List<Map<String, dynamic>> users = [];
  List<String> selectedAnswers = [];
  int index = 0;

  String question = "";
  String option1 = "", option2 = "", option3 = "", option4 = "";
  String answer = "";
  String grp = "";

  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  bool isRecorderInitialized = false;
  StreamSubscription? _recorderSubscription;

  bool _appSwitched = false;
  DateTime? _lastNoiseTime;

  bool _recorderOpened = false;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    requestMicPermission();
    initializeCamera();
    viewUsers();
    initRecorderAndStartListening();
  }

  // ------------------ NOISE DETECTION ------------------

  Future<void> initRecorderAndStartListening() async {
    if (recorder.isRecording) return;

    try {
      if (!_recorderOpened) {
        await recorder.openRecorder();
        _recorderOpened = true;
      }

      await recorder.setSubscriptionDuration(
        const Duration(milliseconds: 200),
      );

      _recorderSubscription?.cancel();
      _recorderSubscription = recorder.onProgress!.listen((event) async {
        double decibels = event.decibels ?? 0.0;

        if (decibels > 60) {
          if (_lastNoiseTime == null ||
              DateTime.now()
                  .difference(_lastNoiseTime!)
                  .inSeconds >
                  5) {
            _lastNoiseTime = DateTime.now();
            await notifyNoiseDetected();
          }
        }
      });

      await recorder.startRecorder(
        toFile: 'temp.aac',
        codec: Codec.aacMP4,
      );

      isRecorderInitialized = true;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Recorder error: $e');
    }
  }

  Future<void> notifyNoiseDetected() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url') ?? '';
      String eid = sh.getString('qeid') ?? '';
      String sid = sh.getString('lid') ?? '';

      if (url.isEmpty || eid.isEmpty || sid.isEmpty) return;

      await http.post(
        Uri.parse('$url/noice_Detection/'),
        body: {'eid': eid, 'lid': sid},
      );
    } catch (_) {}
  }

  Future<void> requestMicPermission() async {
    if (!await Permission.microphone.isGranted) {
      await Permission.microphone.request();
    }
  }

  // ------------------ CAMERA ------------------

  Future<void> initializeCamera() async {
    cameras = await availableCameras();

    CameraDescription frontCam = cameras!.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras!.first,
    );

    _cameraController = CameraController(
      frontCam,
      ResolutionPreset.low,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  // ------------------ QUESTIONS ------------------

  Future<void> viewUsers() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url') ?? '';
    String exam = sh.getString('exam') ?? '';

    var response = await http.post(
      Uri.parse('$url/studentviewquestion/'),
      body: {'exam': exam},
    );

    var jsonData = json.decode(response.body);
    if (jsonData['status'] == 'ok') {
      users = List<Map<String, dynamic>>.from(jsonData['data']);
      loadQuestion();
    }
  }

  void loadQuestion() {
    setState(() {
      question = users[index]['question'];
      option1 = users[index]['option1'];
      option2 = users[index]['option2'];
      option3 = users[index]['option3'];
      option4 = users[index]['option4'];
      answer = users[index]['answer'];
      grp = option1;
    });
  }

  Future<void> detect() async {
    final image = await _cameraController?.takePicture();

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url') ?? '';
    String exam = sh.getString('qeid') ?? '';
    String lid = sh.getString('lid') ?? '';

    int mark = (grp == answer) ? 1 : 0;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$url/user_addmark/'),
    );

    request.fields['eid'] = exam;
    request.fields['lid'] = lid;
    request.fields['answer'] = grp;
    request.fields['mark'] = mark.toString();

    request.files.add(
      await http.MultipartFile.fromPath('photo', image!.path),
    );

    await request.send();
  }

  void nextQuestion() {
    detect();
    selectedAnswers.add(grp);

    if (index < users.length - 1) {
      index++;
      loadQuestion();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CandidateHome()),
      );
    }
  }

  // ------------------ APP SWITCH DETECTION ------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) &&
        !_appSwitched) {

      _appSwitched = true;
      _send_data();

      if (isRecorderInitialized) {
        recorder.stopRecorder();
      }
    }

    if (state == AppLifecycleState.resumed) {
      _appSwitched = false;
      initRecorderAndStartListening();
    }
  }

  void _send_data() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url') ?? '';
    String lid = sh.getString('lid') ?? '';
    String eid = sh.getString('qeid') ?? '';

    if (url.isEmpty || lid.isEmpty || eid.isEmpty) return;

    await http.post(
      Uri.parse('$url/app_switching/'),
      body: {'lid': lid, 'eid': eid},
    );
  }

  // ------------------ UI ------------------

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _recorderSubscription?.cancel();
    recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try {
          SharedPreferences sh = await SharedPreferences.getInstance();
          String url = sh.getString('url') ?? '';
          String eid = sh.getString('qeid') ?? '';
          String sid = sh.getString('lid') ?? '';

          if (url.isEmpty || eid.isEmpty || sid.isEmpty) ;

          final response = await http.post(Uri.parse('$url/back_action/'), body: {
            'eid': eid,
            'lid': sid,
          });

          if (response.statusCode == 200) {
            String status = jsonDecode(response.body)['status'];
            Fluttertoast.showToast(msg: status == 'ok' ? 'Back action detected event sent' : 'Back action detection failed');
          } else {
            Fluttertoast.showToast(msg: 'Network error during back action detection');
          }
        } catch (e) {
          Fluttertoast.showToast(msg: 'Error sending back action detection: $e');
        }

        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Attend Exam")),
        body: Column(
          children: [
            SizedBox(
              height: 150,
              width: 200,
              child: _cameraController != null &&
                  _cameraController!.value.isInitialized
                  ? CameraPreview(_cameraController!)
                  : const Center(child: CircularProgressIndicator()),
            ),
            Expanded(
              child: Column(
                children: [
                  Text("Q${index + 1}. $question"),
                  optionButton(option1),
                  optionButton(option2),
                  optionButton(option3),
                  optionButton(option4),
                  ElevatedButton(
                    onPressed: nextQuestion,
                    child: Text(
                      index == users.length - 1 ? "Finish" : "Next",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget optionButton(String opt) {
    return Row(
      children: [
        Radio(
          value: opt,
          groupValue: grp,
          onChanged: (v) => setState(() => grp = v.toString()),
        ),
        Text(opt),
      ],
    );
  }
}

