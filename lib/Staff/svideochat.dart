import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// ─── Theme (same as login & chat) ─────────────────────────────────────────────
const _primary      = Color(0xFF194569);
const _primaryLight = Color(0xFF2A6096);
const _bg           = Color(0xFFF0F4F8);
const _text         = Color(0xFF0D1F2D);
const _sub          = Color(0xFF607D8B);
const _divider      = Color(0xFFE8EEF4);
// ─────────────────────────────────────────────────────────────────────────────

class sAgoraVideoCall extends StatefulWidget {
  const sAgoraVideoCall({Key? key}) : super(key: key);

  @override
  State<sAgoraVideoCall> createState() => _sAgoraVideoCallState();
}

class _sAgoraVideoCallState extends State<sAgoraVideoCall> {
  // In svideochat.dart — change TO this:
  final String appId       = "50a69b58403c424c9895cb8715bea7fb";
  final String token       = "007eJxTYHCZ+/6fAufTRX8LW0MKp5nIf6/0sXtgUbGG34qRyWvHzFIFBlODRDPLJFMLEwPjZBMjk2RLC0vT5CQLc0PTpNRE87Qk9aerMxsCGRluJ/QwMEIhiM/GkJiUbGhkzMAAAFEIHt4=";
  final String channelName = "abc123"; // ← same channel
  final int uid = 2;                             // proctor = 2

  late final RtcEngine _engine;
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _micMuted        = false;
  bool _cameraOff       = false;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));
    await _engine.enableVideo();
    await _engine.startPreview();

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          setState(() => _localUserJoined = true);
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (connection, remoteUid, reason) {
          setState(() => _remoteUid = null);
        },
      ),
    );

    await _engine.joinChannel(
      token: "007eJxTYHCZ+/6fAufTRX8LW0MKp5nIf6/0sXtgUbGG34qRyWvHzFIFBlODRDPLJFMLEwPjZBMjk2RLC0vT5CQLc0PTpNRE87Qk9aerMxsCGRluJ/QwMEIhiM/GkJiUbGhkzMAAAFEIHt4=",                   // ← empty for testing mode
      channelId: "abc123",
      uid: 2,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  void _toggleMic() {
    setState(() => _micMuted = !_micMuted);
    _engine.muteLocalAudioStream(_micMuted);
  }

  void _toggleCamera() {
    setState(() => _cameraOff = !_cameraOff);
    _engine.muteLocalVideoStream(_cameraOff);
  }

  void _endCall() {
    _engine.leaveChannel();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _text, // dark bg for video area
      body: Stack(
        children: [

          // ── Remote video (full screen) ────────────────────────────────
          _remoteUid != null
              ? SizedBox.expand(
            child: AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: _remoteUid),
                connection: RtcConnection(channelId: channelName),
              ),
            ),
          )
              : SizedBox.expand(
            child: Container(
              color: _text,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1.5),
                      ),
                      child: Icon(Icons.person_outline,
                          color: Colors.white.withOpacity(0.4), size: 40),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Waiting for Candidate...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Top header bar (gradient — same theme) ────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: size.height * 0.14,
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
            ),
          ),

          // ── Decorative circles top-right ──────────────────────────────
          Positioned(
            top: -40, right: -40,
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            top: 28, right: 22,
            child: Container(
              width: 55, height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            top: 45, left: -18,
            child: Container(
              width: 85, height: 85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // ── Top bar content ───────────────────────────────────────────
          SafeArea(
            child: Padding(
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

                  // Icon + title
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.25), width: 1.5),
                    ),
                    child: const Icon(Icons.videocam_outlined,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Live Proctoring',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          _remoteUid != null
                              ? 'Candidate connected'
                              : 'Connecting...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Live badge
                  Container(
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
                        Text('LIVE',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Local preview (picture-in-picture card) ───────────────────
          Positioned(
            top: size.height * 0.16,
            left: 16,
            child: Container(
              width: 110, height: 150,
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.white.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _localUserJoined
                    ? AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                )
                    : Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          ),

          // ── "You" label under pip ─────────────────────────────────────
          Positioned(
            top: size.height * 0.16 + 154,
            left: 16,
            child: SizedBox(
              width: 110,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'You',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom control bar ────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 28),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _divider),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  // Mic toggle
                  _buildControlButton(
                    icon: _micMuted
                        ? Icons.mic_off_outlined
                        : Icons.mic_outlined,
                    label: _micMuted ? 'Unmute' : 'Mute',
                    onTap: _toggleMic,
                    active: !_micMuted,
                  ),

                  // Camera toggle
                  _buildControlButton(
                    icon: _cameraOff
                        ? Icons.videocam_off_outlined
                        : Icons.videocam_outlined,
                    label: _cameraOff ? 'Cam On' : 'Cam Off',
                    onTap: _toggleCamera,
                    active: !_cameraOff,
                  ),

                  // End call button
                  GestureDetector(
                    onTap: _endCall,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFD32F2F),
                                Color(0xFFEF5350)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.call_end_rounded,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(height: 6),
                        const Text('End Call',
                            style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFD32F2F),
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),

                  // Flip camera
                  _buildControlButton(
                    icon: Icons.flip_camera_ios_outlined,
                    label: 'Flip',
                    onTap: () => _engine.switchCamera(),
                    active: true,
                  ),

                  // Speaker
                  _buildControlButton(
                    icon: Icons.volume_up_outlined,
                    label: 'Speaker',
                    onTap: () {},
                    active: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool active,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: active ? _bg : _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: active ? _divider : _primary.withOpacity(0.2),
              ),
            ),
            child: Icon(icon,
                color: active ? _primary : _sub,
                size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: active ? _text : _sub,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}