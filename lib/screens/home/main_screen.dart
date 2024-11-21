import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:chitieu/components/transaction_items/transaction_item.dart';
import 'package:chitieu/helpers/db/models/transaction_model.dart';
import 'package:chitieu/screens/add_expense/add_expense.dart';
import 'package:chitieu/screens/all_transactions/all_transactions.dart';

import '../../helpers/providers/transaction_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // Shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );

    // Load transactions when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      await transactionProvider.fetchTransactions();
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  String formatCurrency(int amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatCurrency.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Consumer<TransactionProvider>(
          builder: (context, transactionProvider, child) {
            return Stack(
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserHeader(context),
                      const SizedBox(height: 20),
                      transactionProvider.isLoading
                          ? _buildLoadingBalanceCard()
                          : _buildBalanceCard(transactionProvider),
                      const SizedBox(height: 20),
                      _buildTransactionsHeader(context),
                      const SizedBox(height: 10),
                      transactionProvider.isLoading
                          ? _buildTransactionsLoading()
                          : _buildRecentTransactionsList(
                          transactionProvider.transactions),
                    ],
                  ),
                ),
              ],
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
                  "Welcome!",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Text(
                  "Hứa Tuấn Vĩ",
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
        IconButton(
          onPressed: () {
            // TODO: Implement settings screen
          },
          icon: Icon(
            Icons.settings,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCustomShimmer(
              width: 200,
              height: 40,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCustomShimmer(
                  width: 100,
                  height: 30,
                  borderRadius: BorderRadius.circular(8),
                ),
                _buildCustomShimmer(
                  width: 100,
                  height: 30,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(TransactionProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Total Balance',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              formatCurrency(provider.totalBalance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBalanceInfoItem(
                    label: 'Income',
                    amount: provider.income,
                    color: Colors.green,
                    icon: Icons.trending_up),
                Container(height: 50, width: 1, color: Colors.white24),
                _buildBalanceInfoItem(
                    label: 'Expenses',
                    amount: provider.expense,
                    color: Colors.red,
                    icon: Icons.trending_down),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceInfoItem({
    required String label,
    required int amount,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white70.withOpacity(0.3),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white)),
            Text(
              formatCurrency(amount),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Transactions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const AllTransactionsScreen()));
          },
          child: const Text('View All'),
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
    // Lấy tối đa 5 giao dịch đầu tiên, nếu danh sách có ít hơn 5 thì sẽ lấy hết
    final limitedTransactions = transactions.take(5).toList();

    return Expanded(
      child: ListView.builder(
        itemCount: limitedTransactions.length, // Hiển thị tối đa 5 giao dịch
        itemBuilder: (context, index) {
          final transaction = limitedTransactions[index];
          return TransactionItem(transaction: transaction.toMap()); // Chuyển đổi thành Map
        },
      ),
    );
  }



  Widget _buildCustomShimmer(
      {double? width, double? height, BorderRadiusGeometry? borderRadius}) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
            color: Colors.grey.withOpacity(_shimmerAnimation.value),
          ),
        );
      },
    );
  }
}
