import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Theme (same as login) ────────────────────────────────────────────────────
const _primary      = Color(0xFF194569);
const _primaryLight = Color(0xFF2A6096);
const _bg           = Color(0xFFF0F4F8);
const _text         = Color(0xFF0D1F2D);
const _sub          = Color(0xFF607D8B);
const _divider      = Color(0xFFE8EEF4);
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  runApp(const MyChatApp());
}

class MyChatApp extends StatelessWidget {
  const MyChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIXam Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: _bg,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),
      home: const MyChatPage(title: 'Chat'),
    );
  }
}

class MyChatPage extends StatefulWidget {
  const MyChatPage({super.key, required this.title});
  final String title;

  @override
  State<MyChatPage> createState() => _MyChatPageState();
}

class ChatMessage {
  String messageContent;
  String messageType;
  ChatMessage({required this.messageContent, required this.messageType});
}

class _MyChatPageState extends State<MyChatPage> {
  String name = "";
  List<ChatMessage> messages = [];
  final TextEditingController te_message = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  _MyChatPageState() {
    Timer.periodic(const Duration(seconds: 2), (_) {
      view_message();
    });
  }

  Future<void> view_message() async {
    final pref = await SharedPreferences.getInstance();
    name = pref.getString("agrname").toString();

    List<ChatMessage> tempMessages = [];

    try {
      String urls = pref.getString('url').toString();
      String url = '$urls/User_viewchat/';

      var data = await http.post(Uri.parse(url), body: {
        'from_id': pref.getString("lid").toString(),
        'to_id': pref.getString("toid").toString()
      });
      var jsondata = json.decode(data.body);
      var arr = jsondata["data"];

      for (int i = 0; i < arr.length; i++) {
        if (pref.getString("lid").toString() == arr[i]['from'].toString()) {
          tempMessages.add(ChatMessage(
              messageContent: arr[i]['msg'], messageType: "sender"));
        } else {
          tempMessages.add(ChatMessage(
              messageContent: arr[i]['msg'], messageType: "receiver"));
        }
      }

      setState(() {
        name = name;
        messages = tempMessages;
      });

      // Auto-scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _sendMessage() async {
    String message = te_message.text.trim();
    if (message.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url").toString();
      String url = '$ip/User_sendchat/';

      var data = await http.post(Uri.parse(url), body: {
        'message': message,
        'from_id': pref.getString("lid").toString(),
        'to_id': pref.getString("toid").toString()
      });
      json.decode(data.body);
      te_message.clear();
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [

          // ── Decorative top gradient blob (same as login) ──────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: size.height * 0.16,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_primary, _primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),

          // ── Decorative circles (same as login) ────────────────────────
          Positioned(
            top: -40, right: -40,
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            top: 30, right: 20,
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            top: 50, left: -20,
            child: Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // ── Main content ──────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [

                // ── AppBar area ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.25), width: 1.5),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Avatar + name
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.4), width: 1.5),
                        ),
                        child: const Icon(Icons.person_outline,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isNotEmpty ? name : 'Loading...',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              'Online',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // More options
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.25), width: 1.5),
                        ),
                        child: const Icon(Icons.more_vert,
                            color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),

                // ── Messages list (card style like login card) ────────
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      color: _bg,
                    ),
                    child: messages.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(Icons.chat_bubble_outline,
                                color: _primary.withOpacity(0.4), size: 32),
                          ),
                          const SizedBox(height: 12),
                          const Text('No messages yet',
                              style: TextStyle(
                                  color: _sub, fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text('Start the conversation!',
                              style: TextStyle(
                                  color: _sub.withOpacity(0.6), fontSize: 12)),
                        ],
                      ),
                    )
                        : ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      itemBuilder: (context, index) {
                        bool isSender =
                            messages[index].messageType == "sender";
                        return _buildMessageBubble(
                            messages[index].messageContent, isSender);
                      },
                    ),
                  ),
                ),

                // ── Input bar (styled like login card) ───────────────
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _divider),
                    boxShadow: [
                      BoxShadow(
                        color: _primary.withOpacity(0.10),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Attachment button
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _primary.withOpacity(0.15)),
                          ),
                          child: Icon(Icons.attach_file_rounded,
                              color: _primary.withOpacity(0.6), size: 18),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Text field
                      Expanded(
                        child: TextField(
                          controller: te_message,
                          style: const TextStyle(
                              fontSize: 14, color: _text),
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                                color: _sub.withOpacity(0.6),
                                fontSize: 14),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Send button (gradient like login button)
                      GestureDetector(
                        onTap: _isSending ? null : _sendMessage,
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_primary, _primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _primary.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _isSending
                              ? const Center(
                            child: SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2),
                            ),
                          )
                              : const Icon(Icons.send_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isSender) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
        isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Receiver avatar
          if (!isSender) ...[
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _primary.withOpacity(0.2)),
              ),
              child: Icon(Icons.person_outline,
                  color: _primary.withOpacity(0.6), size: 16),
            ),
            const SizedBox(width: 6),
          ],

          // Bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.68,
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSender
                    ? const LinearGradient(
                  colors: [_primary, _primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: isSender ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isSender ? 18 : 4),
                  bottomRight: Radius.circular(isSender ? 4 : 18),
                ),
                border: isSender
                    ? null
                    : Border.all(color: _divider),
                boxShadow: [
                  BoxShadow(
                    color: isSender
                        ? _primary.withOpacity(0.25)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: isSender ? Colors.white : _text,
                  height: 1.4,
                ),
              ),
            ),
          ),

          // Sender avatar
          if (isSender) ...[
            const SizedBox(width: 6),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primary, _primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline,
                  color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}