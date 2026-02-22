import 'package:flutter/material.dart';
import 'package:influcollb_app/core/services/third_party/instagram_service.dart';

class InstagramVerificationWidget extends StatefulWidget {
  final String? instagramUserId;
  final Function(InfluencerVerification) onVerified;

  const InstagramVerificationWidget({
    super.key,
    this.instagramUserId,
    required this.onVerified,
  });

  @override
  State<InstagramVerificationWidget> createState() =>
      _InstagramVerificationWidgetState();
}

class _InstagramVerificationWidgetState
    extends State<InstagramVerificationWidget> {
  final InstagramService _instagramService = InstagramService();
  final TextEditingController _userIdController = TextEditingController();
  bool _isVerifying = false;
  InfluencerVerification? _verification;

  @override
  void initState() {
    super.initState();
    if (widget.instagramUserId != null) {
      _userIdController.text = widget.instagramUserId!;
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _verifyInfluencer() async {
    if (_userIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Instagram User ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      // Note: User needs to set access token first
      // _instagramService.setAccessToken('YOUR_ACCESS_TOKEN');
      
      final verification = await _instagramService.verifyInfluencer(
        _userIdController.text.trim(),
      );

      setState(() {
        _verification = verification;
        _isVerifying = false;
      });

      widget.onVerified(verification);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              verification.isVerified
                  ? 'Verification successful!'
                  : 'Verification failed: ${verification.reason}',
            ),
            backgroundColor:
                verification.isVerified ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instagram Verification',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Verify your Instagram account',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: 'Instagram User ID',
                hintText: 'Enter your Instagram User ID',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isVerifying ? null : _verifyInfluencer,
                icon: _isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.verified),
                label: Text(_isVerifying ? 'Verifying...' : 'Verify Account'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            if (_verification != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _verification!.isVerified
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _verification!.isVerified
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _verification!.isVerified
                              ? Icons.check_circle
                              : Icons.warning,
                          color: _verification!.isVerified
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _verification!.isVerified
                              ? 'Verified'
                              : 'Not Verified',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _verification!.isVerified
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    if (_verification!.followersCount != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Followers: ${_verification!.followersCount}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                    if (_verification!.engagementRate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Engagement Rate: ${_verification!.engagementRate!.toStringAsFixed(2)}%',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                    if (_verification!.postsCount != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Posts: ${_verification!.postsCount}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      _verification!.reason,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Note: You need to connect your Instagram Business account and get an access token from Facebook Developer Console.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
