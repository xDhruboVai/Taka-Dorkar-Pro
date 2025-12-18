import 'package:flutter/material.dart';
import 'package:mobile/controllers/account_controller.dart';
import 'package:provider/provider.dart';

class AccountsView extends StatefulWidget {
  const AccountsView({super.key});

  @override
  _AccountsViewState createState() => _AccountsViewState();
}

class _AccountsViewState extends State<AccountsView> {
  @override
  void initState() {
    super.initState();
    // Fetch accounts when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountController>(context, listen: false).fetchAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountController>(
      builder: (context, accountController, child) {
        if (accountController.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final groupedAccounts = accountController.groupedAccounts;
        final categories = ['cash', 'mobile_banking', 'bank', 'savings'];

        return Scaffold(
          body: ListView(
            children: categories.map((category) {
              final accounts = groupedAccounts[category] ?? [];
              double categoryTotal = accounts.fold(
                0,
                (sum, item) => sum + item.balance,
              );

              return ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatCategoryName(category),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '৳${categoryTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                children: accounts.map((account) {
                  return ListTile(
                    title: Text(account.name),
                    trailing: Text('৳${account.balance.toStringAsFixed(2)}'),
                    onTap: () => _showEditBalanceDialog(context, account),
                  );
                }).toList(),
              );
            }).toList(),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddAccountDialog(context),
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  String _formatCategoryName(String category) {
    return category
        .replaceAll('_', ' ')
        .split(' ')
        .map((str) => str[0].toUpperCase() + str.substring(1))
        .join(' ');
  }

  void _showEditBalanceDialog(BuildContext context, account) {
    final TextEditingController balanceController = TextEditingController(
      text: account.balance.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Balance for ${account.name}'),
          content: TextField(
            controller: balanceController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'New Balance',
              prefixText: '৳',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newBalance = double.tryParse(balanceController.text);
                if (newBalance != null) {
                  Provider.of<AccountController>(
                    context,
                    listen: false,
                  ).updateAccountBalance(account.id, newBalance);
                  Navigator.pop(context);
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    String? selectedCategory = 'cash';
    final categories = ['cash', 'mobile_banking', 'bank', 'savings'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Account Name'),
              ),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(_formatCategoryName(category)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  selectedCategory = newValue;
                },
                decoration: InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                if (name.isNotEmpty && selectedCategory != null) {
                  Provider.of<AccountController>(
                    context,
                    listen: false,
                  ).createAccount(
                    name,
                    selectedCategory!,
                    selectedCategory!,
                    0,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
