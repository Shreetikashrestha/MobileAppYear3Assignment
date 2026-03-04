import 'package:flutter/material.dart';
import 'package:influcollb_app/core/services/call/call_service.dart';

/// Call screen for voice and video calls
/// This is a placeholder UI - integrate with WebRTC/Agora/Twilio for production
class CallScreen extends StatefulWidget {
  final String conversationId;
  final String receiverId;
  final String receiverName;
  final String? receiverAvatar;
  final bool isVideoCall;

  const CallScreen({
    super.key,
    required this.conversationId,
    required this.receiverId,
    required this.receiverName,
    this.receiverAvatar,
    this.isVideoCall = false,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallService _callService = CallService();
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerOn = false;

  @override
  void initState() {
    super.initState();
    // Initialize call
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    if (widget.isVideoCall) {
      await _callService.startVideoCall(
        conversationId: widget.conversationId,
        receiverId: widget.receiverId,
        receiverName: widget.receiverName,
      );
    } else {
      await _callService.startVoiceCall(
        conversationId: widget.conversationId,
        receiverId: widget.receiverId,
        receiverName: widget.receiverName,
      );
    }
  }

  Future<void> _endCall() async {
    await _callService.endCall();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isVideoCall ? 'Video Call' : 'Voice Call',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _endCall,
                  ),
                ],
              ),
            ),
            
            // Call content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue,
                      backgroundImage: widget.receiverAvatar != null
                          ? NetworkImage(widget.receiverAvatar!)
                          : null,
                      child: widget.receiverAvatar == null
                          ? Text(
                              widget.receiverName[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 48,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 24),
                    
                    // Name
                    Text(
                      widget.receiverName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Status
                    const Text(
                      'Connecting...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Controls
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute button
                  _buildControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    onPressed: () {
                      setState(() => _isMuted = !_isMuted);
                      _callService.toggleMute(_isMuted);
                    },
                  ),
                  
                  // End call button
                  _buildControlButton(
                    icon: Icons.call_end,
                    label: 'End',
                    color: Colors.red,
                    onPressed: _endCall,
                  ),
                  
                  // Video/Speaker button
                  if (widget.isVideoCall)
                    _buildControlButton(
                      icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                      label: _isVideoEnabled ? 'Video Off' : 'Video On',
                      onPressed: () {
                        setState(() => _isVideoEnabled = !_isVideoEnabled);
                        _callService.toggleVideo(_isVideoEnabled);
                      },
                    )
                  else
                    _buildControlButton(
                      icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                      label: _isSpeakerOn ? 'Speaker Off' : 'Speaker On',
                      onPressed: () {
                        setState(() => _isSpeakerOn = !_isSpeakerOn);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color ?? Colors.white24,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 28),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
