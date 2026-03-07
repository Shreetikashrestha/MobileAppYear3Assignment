import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class AnalyticsExport {
  /// Export campaign analytics to CSV
  static Future<void> exportCampaignAnalytics({
    required List<Map<String, dynamic>> campaigns,
    String? fileName,
  }) async {
    try {
      // Prepare CSV data
      final List<List<dynamic>> rows = [];

      // Add headers
      rows.add([
        'Campaign Title',
        'Category',
        'Status',
        'Budget Min (NPR)',
        'Budget Max (NPR)',
        'Applicants',
        'Deadline',
        'Location',
        'Created Date',
      ]);

      // Add data rows
      for (final campaign in campaigns) {
        rows.add([
          campaign['title'] ?? '',
          campaign['category'] ?? '',
          campaign['status'] ?? '',
          campaign['budgetMin'] ?? 0,
          campaign['budgetMax'] ?? 0,
          campaign['applicantsCount'] ?? 0,
          campaign['deadline'] != null
              ? DateFormat('yyyy-MM-dd').format(DateTime.parse(campaign['deadline']))
              : '',
          campaign['location'] ?? '',
          campaign['createdAt'] != null
              ? DateFormat('yyyy-MM-dd').format(DateTime.parse(campaign['createdAt']))
              : '',
        ]);
      }

      // Convert to CSV
      final csv = const ListToCsvConverter().convert(rows);
      final bytes = utf8.encode(csv);

      // Generate filename
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final name = fileName ?? 'campaign_analytics_$timestamp.csv';

      // Share the file
      await Share.shareXFiles(
        [
          XFile.fromData(
            Uint8List.fromList(bytes),
            name: name,
            mimeType: 'text/csv',
          ),
        ],
        subject: 'Campaign Analytics Export',
      );
    } catch (e) {
      throw Exception('Failed to export analytics: $e');
    }
  }

  /// Export application analytics to CSV
  static Future<void> exportApplicationAnalytics({
    required List<Map<String, dynamic>> applications,
    String? fileName,
  }) async {
    try {
      // Prepare CSV data
      final List<List<dynamic>> rows = [];

      // Add headers
      rows.add([
        'Campaign Title',
        'Influencer Name',
        'Influencer Email',
        'Status',
        'Applied Date',
        'Message',
      ]);

      // Add data rows
      for (final app in applications) {
        rows.add([
          app['campaignId']?['title'] ?? '',
          app['influencerId']?['fullName'] ?? '',
          app['influencerId']?['email'] ?? '',
          app['status'] ?? '',
          app['createdAt'] != null
              ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(app['createdAt']))
              : '',
          app['proposalMessage'] ?? '',
        ]);
      }

      // Convert to CSV
      final csv = const ListToCsvConverter().convert(rows);
      final bytes = utf8.encode(csv);

      // Generate filename
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final name = fileName ?? 'application_analytics_$timestamp.csv';

      // Share the file
      await Share.shareXFiles(
        [
          XFile.fromData(
            Uint8List.fromList(bytes),
            name: name,
            mimeType: 'text/csv',
          ),
        ],
        subject: 'Application Analytics Export',
      );
    } catch (e) {
      throw Exception('Failed to export analytics: $e');
    }
  }

  /// Export general stats to CSV
  static Future<void> exportGeneralStats({
    required Map<String, dynamic> stats,
    String? fileName,
  }) async {
    try {
      // Prepare CSV data
      final List<List<dynamic>> rows = [];

      // Add headers
      rows.add(['Metric', 'Value']);

      // Add data rows
      stats.forEach((key, value) {
        rows.add([
          _formatKey(key),
          value.toString(),
        ]);
      });

      // Convert to CSV
      final csv = const ListToCsvConverter().convert(rows);
      final bytes = utf8.encode(csv);

      // Generate filename
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final name = fileName ?? 'stats_export_$timestamp.csv';

      // Share the file
      await Share.shareXFiles(
        [
          XFile.fromData(
            Uint8List.fromList(bytes),
            name: name,
            mimeType: 'text/csv',
          ),
        ],
        subject: 'Statistics Export',
      );
    } catch (e) {
      throw Exception('Failed to export stats: $e');
    }
  }

  /// Format camelCase keys to readable format
  static String _formatKey(String key) {
    return key
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
