import 'package:flutter/material.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/controllers/transaction_controller.dart';
import 'package:mobile/views/auth/auth_gate.dart';
import 'package:mobile/widgets/app_theme.dart';
import 'package:mobile/controllers/account_controller.dart';
import 'package:provider/provider.dart';

void main() {
  const asciiArt = '''
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣤⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⠀⠀⠀⢀⣴⠟⠉⠀⠀⠀⠈⠻⣦⡀⠀⠀⠀⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣷⣀⢀⣾⠿⠻⢶⣄⠀⠀⣠⣶⡿⠶⣄⣠⣾⣿⠗⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⢻⣿⣿⡿⣿⠿⣿⡿⢼⣿⣿⡿⣿⣎⡟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⡟⠉⠛⢛⣛⡉⠀⠀⠙⠛⠻⠛⠑⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣧⣤⣴⠿⠿⣷⣤⡤⠴⠖⠳⣄⣀⣹⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣀⣟⠻⢦⣀⡀⠀⠀⠀⠀⣀⡈⠻⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⡿⠉⡇⠀⠀⠛⠛⠛⠋⠉⠉⠀⠀⠀⠹⢧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⡟⠀⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠃⠀⠈⠑⠪⠷⠤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣾⣿⣿⣿⣦⣼⠛⢦⣤⣄⡀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠑⠢⡀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢀⣠⠴⠲⠖⠛⠻⣿⡿⠛⠉⠉⠻⠷⣦⣽⠿⠿⠒⠚⠋⠉⠁⡞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢦⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⣾⠛⠁⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠤⠒⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢣⠀⠀⠀
⠀⠀⠀⠀⣰⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣑⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⡇⠀⠀
⠀⠀⠀⣰⣿⣁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣧⣄⠀⠀⠀⠀⠀⠀⢳⡀⠀
⠀⠀⠀⣿⡾⢿⣀⢀⣀⣦⣾⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡰⣫⣿⡿⠟⠻⠶⠀⠀⠀⠀⠀⢳⠀
⠀⠀⢀⣿⣧⡾⣿⣿⣿⣿⣿⡷⣶⣤⡀⠀⠀⠀⠀⠀⠀⠀⢀⡴⢿⣿⣧⠀⡀⠀⢀⣀⣀⢒⣤⣶⣿⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇
⠀⠀⡾⠁⠙⣿⡈⠉⠙⣿⣿⣷⣬⡛⢿⣶⣶⣴⣶⣶⣶⣤⣤⠤⠾⣿⣿⣿⡿⠿⣿⠿⢿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇
⠀⣸⠃⠀⠀⢸⠃⠀⠀⢸⣿⣿⣿⣿⣿⣿⣷⣾⣿⣿⠟⡉⠀⠀⠀⠈⠙⠛⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇
⠀⣿⠀⠀⢀⡏⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⠿⠿⠛⠛⠉⠁⠀⠀⠀⠀⠀⠉⠠⠿⠟⠻⠟⠋⠉⢿⣿⣦⡀⢰⡀⠀⠀⠀⠀⠀⠀⠁
⢀⣿⡆⢀⡾⠀⠀⠀⠀⣾⠏⢿⣿⣿⣿⣯⣙⢷⡄⠀⠀⠀⠀⠀⢸⡄⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣿⣻⢿⣷⣀⣷⣄⠀⠀⠀⠀⢸⠀
⢸⠃⠠⣼⠃⠀⠀⣠⣾⡟⠀⠈⢿⣿⡿⠿⣿⣿⡿⠿⠿⠿⠷⣄⠈⠿⠛⠻⠶⢶⣄⣀⣀⡠⠈⢛⡿⠃⠈⢿⣿⣿⡿⠀⠀⠀⠀⠀⡀
⠟⠀⠀⢻⣶⣶⣾⣿⡟⠀⠀⢸⣿⢅⠀⠈⣿⡇⠀⠀⠀⠀⠀⣷⠂⠀⠀⠀⠀⠐⠋⠉⠉⠀⢸⠁⠀⠀⠀⢻⣿⠛⠀⠀⠀⠀⢀⠇
⠀⠀⠀⠀⠹⣿⣿⠋⠀⠀⠀⠀⢸⣧⠀⠰⡀⢸⣷⣤⣤⡄⠀⠀⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡆⠀⠀⠀⠀⡾⠀⠀⠀⠀⠀⠀⢼⡇
⠀⠀⠀⠀⠀⠙⢻⠄⠀⠀⠀⠀⣿⠉⠀⠀⠈⠓⢯⡉⠉⠉⢱⣶⠏⠙⠛⠚⠁⠀⠀⠀⠀⠀⣼⠇⠀⠀⠀⢀⡇⠀⠀⠀⠀⠀⠀⠀⡇
⠀⠀⠀⠀⠀⠀⠻⠄⠀⠀⠀⢀⣿⠀⢠⡄⠀⠀⠀⣁⠁⡀⠀⢠⠀⠀⠀⠀⠀⠀⠀⠀⢀⣐⡟⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⢠⡇
''';
  for (var line in asciiArt.split('\n')) {
    debugPrint(line);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => TransactionController()),
        ChangeNotifierProvider(create: (_) => AccountController()),
      ],
      child: MaterialApp(
        title: 'Taka Dorkar Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppTheme.primaryColor,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: AppTheme.accentColor,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AuthGate(),
      ),
    );
  }
}
