import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/transaction_controller.dart';
import '../models/transaction_model.dart';
import '../widgets/add_transaction_modal.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  @override
  void initState() {
    super.initState();
    // Fetch transactions when view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionController>(context, listen: false).fetchTransactions();
    });
  }

  void _showAddTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return AddTransactionModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F5F9), // Light background color from design
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFinancialOverviewHeader(),
                      SizedBox(height: 20),
                      _buildOverviewCards(context),
                      SizedBox(height: 20),
                       _buildPeriodButtons(),
                      SizedBox(height: 20),
                      _buildTransactionList(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionModal(context),
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.teal,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.account_balance_wallet, color: Colors.teal, size: 24),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HisabGuru',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'AI Financial Assistant',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          Spacer(),
          _buildHeaderIcon(Icons.notifications_outlined),
          SizedBox(width: 8),
          _buildHeaderIcon(Icons.volume_up_outlined),
          SizedBox(width: 8),
          _buildHeaderIcon(Icons.person_outline),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildFinancialOverviewHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Overview',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
        ),
        Text(
          'Your financial snapshot',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildOverviewCards(BuildContext context) {
      // In a real app we might not want to listen to the whole controller here, 
      // but for simplicity we will.
      final controller = Provider.of<TransactionController>(context);
      
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildOverviewCard(
            label: 'INCOME',
            amount: controller.totalIncome,
            icon: Icons.trending_up,
            color: Colors.green,
            backgroundColor: Color(0xFFE8F5E9),
          ),
          SizedBox(width: 15),
          _buildOverviewCard(
            label: 'EXPENSE',
            amount: controller.totalExpense,
            icon: Icons.trending_down,
            color: Colors.red,
            backgroundColor: Color(0xFFFFEBEE),
          ),
          SizedBox(width: 15),
          _buildOverviewCard(
            label: 'BALANCE',
            amount: controller.balance,
            icon: Icons.account_balance_wallet,
            color: Colors.blue,
            backgroundColor: Color(0xFFE3F2FD),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required String label,
    required double amount,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      width: 140,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5))
        ]
      ),
      child: Stack(
          children: [
            Positioned(
                right: -10,
                top: -10,
                child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle
                    ),
                )
            ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    SizedBox(height: 15),
                    Text(label, style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('৳${NumberFormat('#,##0').format(amount)}', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
            )
          ],
      ),
    );
  }

   Widget _buildPeriodButtons() {
    return Row(
      children: [
        Expanded(child: _buildPeriodButton('Today', true)),
        SizedBox(width: 10),
        Expanded(child: _buildPeriodButton('Last Week', false)),
        SizedBox(width: 10),
        Expanded(child: _buildPeriodButton('Current Month', false)),
      ],
    );
  }

  Widget _buildPeriodButton(String text, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.teal : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: isSelected ? null : Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context) {
    final controller = Provider.of<TransactionController>(context);

    if (controller.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (controller.transactions.isEmpty) {
        return Container(
            width: double.infinity,
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
            ),
            child: Text("No transactions for this period", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey),)
        );
    }
    
    // Group transactions by date
    final groupedTransactions = <String, List<TransactionModel>>{};
    for (var tx in controller.transactions) {
      final dateStr = DateFormat('EEE, MMM d').format(tx.date).toUpperCase();
      if (!groupedTransactions.containsKey(dateStr)) {
        groupedTransactions[dateStr] = [];
      }
      groupedTransactions[dateStr]!.add(tx);
    }


    return Column(
      children: groupedTransactions.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                entry.key,
                style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            ...entry.value.map((tx) => _buildTransactionItem(tx)).toList(),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTransactionItem(TransactionModel tx) {
    bool isIncome = tx.type == 'income';
    Color amountColor = isIncome ? Colors.green : Colors.red;
    String sign = isIncome ? '+' : '-';

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: Offset(0, 2))
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIncome ? Icons.attach_money : Icons.money_off, // Placeholder icons
              color: amountColor,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.category,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey[900]),
                ),
                SizedBox(height: 4),
                 Row(
                   children: [
                     Text(
                      tx.note != null && tx.note!.isNotEmpty ? tx.note! : tx.account,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                                     ),
                     if (tx.note != null && tx.note!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text("• ${tx.account}", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        )
                   ],
                 ),
              ],
            ),
          ),
          Text(
            '$sign৳${tx.amount.toStringAsFixed(0)}',
            style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
