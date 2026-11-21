import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/network/api_client.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../verification/presentation/pending_screen.dart';
import 'register_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Default prefilled test OTP as shown in Figma screenshot (878786)
    const testOtp = '878786';
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = testOtp[i];
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया 6 अंकों का OTP दर्ज करें')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.dio.post(
        '',
        queryParameters: {'action': 'verify-otp'},
        data: {'phone': widget.phone, 'otp': otp},
      );

      final data = response.data;
      if (data['success'] == true) {
        if (!mounted) return;
        if (data['data']['needs_registration'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => RegisterScreen(initialPhone: widget.phone)),
          );
        } else {
          final token = data['data']['auth_token'];
          final status = data['data']['status'];
          await ApiClient.saveToken(token);

          if (!mounted) return;
          if (status == 'verified') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => PendingScreen(phone: widget.phone)),
              (route) => false,
            );
          }
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'OTP अमान्य है')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('सत्यापन त्रुटि')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                // Figma Logo
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.brandGradient,
                    boxShadow: [
                      BoxShadow(color: Color(0x40FF7A00), blurRadius: 20, offset: Offset(0, 8)),
                    ],
                  ),
                  child: const Icon(Icons.handshake_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Cooperative Clap',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textHeading,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'आपका विश्वसनीय सेवा साथी',
                  style: TextStyle(fontSize: 14, color: AppColors.textSubheading),
                ),
                const SizedBox(height: 32),

                // Figma OTP Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderLight.withOpacity(0.6)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x14FF7A00), blurRadius: 30, offset: Offset(0, 12)),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'OTP सत्यापन',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '+91 ${widget.phone} पर भेजे गए 6 अंकों का OTP दर्ज करें',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),

                      // 6 Segmented PIN boxes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (i) {
                          return SizedBox(
                            width: 44,
                            height: 52,
                            child: TextField(
                              controller: _controllers[i],
                              focusNode: _focusNodes[i],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: const Color(0xFFFFFBF7),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.borderLight),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.brandOrange, width: 2),
                                ),
                              ),
                              onChanged: (val) {
                                if (val.isNotEmpty && i < 5) {
                                  _focusNodes[i + 1].requestFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),

                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('सत्यापित करें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('नंबर बदलें', style: TextStyle(color: AppColors.brandOrangeDark, fontWeight: FontWeight.bold)),
                          ),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('नया OTP भेजा गया (Test OTP: 878786)')),
                              );
                            },
                            child: const Text('OTP दोबारा भेजें', style: TextStyle(color: AppColors.brandOrangeDark, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
