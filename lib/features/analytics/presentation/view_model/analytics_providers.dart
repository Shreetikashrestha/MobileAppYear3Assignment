import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/core/providers/api_provider.dart';
import 'package:influcollb_app/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:influcollb_app/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:influcollb_app/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:influcollb_app/features/analytics/domain/usecases/get_analytics_usecase.dart';
import 'package:influcollb_app/features/analytics/presentation/view_model/analytics_view_model.dart';

// Data Source Provider
final analyticsRemoteDataSourceProvider =
    Provider<IAnalyticsRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return AnalyticsRemoteDataSource(apiClient: dio);
});

// Repository Provider
final analyticsRepositoryProvider = Provider<IAnalyticsRepository>((ref) {
  final remoteDataSource = ref.read(analyticsRemoteDataSourceProvider);
  return AnalyticsRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Use Case Provider
final getAnalyticsUseCaseProvider = Provider<GetAnalyticsUseCase>((ref) {
  final repository = ref.read(analyticsRepositoryProvider);
  return GetAnalyticsUseCase(repository: repository);
});

// ViewModel Provider
final analyticsViewModelProvider =
    StateNotifierProvider<AnalyticsViewModel, AnalyticsState>((ref) {
  return AnalyticsViewModel(
    getAnalyticsUseCase: ref.read(getAnalyticsUseCaseProvider),
  );
});
