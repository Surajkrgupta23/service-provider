import 'package:flutter/material.dart';
import 'core/constants/colors.dart';
import 'core/network/api_client.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final token = await ApiClient.getToken();

  runApp(
    CooperativeClapApp(isLoggedIn: token != null),
  );
}

class CooperativeClapApp extends StatelessWidget {
  final bool isLoggedIn;
  const CooperativeClapApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cooperative Clap - सेवा साथी',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brandOrange,
          primary: AppColors.brandOrange,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textHeading,
          elevation: 0,
        ),
      ),
      home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
