import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/core/api/api_client.dart';
import 'package:influcollb_app/core/api/api_service.dart';
import 'package:influcollb_app/core/api/api_endpoints.dart';
import 'package:influcollb_app/core/providers/core_providers.dart';

final dioProvider = Provider<Dio>((ref) {
  // Use ApiEndpoints.mediaBaseUrl which doesn't include /api
  // The datasources will add the full path like /api/campaigns
  return Dio(BaseOptions(
    baseUrl: ApiEndpoints
        .mediaBaseUrl, // Base URL without /api (dynamic based on device)
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  final sessionService = ref.watch(userSessionServiceProvider);
  final tokenService = ref.watch(tokenServiceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return ApiClient(
    dio: dio,
    userSessionService: sessionService,
    tokenService: tokenService,
    networkInfo: networkInfo,
  );
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApiService(apiClient);
});
