import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/failure.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/entities/transaction_entity.dart';
import '../datasources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements IPaymentRepository {
  final IPaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TransactionEntity>>> getMyTransactions() async {
    try {
      final transactions = await remoteDataSource.getMyTransactions();
      return Right(transactions);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server Error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getWalletBalance() async {
    try {
      final balance = await remoteDataSource.getWalletBalance();
      return Right(balance);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server Error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> requestPayout({
    required double amount,
    required String method,
    Map<String, dynamic>? details,
  }) async {
    try {
      final transaction = await remoteDataSource.requestPayout(
        amount: amount,
        method: method,
        details: details,
      );
      return Right(transaction);
    } on DioException catch (e) {
      debugPrint('Request Payout Error: ${e.response?.data}');
      if (e.response?.data != null && e.response!.data['message'] != null) {
        return Left(ServerFailure(e.response!.data['message']));
      }
      return Left(ServerFailure(e.message ?? 'Server Error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
