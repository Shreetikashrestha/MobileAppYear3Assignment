import 'package:flutter/material.dart';

class VerificationBadge extends StatelessWidget {
  final bool isVerified;
  final String? verificationType;
  final double size;

  const VerificationBadge({
    super.key,
    required this.isVerified,
    this.verificationType,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDEEBFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            color: const Color(0xFF2563EB),
            size: size,
          ),
          const SizedBox(width: 4),
          Text(
            verificationType ?? 'Verified',
            style: TextStyle(
              color: const Color(0xFF2563EB),
              fontWeight: FontWeight.bold,
              fontSize: size * 0.875,
            ),
          ),
        ],
      ),
    );
  }
}

class VerificationBadgeIcon extends StatelessWidget {
  final bool isVerified;
  final double size;

  const VerificationBadgeIcon({
    super.key,
    required this.isVerified,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const SizedBox.shrink();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}

class VerificationSection extends StatelessWidget {
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isIdentityVerified;
  final bool isSocialMediaVerified;

  const VerificationSection({
    super.key,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isIdentityVerified = false,
    this.isSocialMediaVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDEEBFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_user,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Verification Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildVerificationItem(
            'Email Address',
            isEmailVerified,
            Icons.email,
          ),
          const SizedBox(height: 12),
          _buildVerificationItem(
            'Phone Number',
            isPhoneVerified,
            Icons.phone,
          ),
          const SizedBox(height: 12),
          _buildVerificationItem(
            'Identity Document',
            isIdentityVerified,
            Icons.badge,
          ),
          const SizedBox(height: 12),
          _buildVerificationItem(
            'Social Media',
            isSocialMediaVerified,
            Icons.share,
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationItem(String label, bool isVerified, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified
              ? const Color(0xFF16A34A).withOpacity(0.2)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isVerified
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isVerified
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ),
          if (isVerified)
            const Icon(
              Icons.check_circle,
              color: Color(0xFF16A34A),
              size: 20,
            )
          else
            const Text(
              'Not Verified',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
        ],
      ),
    );
  }
}
