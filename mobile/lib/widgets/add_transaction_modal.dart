import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/account_controller.dart';
import '../controllers/budget_controller.dart';
import '../services/api_service.dart';

class AddTransactionModal extends StatefulWidget {
  const AddTransactionModal({super.key});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  String _selectedType = 'expense';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;

  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<AccountController>(context, listen: false).fetchAccounts();
      final userId = Provider.of<AuthController>(
        context,
        listen: false,
      ).currentUser?.id;
      List<Map<String, dynamic>> cats = [];
      try {
        final data = await ApiService.get(
          '/categories?user_id=$userId&type=expense',
        );
        if (data is List) {
          cats = List<Map<String, dynamic>>.from(data);
        }
      } catch (_) {}
      setState(() {
        _categories = cats;
        if (_categories.isNotEmpty) {
          _selectedCategoryId = _categories.first['id'] as String;
        }
      });
    });
  }

  void _submitTransaction() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final transactionController = Provider.of<TransactionController>(
      context,
      listen: false,
    );
    // Removed unused accountController

    if (_amountController.text.isEmpty ||
        double.tryParse(_amountController.text) == null) {
      messenger.showSnackBar(
        SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (_selectedAccountId == null) {
      messenger.showSnackBar(
        SnackBar(content: Text('Please select an account')),
      );
      return;
    }

    final currentUser = authController.currentUser;
    if (currentUser == null) {
      messenger.showSnackBar(SnackBar(content: Text('You must be logged in')));
      return;
    }

    final now = DateTime.now().toIso8601String();
    final id = Uuid().v4();
    final newTransaction = {
      'id': id,
      'user_id': currentUser.id,
      'amount': double.parse(_amountController.text),
      'type': _selectedType,
      'category': _categories.firstWhere(
        (c) => c['id'] == _selectedCategoryId,
        orElse: () => {'name': null},
      )['name'],
      'account_id': _selectedAccountId,
      'date': _selectedDate.toIso8601String(),
      'note': _noteController.text,
      'created_at': now,
      'updated_at': now,
    };

    // Removed unused catName
    transactionController.addTransaction({
      'user_id': currentUser.id,
      'amount': newTransaction['amount'],
      'type': newTransaction['type'],
      'category': newTransaction['category'],
      'account_id': newTransaction['account_id'],
      'date': newTransaction['date'],
      'note': newTransaction['note'],
    });

    try {
      try {
        final bc = Provider.of<BudgetController>(context, listen: false);
        await bc.loadBudgets();
      } catch (_) {}

      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text('Transaction Added')));
    } catch (_) {}
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

    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }

    return Container(
      padding: EdgeInsets.all(20),
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
              initialValue: _selectedCategoryId,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              items: _categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c['id'] as String,
                      child: Text(c['name'] as String),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategoryId = val),
            ),
            SizedBox(height: 20),

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
