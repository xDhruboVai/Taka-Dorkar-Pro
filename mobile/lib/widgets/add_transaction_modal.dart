import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/transaction_controller.dart';
import '../models/transaction_model.dart';

class AddTransactionModal extends StatefulWidget {
  const AddTransactionModal({super.key});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedType = 'expense';
  String _selectedCategory = 'Food & Dining';
  String _selectedAccount = 'Cash';
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'Food & Dining',
    'Transport',
    'Shopping',
    'Entertainment',
    'Medical',
    'Education',
    'Personal',
    'Salary',
    'Pocket Money',
    'Other'
  ];

  final List<String> _accounts = ['Cash', 'Bank', 'Rocket', 'Bkash', 'Nagad'];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitData() {
    if(_amountController.text.isEmpty) {
      return;
    }
    final enteredAmount = double.tryParse(_amountController.text);
    if(enteredAmount == null || enteredAmount <= 0) {
      return;
    }

    final newTx = TransactionModel(
      id: DateTime.now().toString(),
      amount: enteredAmount,
      type: _selectedType,
      date: _selectedDate,
      category: _selectedCategory,
      account: _selectedAccount,
      note: _noteController.text,
    );

    Provider.of<TransactionController>(context, listen: false).addTransaction(newTx);
    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Transaction',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('TYPE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildTypeButton('Expense', 'expense')),
                SizedBox(width: 10),
                Expanded(child: _buildTypeButton('Income', 'income')),
                SizedBox(width: 10),
                Expanded(child: _buildTypeButton('Transfer', 'transfer')),
              ],
            ),
             SizedBox(height: 20),
             Text('AMOUNT (৳)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
             SizedBox(height: 10),
             TextField(
               controller: _amountController,
               keyboardType: TextInputType.number,
               decoration: InputDecoration(
                 filled: true,
                 fillColor: Colors.white,
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                 hintText: '0',
               ),
             ),
             SizedBox(height: 20),
             Text('CATEGORY', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              SizedBox(height: 10),
             Container(
               padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(10),
               ),
               child: DropdownButtonHideUnderline(
                 child: DropdownButton<String>(
                   value: _selectedCategory,
                   isExpanded: true,
                   items: _categories.map((String value) {
                     return DropdownMenuItem<String>(
                       value: value,
                       child: Text(value),
                     );
                   }).toList(),
                   onChanged: (newValue) {
                     setState(() {
                       _selectedCategory = newValue!;
                     });
                   },
                 ),
               ),
             ),
             SizedBox(height: 20),
             Text('ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              SizedBox(height: 10),
             Container(
               padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(10),
               ),
               child: DropdownButtonHideUnderline(
                 child: DropdownButton<String>(
                   value: _selectedAccount,
                   isExpanded: true,
                   items: _accounts.map((String value) {
                     return DropdownMenuItem<String>(
                       value: value,
                       child: Text(value),
                     );
                   }).toList(),
                   onChanged: (newValue) {
                     setState(() {
                       _selectedAccount = newValue!;
                     });
                   },
                 ),
               ),
             ),
             SizedBox(height: 20),
             Text('DATE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
             SizedBox(height: 10),
             GestureDetector(
               onTap: _presentDatePicker,
               child: Container(
                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(10),
                 ),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text(DateFormat.yMd().format(_selectedDate)),
                     Icon(Icons.calendar_today, size: 20),
                   ],
                 ),
               ),
             ),
             SizedBox(height: 20),
             Text('NOTE (OPTIONAL)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
             SizedBox(height: 10),
             TextField(
               controller: _noteController,
               decoration: InputDecoration(
                 filled: true,
                 fillColor: Colors.white,
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                 hintText: 'Add a note...',
               ),
             ),
             SizedBox(height: 30),
             SizedBox(
               width: double.infinity,
               height: 50,
               child: ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.teal,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                 ),
                 onPressed: _submitData,
                 child: Text('Add Transaction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
               ),
             ),
             SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, String value) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
