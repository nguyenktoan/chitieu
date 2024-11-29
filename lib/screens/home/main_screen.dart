import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chitieu/components/balance_card.dart'; // Import BalanceCard
import 'package:chitieu/helpers/providers/transaction_provider.dart';
import 'package:chitieu/components/transaction_item.dart';
import 'package:chitieu/helpers/db/models/transaction_model.dart';
import 'package:chitieu/screens/all_transactions/all_transactions.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();

    // Tải giao dịch khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final transactionProvider =
      Provider.of<TransactionProvider>(context, listen: false);
      await transactionProvider.fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Consumer<TransactionProvider>(
          builder: (context, transactionProvider, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserHeader(context),
                  const SizedBox(height: 20),
                  transactionProvider.isLoading
                      ? _buildLoadingBalanceCard()
                      : BalanceCard(
                    totalBalance: transactionProvider.totalBalance,
                    income: transactionProvider.income,
                    expense: transactionProvider.expense,
                  ),
                  const SizedBox(height: 20),
                  _buildTransactionsHeader(context),
                  const SizedBox(height: 10),
                  transactionProvider.isLoading
                      ? _buildTransactionsLoading()
                      : _buildRecentTransactionsList(
                      transactionProvider.transactions),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade200, Colors.blue.shade400],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(
                Icons.person_outline,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Chào bạn!",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Text(
                  "Hua Tuan Vi", // Thay bằng tên người dùng động nếu cần
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
        // IconButton(
        //   onPressed: () {
        //     // TODO: Implement settings screen
        //   },
        //   icon: Icon(
        //     Icons.settings,
        //     color: Theme.of(context).colorScheme.secondary,
        //   ),
        // ),
      ],
    );
  }

  Widget _buildLoadingBalanceCard() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.grey[200],
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildTransactionsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Giao dịch gần đây',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AllTransactionsScreen(),
              ),
            );
          },
          child: const Text('Xem tất cả'),
        ),
      ],
    );
  }

  Widget _buildTransactionsLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildRecentTransactionsList(List<UserTransaction> transactions) {
    return Expanded(
      child: ListView.builder(
        itemCount: transactions.take(5).toList().length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return TransactionItem(transaction: transaction.toMap());
        },
      ),
    );
  }
}
