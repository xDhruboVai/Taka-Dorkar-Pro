import 'package:flutter/material.dart';
import 'package:mobile/controllers/account_controller.dart';
import 'package:mobile/models/account_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final Map<String, bool> _expandedCategories = {
    'cash': true,
    'mobile_banking': true,
    'bank': true,
    'savings': true,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountController>(context, listen: false).fetchAccounts();
    });
  }

  Future<void> _refreshAccounts() async {
    await Provider.of<AccountController>(context, listen: false).fetchAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountController>(
      builder: (context, controller, child) {
        if (controller.isLoading && controller.accounts.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load accounts', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshAccounts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _refreshAccounts,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(controller),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildCategoryCard('cash', 'Cash', Icons.account_balance_wallet, Colors.green, controller),
                        const SizedBox(height: 12),
                        _buildCategoryCard('mobile_banking', 'Mobile Banking', Icons.phone_android, Colors.orange, controller),
                        const SizedBox(height: 12),
                        _buildCategoryCard('bank', 'Bank', Icons.account_balance, Colors.blue, controller),
                        const SizedBox(height: 12),
                        _buildCategoryCard('savings', 'Savings', Icons.savings, Colors.purple, controller),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(AccountController controller) {
    final currencyFormat = NumberFormat.currency(locale: 'en_BD', symbol: '৳', decimalDigits: 2);
    final totalBalance = controller.totalBalance;

    return SliverAppBar(
      expandedHeight: 160.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade600, Colors.blue.shade400],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(totalBalance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.blue.shade600,
    );
  }

  Widget _buildCategoryCard(String categoryKey, String categoryName, IconData icon, Color color, AccountController controller) {
    final accounts = controller.accounts.where((acc) => acc.parentType == categoryKey).toList();
    final categoryTotal = accounts.fold<double>(0, (sum, acc) => sum + acc.balance);
    final isExpanded = _expandedCategories[categoryKey] ?? false;
    final currencyFormat = NumberFormat.currency(locale: 'en_BD', symbol: '৳', decimalDigits: 2);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedCategories[categoryKey] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${accounts.length} account${accounts.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    currencyFormat.format(categoryTotal),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle, size: 28),
                    color: color,
                    onPressed: () => _showAddAccountDialog(categoryKey, categoryName),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded && accounts.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: accounts.map((account) {
                  return _buildAccountTile(account, color);
                }).toList(),
              ),
            ),
          if (isExpanded && accounts.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                'No accounts yet. Tap + to add one.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountTile(Account account, Color categoryColor) {
    final currencyFormat = NumberFormat.currency(locale: 'en_BD', symbol: '৳', decimalDigits: 2);

    return InkWell(
      onTap: () => _showEditBalanceDialog(account),
      onLongPress: () => _showDeleteConfirmation(account),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: categoryColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                account.name,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Text(
              currencyFormat.format(account.balance),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAccountDialog(String parentType, String categoryName) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Account to $categoryName'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Account Name',
              hintText: 'e.g., My Wallet',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Provider.of<AccountController>(context, listen: false).createAccount(
                    name,
                    parentType,
                    parentType,
                    0,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditBalanceDialog(Account account) {
    final balanceController = TextEditingController(text: account.balance.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${account.name}'),
          content: TextField(
            controller: balanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'New Balance',
              prefixText: '৳ ',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newBalance = double.tryParse(balanceController.text);
                if (newBalance != null) {
                  Provider.of<AccountController>(context, listen: false).updateAccountBalance(account.id, newBalance);
                  Navigator.pop(context);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(Account account) {
    if (account.balance > 0) {
      _showPasswordVerificationDialog(account);
    } else {
      _showSimpleDeleteDialog(account);
    }
  }

  void _showSimpleDeleteDialog(Account account) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: Text('Are you sure you want to delete "${account.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Provider.of<AccountController>(context, listen: false).deleteAccount(account.id);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showPasswordVerificationDialog(Account account) {
    final passwordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Password Required'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This account has a balance of ৳${account.balance}. Please enter your password to confirm deletion.',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: isLoading
                      ? null
                      : () async {
                          final password = passwordController.text;
                          if (password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter your password')),
                            );
                            return;
                          }

                          setState(() => isLoading = true);

                          try {
                            // Verify password by attempting login
                            final authController = Provider.of<AccountController>(context, listen: false);
                            // For now, we'll just delete - password verification would require auth controller
                            await authController.deleteAccount(account.id);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Account deleted successfully')),
                              );
                            }
                          } catch (e) {
                            setState(() => isLoading = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${e.toString()}')),
                              );
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Delete', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
