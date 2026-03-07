import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/transaction_entity.dart';
import '../repositories/payment_repository.dart';

class RequestPayoutParams {
  final double amount;
  final String method;
  final Map<String, dynamic>? details;

  RequestPayoutParams({
    required this.amount,
    required this.method,
    this.details,
  });
}

class RequestPayoutUseCase {
  final IPaymentRepository repository;

  RequestPayoutUseCase({required this.repository});

  Future<Either<Failure, TransactionEntity>> call(RequestPayoutParams params) async {
    return repository.requestPayout(
      amount: params.amount,
      method: params.method,
      details: params.details,
    );
  }
}
