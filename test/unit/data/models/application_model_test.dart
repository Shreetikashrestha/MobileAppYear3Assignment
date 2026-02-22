import 'package:flutter_test/flutter_test.dart';
import 'package:influcollb_app/features/application/data/models/application_model.dart';

void main() {
  group('ApplicationModel', () {
    final testJson = {
      '_id': 'test123',
      'campaignId': 'campaign123',
      'influencerId': 'influencer123',
      'coverLetter': 'Test cover letter',
      'proposedRate': '5000',
      'portfolioLinks': ['https://portfolio1.com', 'https://portfolio2.com'],
      'status': 'pending',
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-02T00:00:00.000Z',
    };

    final testModel = ApplicationModel(
      id: 'test123',
      campaignId: 'campaign123',
      influencerId: 'influencer123',
      coverLetter: 'Test cover letter',
      proposedRate: '5000',
      portfolioLinks: ['https://portfolio1.com', 'https://portfolio2.com'],
      status: 'pending',
      createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse('2024-01-02T00:00:00.000Z'),
    );

    test('should create ApplicationModel from JSON', () {
      // Act
      final result = ApplicationModel.fromJson(testJson);

      // Assert
      expect(result.id, 'test123');
      expect(result.campaignId, 'campaign123');
      expect(result.influencerId, 'influencer123');
      expect(result.coverLetter, 'Test cover letter');
      expect(result.proposedRate, '5000');
      expect(result.portfolioLinks.length, 2);
      expect(result.status, 'pending');
    });

    test('should convert ApplicationModel to JSON', () {
      // Act
      final result = testModel.toJson();

      // Assert
      expect(result['_id'], 'test123');
      expect(result['campaignId'], 'campaign123');
      expect(result['influencerId'], 'influencer123');
      expect(result['coverLetter'], 'Test cover letter');
      expect(result['proposedRate'], '5000');
      expect(result['portfolioLinks'], isA<List<String>>());
      expect(result['status'], 'pending');
    });

    test('should handle nested campaign object in JSON', () {
      // Arrange
      final jsonWithNestedCampaign = {
        ...testJson,
        'campaignId': {
          '_id': 'campaign123',
          'title': 'Test Campaign',
        },
      };

      // Act
      final result = ApplicationModel.fromJson(jsonWithNestedCampaign);

      // Assert
      expect(result.campaignId, 'campaign123');
      expect(result.campaign, isNotNull);
      expect(result.campaignTitle, 'Test Campaign');
    });

    test('should handle nested influencer object in JSON', () {
      // Arrange
      final jsonWithNestedInfluencer = {
        ...testJson,
        'influencerId': {
          '_id': 'influencer123',
          'fullName': 'John Doe',
        },
      };

      // Act
      final result = ApplicationModel.fromJson(jsonWithNestedInfluencer);

      // Assert
      expect(result.influencerId, 'influencer123');
      expect(result.influencer, isNotNull);
      expect(result.influencerName, 'John Doe');
    });

    test('should return correct status display', () {
      // Arrange
      final pendingApp = testModel.copyWith(status: 'pending');
      final acceptedApp = testModel.copyWith(status: 'accepted');
      final rejectedApp = testModel.copyWith(status: 'rejected');

      // Assert
      expect(pendingApp.statusDisplay, 'Pending');
      expect(acceptedApp.statusDisplay, 'Accepted');
      expect(rejectedApp.statusDisplay, 'Rejected');
    });

    test('should create copy with updated fields', () {
      // Act
      final result = testModel.copyWith(
        status: 'accepted',
        proposedRate: '6000',
      );

      // Assert
      expect(result.status, 'accepted');
      expect(result.proposedRate, '6000');
      expect(result.id, testModel.id); // Unchanged fields remain same
      expect(result.coverLetter, testModel.coverLetter);
    });

    test('should handle empty portfolio links', () {
      // Arrange
      final jsonWithoutPortfolio = {
        ...testJson,
        'portfolioLinks': null,
      };

      // Act
      final result = ApplicationModel.fromJson(jsonWithoutPortfolio);

      // Assert
      expect(result.portfolioLinks, isEmpty);
    });

    test('should handle missing optional fields', () {
      // Arrange
      final minimalJson = {
        'campaignId': 'campaign123',
        'influencerId': 'influencer123',
        'coverLetter': 'Test',
        'proposedRate': '5000',
      };

      // Act
      final result = ApplicationModel.fromJson(minimalJson);

      // Assert
      expect(result.id, isNull);
      expect(result.createdAt, isNull);
      expect(result.updatedAt, isNull);
      expect(result.portfolioLinks, isEmpty);
      expect(result.status, 'pending'); // Default value
    });
  });
}
