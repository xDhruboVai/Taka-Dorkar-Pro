import 'package:flutter/material.dart';

class AiBudgetView extends StatelessWidget {
  const AiBudgetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Budget'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(child: Text('AI Budget View')),
    );
  }
}
