import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/account_controller.dart';
import '../models/account_model.dart';

class AddTransactionModal extends StatefulWidget {
  const AddTransactionModal({super.key});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  String _selectedType = 'expense'; // 'expense', 'income', 'transfer'
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // Categories
  final List<String> _categories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Bills',
    'Salary',
    'Investment',
    'Rent',
    'Groceries',
    'Utilities',
  ];
  String? _selectedCategory;

  // Accounts
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories[0];

    // Fetch accounts when modal opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountController>(context, listen: false).fetchAccounts();
    });
  }

  void _submitTransaction() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final transactionController = Provider.of<TransactionController>(
      context,
      listen: false,
    );
    final accountController = Provider.of<AccountController>(
      context,
      listen: false,
    );

    // Validation
    if (_amountController.text.isEmpty ||
        double.tryParse(_amountController.text) == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a valid amount')));
      return;
    }

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please select an account')));
      return;
    }

    final currentUser = authController.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('You must be logged in')));
      return;
    }

    final newTransaction = {
      'user_id': currentUser.id,
      'amount': double.parse(_amountController.text),
      'type': _selectedType,
      'category': _selectedCategory,
      'account_id': _selectedAccountId,
      'date': _selectedDate.toIso8601String(),
      'note': _noteController.text,
    };

    final success = await transactionController.addTransaction(newTransaction);
    if (success) {
      // Update account balance locally immediately for UI responsiveness
      // Note: In a real app, backend should handle this sync or we double check.
      // Ideally, specific logic for income (+) vs expense (-)
      double currentBalance = accountController.accounts
          .firstWhere((a) => a.id == _selectedAccountId)
          .balance;
      double amount = double.parse(_amountController.text);
      if (_selectedType == 'expense') {
        await accountController.updateAccountBalance(
          _selectedAccountId!,
          currentBalance - amount,
        );
      } else if (_selectedType == 'income') {
        await accountController.updateAccountBalance(
          _selectedAccountId!,
          currentBalance + amount,
        );
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Transaction Added')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add transaction')));
    }
  }

  Widget _buildTypeButton(String label, String value) {
    bool isSelected = _selectedType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.teal : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountController = Provider.of<AccountController>(context);
    final accounts = accountController.accounts;

    // Set default account selection if available and not set
    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }

    return Container(
      padding: EdgeInsets.all(20),
      // Handle keyboard covering
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Add Transaction",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Type Selection
            Text(
              "TYPE",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                _buildTypeButton("Expense", "expense"),
                SizedBox(width: 10),
                _buildTypeButton("Income", "income"),
                SizedBox(width: 10),
                _buildTypeButton("Transfer", "transfer"),
              ],
            ),
            SizedBox(height: 20),

            // Amount
            Text(
              "AMOUNT (৳)",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: "0.00",
                prefixText: "৳ ",
              ),
            ),
            SizedBox(height: 20),

            // Category
            Text(
              "CATEGORY",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            SizedBox(height: 20),

            // Account
            Text(
              "ACCOUNT",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 10),
            accountController.isLoading
                ? Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    initialValue: _selectedAccountId,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: accounts
                        .map(
                          (a) => DropdownMenuItem(
                            value: a.id,
                            child: Text("${a.name} (৳${a.balance})"),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedAccountId = val),
                  ),
            SizedBox(height: 20),

            // Date
            Text(
              "DATE",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${_selectedDate.toLocal()}".split(' ')[0]),
                    Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Note
            Text(
              "NOTE (OPTIONAL)",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: "Add a note...",
              ),
            ),
            SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Add Transaction",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
