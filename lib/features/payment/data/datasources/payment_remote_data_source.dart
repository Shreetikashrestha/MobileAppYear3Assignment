import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/transaction_model.dart';

abstract class IPaymentRemoteDataSource {
  Future<List<TransactionModel>> getMyTransactions();
  Future<Map<String, dynamic>> getWalletBalance();
  Future<TransactionModel> requestPayout({
    required double amount,
    required String method,
    Map<String, dynamic>? details,
  });
}

class PaymentRemoteDataSource implements IPaymentRemoteDataSource {
  final ApiClient apiClient;

  PaymentRemoteDataSource({required this.apiClient});

  @override
  Future<List<TransactionModel>> getMyTransactions() async {
    final response = await apiClient.get(ApiEndpoints.myTransactions);
    final List<dynamic> data = response.data['transactions'];
    return data.map((json) => TransactionModel.fromJson(json)).toList();
  }

  @override
  Future<Map<String, dynamic>> getWalletBalance() async {
    final response = await apiClient.get(ApiEndpoints.walletBalance);
    return response.data['data'];
  }

  @override
  Future<TransactionModel> requestPayout({
    required double amount,
    required String method,
    Map<String, dynamic>? details,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.requestPayout,
      data: {
        'amount': amount,
        'method': method,
        'details': details,
      },
    );
    return TransactionModel.fromJson(response.data['transaction']);
  }
}
