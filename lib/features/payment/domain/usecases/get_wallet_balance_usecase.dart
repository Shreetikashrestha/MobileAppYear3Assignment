import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/payment_repository.dart';

class GetWalletBalanceUseCase {
  final IPaymentRepository repository;

  GetWalletBalanceUseCase({required this.repository});

  Future<Either<Failure, Map<String, dynamic>>> call() async {
    return repository.getWalletBalance();
  }
}
