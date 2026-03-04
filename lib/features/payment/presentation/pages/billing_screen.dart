import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/core/providers/core_providers.dart';
import '../view_model/payment_providers.dart';
import '../view_model/payment_view_model.dart';
import '../../domain/entities/transaction_entity.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  String? userRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  void _loadUserRole() {
    final sessionService = ref.read(userSessionServiceProvider);
    setState(() {
      userRole = sessionService.getUserRole();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing & Payments',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        elevation: 0,
      ),
      body: userRole == 'brand' ? _buildBrandView() : _buildInfluencerView(),
    );
  }

  Widget _buildBrandView() {
    final transactionsAsync = ref.watch(myTransactionsProvider);

    return transactionsAsync.when(
      data: (transactions) {
        final totalSpent = transactions
            .where((t) => t.type == 'payment' && t.status != 'failed')
            .fold(0.0, (sum, t) => sum + t.amount);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard('Total Spent',
                  'NPR ${totalSpent.toStringAsFixed(2)}', Colors.purple),
              const SizedBox(height: 20),
              const Text('Transaction History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(child: _buildTransactionList(transactions)),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildInfluencerView() {
    final walletAsync = ref.watch(walletBalanceProvider);
    final transactionsAsync = ref.watch(myTransactionsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          walletAsync.when(
            data: (wallet) {
              return Column(
                children: [
                  _buildSummaryCard(
                      'Available Balance',
                      'NPR ${wallet['currentBalance']?.toStringAsFixed(2) ?? '0.00'}',
                      Colors.green),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _buildSummaryCard(
                              'Total Earnings',
                              'NPR ${wallet['totalEarnings']?.toStringAsFixed(2) ?? '0.00'}',
                              Colors.blue,
                              small: true)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _buildSummaryCard(
                              'Pending',
                              'NPR ${wallet['pendingPayouts']?.toStringAsFixed(2) ?? '0.00'}',
                              Colors.orange,
                              small: true)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showPayoutDialog(
                          wallet['currentBalance']?.toDouble() ?? 0.0),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Request Payout',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text('Error loading wallet: $err')),
          ),
          const SizedBox(height: 30),
          const Text('Transaction History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          transactionsAsync.when(
            data: (transactions) => _buildTransactionList(transactions),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error loading transactions: $err'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color,
      {bool small = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: small ? 14 : 16)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: small ? 18 : 24)),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions found.'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final t = transactions[index];
        // Logic depends on role.
        // Brand: Payment = Debit (-), Refund = Credit (+)
        // Influencer: Payment = Credit (+), Payout = Debit (-)

        bool isPositive = false;
        if (userRole == 'brand') {
          isPositive = t.type == 'refund';
        } else {
          isPositive = t.type == 'payment';
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 0,
          color: Colors.grey[50],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPositive
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
              child: Icon(
                isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
            title: Text(t.type.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(t.description ?? t.status),
            trailing: Text(
              '${isPositive ? '+' : '-'} NPR ${t.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPayoutDialog(double maxAmount) {
    final amountController = TextEditingController();
    String method = 'Bank Transfer';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Request Payout',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (NPR)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: method,
              items: ['Bank Transfer', 'eSewa', 'Khalti']
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (val) => method = val!,
              decoration: const InputDecoration(
                  labelText: 'Payout Method', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid amount')));
                    return;
                  }
                  if (amount > maxAmount) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Insufficient balance')));
                    return;
                  }
                  Navigator.pop(context);
                  ref
                      .read(paymentViewModelProvider.notifier)
                      .requestPayout(amount: amount, method: method);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Submit Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
