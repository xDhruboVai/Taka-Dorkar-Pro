import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/account_controller.dart';
import '../models/transaction_model.dart';
import '../models/account_model.dart';
import '../widgets/add_transaction_modal.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  String _selectedPeriod = 'Monthly';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthController>(context, listen: false);
      if (auth.currentUser != null) {
        String? userId = auth.currentUser?.id;
        if (userId != null) {
          Provider.of<TransactionController>(
            context,
            listen: false,
          ).fetchTransactions(userId);
          Provider.of<AccountController>(
            context,
            listen: false,
          ).fetchAccounts();
        }
      }
    });
  }

  void _showAddTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddTransactionModal(),
      ),
    );
  }

  List<TransactionModel> _getFilteredTransactions(
    List<TransactionModel> allTransactions,
  ) {
    final now = DateTime.now();
    return allTransactions.where((t) {
      final tDate = t.date.toLocal();
      if (_selectedPeriod == 'Daily') {
        return tDate.year == now.year &&
            tDate.month == now.month &&
            tDate.day == now.day;
      } else if (_selectedPeriod == 'Weekly') {
        final difference = now.difference(tDate).inDays;
        return difference >= 0 && difference < 7;
      } else {
        return tDate.year == now.year && tDate.month == now.month;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<TransactionController>(context);
    final accountController = Provider.of<AccountController>(
      context,
    ); // Listen to account changes
    final authController = Provider.of<AuthController>(context);
    final user = authController.currentUser;

    final allTransactions = controller.transactions;
    final filteredTransactions = _getFilteredTransactions(allTransactions);

    // Calculate totals for the FILTERED list
    double totalIncome = filteredTransactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    double totalExpense = filteredTransactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
    // Note: Main balance is now from AccountController, not calculated here

    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionModal(context),
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 360;
            final headerPadding = EdgeInsets.all(isSmall ? 16 : 20);
            final titleSize = isSmall ? 28.0 : 32.0;
            final summaryValueSize = isSmall ? 18.0 : 20.0;
            final tabPadding = EdgeInsets.symmetric(
              horizontal: isSmall ? 16 : 20,
            );
            return Column(
              children: [
                Container(
                  padding: headerPadding,
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Hi, ${user?.name ?? 'User'}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: Icon(
                              Icons.notifications,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmall ? 16 : 25),

                      Text(
                        "Spendable Balance",
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "৳${accountController.spendableBalance.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isSmall ? 16 : 25),

                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSummaryItem(
                              "Income",
                              totalIncome,
                              Colors.greenAccent,
                              valueSize: summaryValueSize,
                            ),
                            VerticalDivider(
                              color: Colors.white30,
                              thickness: 1,
                            ),
                            _buildSummaryItem(
                              "Expense",
                              totalExpense,
                              Colors.redAccent,
                              valueSize: summaryValueSize,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isSmall ? 12 : 20),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 20),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 5),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTab("Daily"),
                      _buildTab("Weekly"),
                      _buildTab("Monthly"),
                    ],
                  ),
                ),

                SizedBox(height: isSmall ? 12 : 20),

                Padding(
                  padding: tabPadding,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Recent Transactions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isSmall ? 8 : 10),

                Expanded(
                  child: controller.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : filteredTransactions.isEmpty
                      ? Center(
                          child: Text(
                            "No transactions for this period",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: tabPadding,
                          itemCount: filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final tx = filteredTransactions[index];
                            final accountName =
                                Provider.of<AccountController>(
                                      context,
                                      listen: false,
                                    ).accounts
                                    .firstWhere(
                                      (a) => a.id == tx.accountId,
                                      orElse: () => Account(
                                        id: '',
                                        userId: '',
                                        name: 'Unknown',
                                        type: '',
                                        balance: 0.0,
                                        parentType: '',
                                        currency: 'BDT',
                                        isDefault: false,
                                        includeInSavings: false,
                                      ),
                                    )
                                    .name;

                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: tx.type == 'income'
                                          ? Colors.green[50]
                                          : Colors.red[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      tx.type == 'income'
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      color: tx.type == 'income'
                                          ? Colors.green
                                          : Colors.red,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tx.category ?? "General",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "${DateFormat('MMM d, yyyy • h:mm a').format(tx.date.toLocal())}${tx.note != null && tx.note!.isNotEmpty ? ' • ${tx.note}' : ''}",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${tx.type == 'expense' ? '-' : '+'}${tx.amount.toStringAsFixed(0)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: tx.type == 'income'
                                              ? Colors.green[700]
                                              : Colors.red[700],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        accountName,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    double amount,
    Color color, {
    double valueSize = 20,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              label == "Income" ? Icons.arrow_downward : Icons.arrow_upward,
              color: Colors.white70,
              size: 16,
            ),
            SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.white70)),
          ],
        ),
        SizedBox(height: 4),
        Text(
          "৳${amount.toStringAsFixed(2)}",
          style: TextStyle(
            color: color,
            fontSize: valueSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String title) {
    bool isSelected = _selectedPeriod == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = title),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
