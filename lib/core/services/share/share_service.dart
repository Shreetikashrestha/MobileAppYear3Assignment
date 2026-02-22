import 'package:share_plus/share_plus.dart';
import 'dart:io';

/// Share Service for sharing content
class ShareService {
  /// Share campaign
  Future<void> shareCampaign({
    required String campaignId,
    required String campaignTitle,
    required String brandName,
    String? imageUrl,
  }) async {
    try {
      final text = '''
🎯 Check out this campaign on InfluCollab!

Campaign: $campaignTitle
Brand: $brandName

Join now and collaborate!
Campaign ID: $campaignId

Download InfluCollab app to apply!
''';

      await Share.share(
        text,
        subject: 'Campaign: $campaignTitle',
      );
    } catch (e) {
      print('Error sharing campaign: $e');
      rethrow;
    }
  }

  /// Share profile
  Future<void> shareProfile({
    required String userId,
    required String userName,
    required String userType,
    String? bio,
  }) async {
    try {
      final text = '''
👤 Check out $userName on InfluCollab!

Type: $userType
${bio != null ? 'Bio: $bio\n' : ''}
Connect with me on InfluCollab!

Download the app now!
''';

      await Share.share(
        text,
        subject: '$userName - InfluCollab Profile',
      );
    } catch (e) {
      print('Error sharing profile: $e');
      rethrow;
    }
  }

  /// Share application success
  Future<void> shareApplicationSuccess({
    required String campaignTitle,
    required String brandName,
  }) async {
    try {
      final text = '''
🎉 Great news! My application was accepted!

Campaign: $campaignTitle
Brand: $brandName

I'm excited to collaborate! 🚀

#InfluCollab #Collaboration #Success
''';

      await Share.share(
        text,
        subject: 'Application Accepted!',
      );
    } catch (e) {
      print('Error sharing success: $e');
      rethrow;
    }
  }

  /// Share app download link
  Future<void> shareAppDownload() async {
    try {
      final text = '''
📱 Join me on InfluCollab!

Connect brands with influencers for amazing collaborations.

🔗 Download now:
iOS: [App Store Link]
Android: [Play Store Link]

#InfluCollab #InfluencerMarketing
''';

      await Share.share(
        text,
        subject: 'Join InfluCollab',
      );
    } catch (e) {
      print('Error sharing app: $e');
      rethrow;
    }
  }

  /// Share with image
  Future<void> shareWithImage({
    required String text,
    required String imagePath,
    String? subject,
  }) async {
    try {
      final file = XFile(imagePath);
      await Share.shareXFiles(
        [file],
        text: text,
        subject: subject,
      );
    } catch (e) {
      print('Error sharing with image: $e');
      rethrow;
    }
  }

  /// Share multiple files
  Future<void> shareMultipleFiles({
    required List<String> filePaths,
    String? text,
    String? subject,
  }) async {
    try {
      final files = filePaths.map((path) => XFile(path)).toList();
      await Share.shareXFiles(
        files,
        text: text,
        subject: subject,
      );
    } catch (e) {
      print('Error sharing multiple files: $e');
      rethrow;
    }
  }

  /// Share text only
  Future<void> shareText({
    required String text,
    String? subject,
  }) async {
    try {
      await Share.share(
        text,
        subject: subject,
      );
    } catch (e) {
      print('Error sharing text: $e');
      rethrow;
    }
  }

  /// Share with result callback
  Future<ShareResult?> shareWithResult({
    required String text,
    String? subject,
  }) async {
    try {
      final result = await Share.shareWithResult(
        text,
        subject: subject,
      );
      
      if (result.status == ShareResultStatus.success) {
        print('Shared successfully');
      } else if (result.status == ShareResultStatus.dismissed) {
        print('Share dismissed');
      }
      
      return result;
    } catch (e) {
      print('Error sharing with result: $e');
      return null;
    }
  }
}
