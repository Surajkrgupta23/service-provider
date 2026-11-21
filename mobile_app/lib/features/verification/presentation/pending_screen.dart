import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/login_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';

class PendingScreen extends StatefulWidget {
  final String? phone;
  const PendingScreen({super.key, this.phone});

  @override
  State<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen> {
  bool _isChecking = false;

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);
    try {
      final token = await ApiClient.getToken();
      final response = await ApiClient.dio.get(
        '',
        queryParameters: {'action': ApiEndpoints.status},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data;
      if (data['success'] == true) {
        final status = data['data']['verification_status'];
        if (!mounted) return;

        if (status == 'verified') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('स्थिति: सत्यापन प्रक्रियाधीन (Under Review)')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('स्टेटस जांचने में असमर्थ')),
      );
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pending Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFEF3C7), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x14FF7A00), blurRadius: 20, offset: Offset(0, 10)),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.hourglass_top_rounded, color: Color(0xFFD97706), size: 36),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'सत्यापन प्रक्रियाधीन',
                        style: TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.w800, fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'आवेदन जांच के अधीन है',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textHeading),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'आपका रजिस्ट्रेशन प्राप्त हो गया है। एडमिन द्वारा सत्यापन पूर्ण होते ही आपका डैशबोर्ड स्वतः अनलॉक हो जाएगा।',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textSubheading, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isChecking ? null : _checkStatus,
                  icon: _isChecking
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.refresh_rounded),
                  label: const Text('स्थिति पुनः जांचें (Check Status)', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () async {
                  await ApiClient.clearAuth();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded, color: AppColors.textMuted),
                label: const Text('लॉगआउट', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
