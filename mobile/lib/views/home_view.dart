import 'package:flutter/material.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/views/accounts_screen.dart';
import 'package:mobile/views/ai_budget_view.dart';
import 'package:mobile/views/analysis_view.dart';
import 'package:mobile/views/ask_ai_view.dart';
import 'package:mobile/views/budget_view.dart';
import 'package:mobile/views/security_view.dart';
import 'package:mobile/views/transactions_view.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    TransactionsView(),
    AccountsScreen(),
    BudgetView(),
    AnalysisView(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Taka Dorkar Pro')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.security),
              title: Text('Security'),
              onTap: () {
                Navigator.pop(context); // close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecurityView()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.auto_awesome),
              title: Text('AI Budget'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AiBudgetView()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.question_answer),
              title: Text('Ask AI'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AskAiView()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                Provider.of<AuthController>(context, listen: false).logout();
              },
            ),
          ],
        ),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Budget'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Analysis',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
