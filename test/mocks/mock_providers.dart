import 'package:mocktail/mocktail.dart';
import 'package:influcollb_app/core/api/api_client.dart';
import 'package:influcollb_app/features/application/data/datasources/application_remote_datasource.dart';
import 'package:influcollb_app/features/application/domain/repositories/application_repository.dart';

// Mock API Client
class MockApiClient extends Mock implements ApiClient {}

// Mock Application Data Source
class MockApplicationRemoteDataSource extends Mock
    implements IApplicationRemoteDataSource {}

// Mock Application Repository
class MockApplicationRepository extends Mock
    implements IApplicationRepository {}
