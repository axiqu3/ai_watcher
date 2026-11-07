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

// ─── Theme ────────────────────────────────────────────────────────────────────
const _primary      = Color(0xFF194569);
const _primaryLight = Color(0xFF2A6096);
const _bg           = Color(0xFFF0F4F8);
const _card         = Colors.white;
const _text         = Color(0xFF0D1F2D);
const _sub          = Color(0xFF607D8B);
const _divider      = Color(0xFFE8EEF4);
// ─────────────────────────────────────────────────────────────────────────────

class attendexam extends StatefulWidget {
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;

  // ── NEW: duration (minutes) and attempts info ──────────────────────────────
  final int duration;       // exam duration in minutes (0 = use end time)
  final int maxAttempts;    // total allowed attempts
  final int usedAttempts;   // attempts already used
  // ──────────────────────────────────────────────────────────────────────────

  const attendexam({
    super.key,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    this.duration     = 0,
    this.maxAttempts  = 1,
    this.usedAttempts = 0,
  });

  @override
  State<attendexam> createState() => _attendexamState();
}

class _attendexamState extends State<attendexam> with WidgetsBindingObserver {

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

  Timer? _timer;
  int _remainingSeconds = 0;
  bool _examEnded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    requestMicPermission();
    initializeCamera();
    viewUsers();
    initRecorderAndStartListening();
    calculateExamDuration();
    startTimer();
  }

  void calculateExamDuration() {
    try {
      // ── If duration (in minutes) is provided, use it directly ─────────────
      if (widget.duration > 0) {
        _remainingSeconds = widget.duration * 60;
        return;
      }

      // ── Fallback: calculate from start/end date-time ───────────────────────
      DateTime startDateTime = DateTime.parse("${widget.startDate} ${widget.startTime}");
      DateTime endDateTime   = DateTime.parse("${widget.endDate} ${widget.endTime}");
      DateTime now           = DateTime.now();

      if (now.isAfter(startDateTime)) {
        _remainingSeconds = endDateTime.difference(now).inSeconds;
      } else {
        _remainingSeconds = endDateTime.difference(startDateTime).inSeconds;
      }

      if (_remainingSeconds < 0) {
        _remainingSeconds = 0;
        finishExam();
      }
    } catch (e) {
      print("Time Parse Error: $e");
    }
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() { _remainingSeconds--; });
      } else {
        timer.cancel();
        finishExam();
      }
    });
  }

  Future<void> finishExam() async {
    if (_examEnded) return;
    _examEnded = true;
    _timer?.cancel();

    try {
      if (grp.isNotEmpty) await detect();

      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url') ?? '';
      String eid = sh.getString('qeid') ?? '';
      String lid = sh.getString('lid') ?? '';

      if (url.isEmpty || eid.isEmpty || lid.isEmpty) return;

      var res = await http.post(
        Uri.parse('$url/exam_finished/'),
        body: {'eid': eid, 'lid': lid},
      );

      if (res.statusCode == 200 && mounted) {
        Fluttertoast.showToast(msg: "Exam Finished Successfully");
        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CandidateHome()),
        );
      }
    } catch (e) {
      print("Finish error: $e");
    }
  }

  Future<void> initRecorderAndStartListening() async {
    if (recorder.isRecording) return;
    try {
      if (!_recorderOpened) {
        await recorder.openRecorder();
        _recorderOpened = true;
      }
      await recorder.setSubscriptionDuration(const Duration(milliseconds: 200));
      _recorderSubscription?.cancel();
      _recorderSubscription = recorder.onProgress!.listen((event) async {
        double decibels = event.decibels ?? 0.0;
        if (decibels > 60) {
          if (_lastNoiseTime == null ||
              DateTime.now().difference(_lastNoiseTime!).inSeconds > 5) {
            _lastNoiseTime = DateTime.now();
            await notifyNoiseDetected();
          }
        }
      });
      await recorder.startRecorder(toFile: 'temp.aac', codec: Codec.aacMP4);
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
      await http.post(Uri.parse('$url/noice_Detection/'), body: {'eid': eid, 'lid': sid});
    } catch (_) {}
  }

  Future<void> requestMicPermission() async {
    if (!await Permission.microphone.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    CameraDescription frontCam = cameras!.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras!.first,
    );
    _cameraController = CameraController(frontCam, ResolutionPreset.low, enableAudio: false);
    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> viewUsers() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url  = sh.getString('url') ?? '';
    String exam = sh.getString('exam') ?? '';
    var response = await http.post(Uri.parse('$url/studentviewquestion/'), body: {'exam': exam});
    var jsonData = json.decode(response.body);
    if (jsonData['status'] == 'ok') {
      users = List<Map<String, dynamic>>.from(jsonData['data']);
      loadQuestion();
    }
  }

  void loadQuestion() {
    setState(() {
      question = users[index]['question'];
      option1  = users[index]['option1'];
      option2  = users[index]['option2'];
      option3  = users[index]['option3'];
      option4  = users[index]['option4'];
      answer   = users[index]['answer'];
      grp      = option1;
    });
  }

  Future<void> detect() async {
    if (grp.isEmpty) {
      Fluttertoast.showToast(msg: "Please select an answer");
      return;
    }
    final image = await _cameraController?.takePicture();
    if (image == null) return;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url  = sh.getString('url') ?? '';
    String exam = sh.getString('qeid') ?? '';
    String lid  = sh.getString('lid') ?? '';
    int mark    = (grp == answer) ? 1 : 0;

    var request = http.MultipartRequest('POST', Uri.parse('$url/user_addmark/'));
    request.fields['eid']    = exam;
    request.fields['lid']    = lid;
    request.fields['answer'] = grp;
    request.fields['mark']   = mark.toString();
    request.files.add(await http.MultipartFile.fromPath('photo', image.path));
    var response = await request.send();
    print("Mark API Status: ${response.statusCode}");
  }

  void nextQuestion() async {
    if (_examEnded) return;
    await detect();
    selectedAnswers.add(grp);
    if (index < users.length - 1) {
      setState(() { index++; });
      loadQuestion();
    } else {
      await finishExam();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.paused || state == AppLifecycleState.inactive) && !_appSwitched) {
      _appSwitched = true;
      _send_data();
      if (isRecorderInitialized) recorder.stopRecorder();
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
    await http.post(Uri.parse('$url/app_switching/'), body: {'lid': lid, 'eid': eid});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _timer?.cancel();
    _recorderSubscription?.cancel();
    recorder.closeRecorder();
    super.dispose();
  }

  // ─── Timer helpers ────────────────────────────────────────────────────────
  Color get _timerColor {
    if (_remainingSeconds < 60)  return Colors.red;
    if (_remainingSeconds < 300) return const Color(0xFFE67E22);
    return _primary;
  }

  String get _timerText {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Attempts helpers ───────────────────────────────────────────────────────
  int get _remainingAttempts => widget.maxAttempts - widget.usedAttempts;

  // ════════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        try {
          SharedPreferences sh = await SharedPreferences.getInstance();
          String url = sh.getString('url') ?? '';
          String eid = sh.getString('qeid') ?? '';
          String sid = sh.getString('lid') ?? '';
          if (url.isEmpty || eid.isEmpty || sid.isEmpty);
          final response = await http.post(
              Uri.parse('$url/back_action/'), body: {'eid': eid, 'lid': sid});
          if (response.statusCode == 200) {
            String status = jsonDecode(response.body)['status'];
            Fluttertoast.showToast(
                msg: status == 'ok'
                    ? 'Back action detected event sent'
                    : 'Back action detection failed');
          } else {
            Fluttertoast.showToast(msg: 'Network error during back action detection');
          }
        } catch (e) {
          Fluttertoast.showToast(msg: 'Error sending back action detection: $e');
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [

            // ══════════════════════════════════════════════════════════════
            // ── CAMERA SECTION ─────────────────────────────────────────────
            // ══════════════════════════════════════════════════════════════
            Stack(
              children: [

                // ── Full-width camera preview ──────────────────────────
                Container(
                  height: size.height * 0.36,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft:  Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft:  Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    child: _cameraController != null &&
                        _cameraController!.value.isInitialized
                        ? CameraPreview(_cameraController!)
                        : Container(
                      color: _primary,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                                color: Colors.white.withOpacity(0.6),
                                strokeWidth: 2),
                            const SizedBox(height: 10),
                            Text('Initializing camera...',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Top gradient overlay ───────────────────────────────
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft:  Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                  ),
                ),

                // ── Bottom gradient overlay ────────────────────────────
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.45),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft:  Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                  ),
                ),

                // ── Header bar (top of camera) ─────────────────────────
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1.5),
                          ),
                          child: const Icon(Icons.quiz_outlined,
                              color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Attend Exam',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.3)),
                              Text('Answer all questions carefully',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white60)),
                            ],
                          ),
                        ),
                        // Question counter badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1.5),
                          ),
                          child: Text(
                            users.isEmpty ? 'Q--' : 'Q${index + 1}/${users.length}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── REC badge ─────────────────────────────────────────
                Positioned(
                  top: 52, right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Colors.white, size: 7),
                        SizedBox(width: 4),
                        Text('REC',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1)),
                      ],
                    ),
                  ),
                ),

                // ── Bottom overlay: Timer + Duration + Attempts ────────
                Positioned(
                  bottom: 14, left: 16, right: 16,
                  child: Row(
                    children: [
                      // Timer pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _remainingSeconds < 60
                                ? Colors.redAccent.withOpacity(0.6)
                                : Colors.white.withOpacity(0.2),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _remainingSeconds < 60
                                  ? Icons.warning_amber_rounded
                                  : Icons.timer_outlined,
                              color: _remainingSeconds < 60
                                  ? Colors.redAccent
                                  : Colors.white70,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _timerText,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _remainingSeconds < 60
                                    ? Colors.redAccent
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // ── Attempts pill ──────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.repeat_rounded,
                                color: Colors.white70, size: 13),
                            const SizedBox(width: 5),
                            Text(
                              '${widget.usedAttempts + 1}/${widget.maxAttempts}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // ── Progress pill ──────────────────────────────
                      if (users.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.format_list_numbered_rounded,
                                  color: Colors.white70, size: 13),
                              const SizedBox(width: 6),
                              Text(
                                '${((index + 1) / users.length * 100).round()}% done',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // ══════════════════════════════════════════════════════════════
            // ── DURATION + ATTEMPTS INFO BAR ──────────────────────────────
            // ══════════════════════════════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  // Duration chip
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _primary.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined,
                              color: _primary, size: 15),
                          const SizedBox(width: 7),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Duration',
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: _sub,
                                      fontWeight: FontWeight.w500)),
                              Text(
                                widget.duration > 0
                                    ? '${widget.duration} mins'
                                    : 'Full period',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Attempts chip
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.green.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.repeat_rounded,
                              color: Color(0xFF2E7D32), size: 15),
                          const SizedBox(width: 7),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Attempt',
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: _sub,
                                      fontWeight: FontWeight.w500)),
                              Text(
                                '${widget.usedAttempts + 1} of ${widget.maxAttempts}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2E7D32)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Remaining attempts chip
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: _remainingAttempts <= 1
                            ? Colors.red.withOpacity(0.07)
                            : const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _remainingAttempts <= 1
                              ? Colors.red.withOpacity(0.25)
                              : Colors.orange.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _remainingAttempts <= 1
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline,
                            color: _remainingAttempts <= 1
                                ? Colors.red.shade600
                                : Colors.orange.shade700,
                            size: 15,
                          ),
                          const SizedBox(width: 7),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Remaining',
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: _sub,
                                      fontWeight: FontWeight.w500)),
                              Text(
                                '$_remainingAttempts left',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _remainingAttempts <= 1
                                        ? Colors.red.shade600
                                        : Colors.orange.shade700),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ══════════════════════════════════════════════════════════════
            // ── QUESTION + OPTIONS SECTION ────────────────────────────────
            // ══════════════════════════════════════════════════════════════
            Expanded(
              child: users.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.hourglass_empty,
                          color: _primary, size: 30),
                    ),
                    const SizedBox(height: 14),
                    const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(
                          color: _primary, strokeWidth: 2.5),
                    ),
                    const SizedBox(height: 10),
                    const Text('Loading questions...',
                        style: TextStyle(
                            fontSize: 13, color: _sub)),
                  ],
                ),
              )
                  : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Progress bar ─────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Question ${index + 1} of ${users.length}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: _sub,
                                fontWeight: FontWeight.w500)),
                        Text(
                            '${((index + 1) / users.length * 100).round()}% done',
                            style: const TextStyle(
                                fontSize: 12, color: _sub)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: users.isEmpty
                            ? 0
                            : (index + 1) / users.length,
                        backgroundColor: _primary.withOpacity(0.1),
                        valueColor:
                        const AlwaysStoppedAnimation<Color>(_primary),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Question card ─────────────────────────────
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
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_primary, _primaryLight],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('Q${index + 1}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                              ),
                              const SizedBox(width: 10),
                              const Text('Question',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: _sub,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            question,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _text,
                                height: 1.5),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Options card ──────────────────────────────
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
                          Container(
                            padding: const EdgeInsets.fromLTRB(
                                16, 14, 16, 10),
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(0.03),
                              borderRadius: const BorderRadius.only(
                                topLeft:  Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              border: const Border(
                                  bottom: BorderSide(color: _divider)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.list_alt_outlined,
                                    size: 16,
                                    color: _primary.withOpacity(0.7)),
                                const SizedBox(width: 8),
                                const Text('Select your answer',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _text)),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              children: [
                                _optionTile(option1, 'A'),
                                _optionTile(option2, 'B'),
                                _optionTile(option3, 'C'),
                                _optionTile(option4, 'D'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── Next / Finish button ──────────────────────
                    GestureDetector(
                      onTap: nextQuestion,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              index == users.length - 1
                                  ? Icons.check_circle_outline
                                  : Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              index == users.length - 1
                                  ? 'Finish Exam'
                                  : 'Next Question',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Option tile ───────────────────────────────────────────────────────────
  Widget _optionTile(String opt, String label) {
    final bool isSelected = grp == opt;
    return GestureDetector(
      onTap: () => setState(() => grp = opt),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected ? _primary.withOpacity(0.07) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primary : _divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(colors: [_primary, _primaryLight])
                    : null,
                color: isSelected ? null : _bg,
                borderRadius: BorderRadius.circular(8),
                border: isSelected ? null : Border.all(color: _divider),
              ),
              child: Center(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : _sub)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(opt,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? _primary : _text)),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: _primary, size: 18),
          ],
        ),
      ),
    );
  }

  // kept for compatibility
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