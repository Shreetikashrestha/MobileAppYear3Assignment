import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/transaction_entity.dart';
import '../repositories/payment_repository.dart';

class GetMyTransactionsUseCase {
  final IPaymentRepository repository;

  GetMyTransactionsUseCase({required this.repository});

  Future<Either<Failure, List<TransactionEntity>>> call() async {
    return repository.getMyTransactions();
  }
}
