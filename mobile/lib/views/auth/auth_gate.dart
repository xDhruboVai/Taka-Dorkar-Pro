import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/controllers/auth_controller.dart';
import 'package:mobile/views/home_view.dart';
import 'package:mobile/views/auth/login_screen.dart';

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        if (authController.isAuthenticated) {
          return HomeView();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
