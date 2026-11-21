import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/network/api_client.dart';
import 'otp_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया 10 अंकों का मान्य मोबाइल नंबर दर्ज करें')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.dio.post(
        '',
        queryParameters: {'action': 'send-otp'},
        data: {'phone': phone},
      );

      if (response.data['success'] == true) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OtpScreen(phone: phone)),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message'] ?? 'OTP भेजने में विफल')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('सर्वर से कनेक्ट नहीं हो सका')),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Figma Logo
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.brandGradient,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x40FF7A00),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
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
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'आपका विश्वसनीय सेवा साथी',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSubheading,
                  ),
                ),
                const SizedBox(height: 32),

                // Figma White Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderLight.withOpacity(0.6)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14FF7A00),
                        blurRadius: 30,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'लॉगिन करें',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'मोबाइल नंबर',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: InputDecoration(
                          hintText: '98XXXXXXXX',
                          counterText: '',
                          prefixIcon: const Icon(Icons.phone_android_rounded, color: AppColors.brandOrange),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.borderInput),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.brandOrange, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Send OTP Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 4,
                            shadowColor: const Color(0x66FF7A00),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('OTP भेजें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Register as Partner link
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'नया पार्टनर खाता बनाएं (Register as Partner)',
                          style: TextStyle(
                            color: AppColors.brandOrangeDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'जारी रखने से आप हमारी सेवा की शर्तों से सहमत हैं।',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
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
