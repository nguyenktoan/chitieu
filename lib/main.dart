import 'package:chitieu/helpers/providers/category_provider.dart';
import 'package:chitieu/helpers/providers/report_provider.dart';
import 'package:chitieu/helpers/providers/transaction_provider.dart';
import 'package:chitieu/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(
          create: (context) {
            final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
            final reportProvider = ReportProvider();
            reportProvider.listenToTransactions(transactionProvider); // Kết nối TransactionProvider
            return reportProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Chi Tiêu',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.light(
            surface: Colors.grey.shade100,
            onSurface: Colors.black,
            primary: const Color(0xFF00B2E7),
            secondary: const Color(0xFFE064F7),
            tertiary: const Color(0xFFFF8D6C),
            outline: Colors.grey.shade400,
          ),
        ),
        home: HomeScreen(),
      ),
    );
  }
}
