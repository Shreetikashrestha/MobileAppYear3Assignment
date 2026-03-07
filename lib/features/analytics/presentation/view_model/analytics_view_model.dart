import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/analytics/domain/entities/analytics_entity.dart';
import 'package:influcollb_app/features/analytics/domain/usecases/get_analytics_usecase.dart';

class AnalyticsState {
  final AnalyticsEntity? analytics;
  final bool isLoading;
  final String? error;

  AnalyticsState({
    this.analytics,
    this.isLoading = false,
    this.error,
  });

  AnalyticsState copyWith({
    AnalyticsEntity? analytics,
    bool? isLoading,
    String? error,
  }) {
    return AnalyticsState(
      analytics: analytics ?? this.analytics,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AnalyticsViewModel extends StateNotifier<AnalyticsState> {
  final GetAnalyticsUseCase getAnalyticsUseCase;

  AnalyticsViewModel({
    required this.getAnalyticsUseCase,
  }) : super(AnalyticsState());

  Future<void> loadAnalytics() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getAnalyticsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (analytics) {
        state = state.copyWith(
          analytics: analytics,
          isLoading: false,
          error: null,
        );
      },
    );
  }
}
