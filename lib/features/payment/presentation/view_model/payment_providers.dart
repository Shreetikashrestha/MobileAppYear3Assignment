import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_provider.dart';
import '../../data/datasources/payment_remote_data_source.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/usecases/get_my_transactions_usecase.dart';
import '../../domain/usecases/get_wallet_balance_usecase.dart';
import '../../domain/usecases/request_payout_usecase.dart';
import '../../domain/entities/transaction_entity.dart';

// DataSource
final paymentRemoteDataSourceProvider = Provider<IPaymentRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentRemoteDataSource(apiClient: apiClient);
});

// Repository
final paymentRepositoryProvider = Provider<IPaymentRepository>((ref) {
  final remoteDataSource = ref.watch(paymentRemoteDataSourceProvider);
  return PaymentRepositoryImpl(remoteDataSource: remoteDataSource);
});

// UseCases
final getMyTransactionsUseCaseProvider = Provider<GetMyTransactionsUseCase>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return GetMyTransactionsUseCase(repository: repository);
});

final getWalletBalanceUseCaseProvider = Provider<GetWalletBalanceUseCase>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return GetWalletBalanceUseCase(repository: repository);
});

final requestPayoutUseCaseProvider = Provider<RequestPayoutUseCase>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return RequestPayoutUseCase(repository: repository);
});

// Data Providers (for UI consumption)
final myTransactionsProvider = FutureProvider.autoDispose<List<TransactionEntity>>((ref) async {
  final useCase = ref.watch(getMyTransactionsUseCaseProvider);
  final result = await useCase.call();
  return result.fold(
    (failure) => throw failure.message,
    (transactions) => transactions,
  );
});

final walletBalanceProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final useCase = ref.watch(getWalletBalanceUseCaseProvider);
  final result = await useCase.call();
  return result.fold(
    (failure) => throw failure.message,
    (balance) => balance,
  );
});
