import 'package:flutter/material.dart';
import '../controllers/transaction_controller.dart';

class TransactionListView extends StatelessWidget {
  const TransactionListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TransactionController();

    return Scaffold(
      appBar: AppBar(title: Text("Transactions")),
      body: FutureBuilder(
        future: controller.fetchTransactions(),
        builder: (context, snapshot) {
          if (controller.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: controller.transactions.length,
            itemBuilder: (context, index) {
              final tx = controller.transactions[index];
              return ListTile(
                title: Text(tx.type.toUpperCase()),
                subtitle: Text(tx.date.toString()),
                trailing: Text("\$${tx.amount}"),
              );
            },
          );
        },
      ),
    );
  }
}
