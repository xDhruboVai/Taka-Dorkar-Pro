import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/budget_controller.dart';

class BudgetView extends StatefulWidget {
  const BudgetView({super.key});

  @override
  State<BudgetView> createState() => _BudgetViewState();
}

class _BudgetViewState extends State<BudgetView> {
  String? _selectedCategoryId;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetController>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetController>(
      builder: (context, c, _) {
        final monthLabel = _formatMonth(c.currentMonth);
        return Scaffold(
          appBar: AppBar(
            title: Text('Monthly Budget ($monthLabel)'),
            actions: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => c.previousMonth(),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => c.nextMonth(),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: c.expenseCategories
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat['id'] as String,
                                child: Text(cat['name'] as String),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedCategoryId = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(labelText: 'Amount'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: c.isBusy
                            ? null
                            : () async {
                                final id = _selectedCategoryId;
                                final amt = double.tryParse(
                                  _amountController.text,
                                );
                                if (id == null || amt == null || amt <= 0)
                                  return;
                                await c.createBudget(
                                  categoryId: id,
                                  amount: amt,
                                );
                                _amountController.clear();
                              },
                        child: c.isBusy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Add'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: c.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : c.budgets.isEmpty
                      ? const Center(child: Text('No budgets for this month'))
                      : ListView.builder(
                          itemCount: c.budgets.length,
                          itemBuilder: (context, index) {
                            final b = c.budgets[index];
                            final name =
                                c.categoryName(b.categoryId) ?? 'Unknown';
                            final spent = c.spentFor(b.categoryId);
                            final pct = b.amount <= 0
                                ? 0.0
                                : (spent / b.amount).clamp(0.0, 1.0);
                            final color = pct >= 1.0
                                ? Colors.red
                                : pct >= 0.8
                                ? Colors.orange
                                : Colors.green;
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          onSelected: (v) async {
                                            if (v == 'edit') {
                                              final ctrl =
                                                  TextEditingController(
                                                    text: b.amount
                                                        .toStringAsFixed(0),
                                                  );
                                              final newAmt =
                                                  await showDialog<double>(
                                                    context: context,
                                                    builder: (_) => AlertDialog(
                                                      title: const Text(
                                                        'Edit Amount',
                                                      ),
                                                      content: TextField(
                                                        controller: ctrl,
                                                        keyboardType:
                                                            TextInputType.numberWithOptions(
                                                              decimal: true,
                                                            ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                          child: const Text(
                                                            'Cancel',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            final v =
                                                                double.tryParse(
                                                                  ctrl.text,
                                                                );
                                                            Navigator.pop(
                                                              context,
                                                              v,
                                                            );
                                                          },
                                                          child: const Text(
                                                            'Save',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                              if (newAmt != null &&
                                                  newAmt > 0) {
                                                await c.updateBudgetAmount(
                                                  b.id,
                                                  newAmt,
                                                );
                                              }
                                            }
                                            if (v == 'delete') {
                                              await c.deleteBudget(b.id);
                                            }
                                          },
                                          itemBuilder: (_) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Text('Edit'),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '৳${spent.toStringAsFixed(0)} of ৳${b.amount.toStringAsFixed(0)}',
                                        ),
                                        Text(
                                          '${(pct * 100).toStringAsFixed(0)}%',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: pct,
                                      color: color,
                                      backgroundColor: Colors.grey[200],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatMonth(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}
