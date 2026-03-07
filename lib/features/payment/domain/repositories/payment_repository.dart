import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/transaction_entity.dart';

abstract class IPaymentRepository {
  Future<Either<Failure, List<TransactionEntity>>> getMyTransactions();
  Future<Either<Failure, Map<String, dynamic>>> getWalletBalance(); // Returns map for simplicity or create WalletEntity
  Future<Either<Failure, TransactionEntity>> requestPayout({
    required double amount,
    required String method,
    Map<String, dynamic>? details,
  });
}
