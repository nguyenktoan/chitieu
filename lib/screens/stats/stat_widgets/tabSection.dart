import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../components/transaction_item.dart';
import '../../../helpers/providers/report_provider.dart';
import 'ParentCategoryList.dart';


class TabSection extends StatelessWidget {
  final TabController tabController;
  final ReportProvider reportProvider;
  final ColorScheme theme;

  const TabSection({
    Key? key,
    required this.tabController,
    required this.reportProvider,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TabBar(
            controller: tabController,
            labelColor: theme.primary,
            unselectedLabelColor: theme.outline,
            indicatorColor: theme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'Tất cả'),
              Tab(text: 'Danh mục'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          child: TabBarView(
            controller: tabController,
            children: [
              _buildTransactionsList(reportProvider),
              _buildParentCategoryList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(ReportProvider reportProvider) {
    // Kiểm tra nếu danh sách transactions là rỗng
    if (reportProvider.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon thông báo không có dữ liệu
            Icon(
              Icons.inbox,
              size: 50,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            // Thông báo không có dữ liệu
            Text(
              "Chưa có dữ liệu giao dịch",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: reportProvider.transactions.length,
        itemBuilder: (context, index) => TransactionItem(
          transaction: reportProvider.transactions[index].toMap(),
        ),
      ),
    );
  }

  Widget _buildParentCategoryList() {
    return ParentCategoryList(
      categoryAmounts: Future.value(reportProvider.categoryAmounts),
    );
  }
}
