import 'package:flutter/material.dart';
import 'package:influcollb_app/core/services/share/share_service.dart';

class ShareCampaignButton extends StatelessWidget {
  final String campaignId;
  final String campaignTitle;
  final String brandName;
  final String? imageUrl;
  final bool isIconButton;

  const ShareCampaignButton({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
    required this.brandName,
    this.imageUrl,
    this.isIconButton = false,
  });

  Future<void> _shareCampaign(BuildContext context) async {
    try {
      final shareService = ShareService();
      await shareService.shareCampaign(
        campaignId: campaignId,
        campaignTitle: campaignTitle,
        brandName: brandName,
        imageUrl: imageUrl,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isIconButton) {
      return IconButton(
        onPressed: () => _shareCampaign(context),
        icon: const Icon(Icons.share),
        tooltip: 'Share Campaign',
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _shareCampaign(context),
      icon: const Icon(Icons.share),
      label: const Text('Share'),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
