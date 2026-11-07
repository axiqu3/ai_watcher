import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// ─── Theme (matches your app) ─────────────────────────────────────────────────
const _primary      = Color(0xFF194569);
const _primaryLight = Color(0xFF2A6096);
const _bg           = Color(0xFFF0F4F8);
const _card         = Colors.white;
const _text         = Color(0xFF0D1F2D);
const _sub          = Color(0xFF607D8B);
const _divider      = Color(0xFFE8EEF4);
const _aiPurple     = Color(0xFF6A11CB);
const _aiBlue       = Color(0xFF2575FC);
// ─────────────────────────────────────────────────────────────────────────────

class ai_question_generator extends StatefulWidget {
  const ai_question_generator({super.key, required this.title});
  final String title;

  @override
  State<ai_question_generator> createState() => _ai_question_generatorState();
}

class _ai_question_generatorState extends State<ai_question_generator>
    with TickerProviderStateMixin {

  final TextEditingController _contentController = TextEditingController();
  int _questionCount = 5;
  bool _isGenerating = false;

  // Each generated question
  List<Map<String, dynamic>> _generatedQuestions = [];

  // Which questions the user has checked
  Set<int> _selectedIndexes = {};

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // ── Call Claude API ──────────────────────────────────────────────────────
  Future<void> _generateQuestions() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter some content first.");
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedQuestions = [];
      _selectedIndexes = {};
    });

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url') ?? '';

      final uri = Uri.parse('$url/generate-ai-questions/');
      var request = http.MultipartRequest('POST', uri);
      request.fields['topic']      = content;
      request.fields['count']      = '$_questionCount';
      request.fields['difficulty'] = 'Medium';
      request.fields['api_key']    = 'AIzaSyCdJgVWVtW9P7-Nh9DvFIwqcMNa_-qwYtI'
          ''
          ''
          ''
          ''
          ''
          '';

      var res      = await request.send();
      var respStr  = await res.stream.bytesToString();
      var data     = jsonDecode(respStr);

      if (data['status'] == 'ok') {
        final List<dynamic> parsed = data['questions'];
        setState(() {
          _generatedQuestions = parsed
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
          _selectedIndexes = Set<int>.from(
              List.generate(_generatedQuestions.length, (i) => i));
        });
      } else {
        Fluttertoast.showToast(
            msg: "Error: ${data['message'] ?? 'Generation failed'}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isGenerating = false);
    }
  }
  // ── Save selected questions to backend ──────────────────────────────────
  Future<void> _saveSelectedQuestions() async {
    if (_selectedIndexes.isEmpty) {
      Fluttertoast.showToast(msg: "Please select at least one question.");
      return;
    }

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url  = sh.getString('url');
    String? exam = sh.getString('exam'); // ← this is the allocated exam id

    if (url == null || exam == null) {
      Fluttertoast.showToast(msg: "Server URL or exam not found.");
      return;
    }

    int successCount = 0;

    for (int i in _selectedIndexes) {
      final q = _generatedQuestions[i];
      try {
        final uri = Uri.parse('$url/examineraddquestion/'); // ✅ correct endpoint
        var request = http.MultipartRequest('POST', uri);
        request.fields['aid']      = exam;        // ✅ backend uses 'aid' not 'exam'
        request.fields['question'] = q['question'];
        request.fields['option1']  = q['option1'];
        request.fields['option2']  = q['option2'];
        request.fields['option3']  = q['option3'];
        request.fields['option4']  = q['option4'];
        request.fields['answer']   = q['answer'];

        var res = await request.send();
        if (res.statusCode == 200) successCount++;
      } catch (_) {}
    }

    Fluttertoast.showToast(
        msg: "$successCount question(s) saved successfully!");

    if (successCount > 0) Navigator.pop(context);
  }
  // ── Option chip widget ───────────────────────────────────────────────────
  Widget _optionChip(String letter, String text, bool isAnswer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24, height: 24,
            margin: const EdgeInsets.only(right: 8, top: 1),
            decoration: BoxDecoration(
              color: isAnswer
                  ? _primary.withOpacity(0.15)
                  : _primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                  color: isAnswer
                      ? _primary.withOpacity(0.5)
                      : _primary.withOpacity(0.15)),
            ),
            child: Center(
              child: Text(letter,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isAnswer ? _primary : _sub)),
            ),
          ),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 13,
                    color: isAnswer ? _primary : _text,
                    fontWeight:
                    isAnswer ? FontWeight.w600 : FontWeight.normal,
                    height: 1.4)),
          ),
          if (isAnswer)
            const Icon(Icons.check_circle_rounded,
                color: _primary, size: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [

          // ── Gradient Header ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 54, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_aiPurple, _aiBlue],
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
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
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
                              Text('AI Question Generator',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                              Text('Generate MCQs from your content',
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
                          child: const Icon(Icons.auto_awesome,
                              color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Content input card ──────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _divider),
                      boxShadow: [
                        BoxShadow(
                          color: _aiPurple.withOpacity(0.07),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [_aiPurple, _aiBlue]),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.article_outlined,
                                  color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 10),
                            const Text('Paste Your Content',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _text)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _contentController,
                          maxLines: 6,
                          style: const TextStyle(
                              fontSize: 13, color: _text, height: 1.5),
                          decoration: InputDecoration(
                            hintText:
                            'Paste or type your topic/paragraph here...\n\nExample: "Photosynthesis is the process by which plants use sunlight..."',
                            hintStyle: TextStyle(
                                color: _sub.withOpacity(0.6),
                                fontSize: 12,
                                height: 1.5),
                            filled: true,
                            fillColor: _bg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: _divider),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: _divider),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(color: _aiPurple),
                            ),
                            contentPadding: const EdgeInsets.all(14),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Question count selector ─────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _divider),
                      boxShadow: [
                        BoxShadow(
                          color: _aiPurple.withOpacity(0.07),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [_aiPurple, _aiBlue]),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.format_list_numbered,
                                  color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 10),
                            const Text('Number of Questions',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _text)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [5, 10].map((count) {
                            final selected = _questionCount == count;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _questionCount = count),
                                child: Container(
                                  margin: EdgeInsets.only(
                                      right: count == 5 ? 8 : 0),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: selected
                                        ? const LinearGradient(
                                        colors: [_aiPurple, _aiBlue])
                                        : null,
                                    color: selected ? null : _bg,
                                    borderRadius:
                                    BorderRadius.circular(14),
                                    border: Border.all(
                                      color: selected
                                          ? Colors.transparent
                                          : _divider,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text('$count',
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w800,
                                              color: selected
                                                  ? Colors.white
                                                  : _sub)),
                                      Text('Questions',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: selected
                                                  ? Colors.white70
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

                  // ── Generate Button ─────────────────────────────────────
                  GestureDetector(
                    onTap: _isGenerating ? null : _generateQuestions,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_aiPurple, _aiBlue],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _aiPurple.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: _isGenerating
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _pulseAnim,
                            child: const Icon(Icons.auto_awesome,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Text('Generating Questions...',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                        ],
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome,
                              color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text('Generate Questions',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),

                  // ── Generated Questions ─────────────────────────────────
                  if (_generatedQuestions.isNotEmpty) ...[
                    const SizedBox(height: 24),

                    // Header row with select-all
                    Row(
                      children: [
                        const Text('Generated Questions',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _text)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedIndexes.length ==
                                  _generatedQuestions.length) {
                                _selectedIndexes.clear();
                              } else {
                                _selectedIndexes = Set<int>.from(
                                    List.generate(
                                        _generatedQuestions.length,
                                            (i) => i));
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _aiPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: _aiPurple.withOpacity(0.3)),
                            ),
                            child: Text(
                              _selectedIndexes.length ==
                                  _generatedQuestions.length
                                  ? 'Deselect All'
                                  : 'Select All',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _aiPurple),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${_selectedIndexes.length} of ${_generatedQuestions.length} selected',
                      style: TextStyle(
                          fontSize: 12,
                          color: _sub.withOpacity(0.7)),
                    ),

                    const SizedBox(height: 12),

                    // Question cards
                    ...List.generate(_generatedQuestions.length, (index) {
                      final q = _generatedQuestions[index];
                      final isSelected = _selectedIndexes.contains(index);
                      final opts = [
                        q['option1'] ?? '',
                        q['option2'] ?? '',
                        q['option3'] ?? '',
                        q['option4'] ?? '',
                      ];
                      final labels = ['A', 'B', 'C', 'D'];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedIndexes.remove(index);
                            } else {
                              _selectedIndexes.add(index);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? _aiPurple.withOpacity(0.5)
                                  : _divider,
                              width: isSelected ? 1.8 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? _aiPurple.withOpacity(0.12)
                                    : _primary.withOpacity(0.06),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                // Question number + checkbox row
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 32, height: 32,
                                      margin: const EdgeInsets.only(
                                          right: 10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isSelected
                                              ? [_aiPurple, _aiBlue]
                                              : [_sub, _sub],
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(9),
                                      ),
                                      child: Center(
                                        child: Text('${index + 1}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight:
                                                FontWeight.w800)),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                          q['question'] ?? '',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: _text,
                                              height: 1.4)),
                                    ),
                                    const SizedBox(width: 8),
                                    AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 200),
                                      width: 24, height: 24,
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? const LinearGradient(
                                            colors: [
                                              _aiPurple,
                                              _aiBlue
                                            ])
                                            : null,
                                        color: isSelected
                                            ? null
                                            : Colors.transparent,
                                        borderRadius:
                                        BorderRadius.circular(7),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.transparent
                                              : _divider,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(Icons.check,
                                          color: Colors.white,
                                          size: 14)
                                          : null,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),
                                Divider(color: _divider, height: 1),
                                const SizedBox(height: 10),

                                // Options
                                ...List.generate(4, (i) => _optionChip(
                                  labels[i],
                                  opts[i],
                                  opts[i] == q['answer'],
                                )),

                                const SizedBox(height: 6),

                                // Answer badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _aiPurple.withOpacity(0.08),
                                        _aiBlue.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    border: Border.all(
                                        color:
                                        _aiPurple.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                          Icons.check_circle_rounded,
                                          color: _aiPurple,
                                          size: 16),
                                      const SizedBox(width: 8),
                                      const Text('Answer: ',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: _sub)),
                                      Expanded(
                                        child: Text(
                                            q['answer'] ?? '',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: _aiPurple)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Save FAB ────────────────────────────────────────────────────────
      floatingActionButton: _generatedQuestions.isNotEmpty
          ? Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_aiPurple, _aiBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _aiPurple.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _saveSelectedQuestions,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.save_alt_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Save ${_selectedIndexes.length} Question${_selectedIndexes.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
          : null,
    );
  }
}