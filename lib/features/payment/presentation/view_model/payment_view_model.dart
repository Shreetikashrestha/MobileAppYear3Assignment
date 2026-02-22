import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/request_payout_usecase.dart';
import 'payment_providers.dart';

final paymentViewModelProvider = StateNotifierProvider<PaymentViewModel, AsyncValue<void>>((ref) {
  return PaymentViewModel(ref);
});

class PaymentViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  PaymentViewModel(this._ref) : super(const AsyncValue.data(null));

  Future<void> requestPayout({required double amount, required String method}) async {
    state = const AsyncValue.loading();
    try {
      final useCase = _ref.read(requestPayoutUseCaseProvider);
      final result = await useCase.call(RequestPayoutParams(amount: amount, method: method));
      
      result.fold(
        (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
        (transaction) {
           state = const AsyncValue.data(null);
           // Invalidate providers to refresh data
           _ref.refresh(myTransactionsProvider);
           _ref.refresh(walletBalanceProvider);
        },
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
