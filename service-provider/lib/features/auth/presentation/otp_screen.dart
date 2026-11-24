import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_endpoints.dart';
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
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
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
    final response = await ApiClient.dio.post(
      '',
      queryParameters: {'action': ApiEndpoints.verifyOtp},
      data: {'phone': widget.phone, 'otp': otp},
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    final data = response.data;
    if (data != null && data['success'] == true) {
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
      final msg = data?['message'] ?? 'OTP अमान्य है';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textHeading, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/register_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.brandGradient,
                        boxShadow: [
                          BoxShadow(color: Color(0x40FF7A00), blurRadius: 20, offset: Offset(0, 8)),
                        ],
                      ),
                      child: const Icon(Icons.handshake_rounded, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Cooperative Clap',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'सुरक्षित OTP सत्यापन',
                      style: TextStyle(fontSize: 13, color: AppColors.brandOrangeDark, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFED7AA), width: 1.2),
                        boxShadow: const [
                          BoxShadow(color: Color(0x10FF7A00), blurRadius: 24, offset: Offset(0, 8)),
                        ],
                      ),
                    child: Column(
                      children: [
                        const Text(
                          'OTP दर्ज करें',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textHeading),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '+91 ${widget.phone} पर भेजा गया 6 अंकों का कोड दर्ज करें (Test OTP: 123456)',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (i) {
                            return SizedBox(
                              width: 46,
                              height: 52,
                              child: TextField(
                                controller: _controllers[i],
                                focusNode: _focusNodes[i],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textHeading),
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: const Color(0xFFFFFDFB),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFFED7AA)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFFED7AA)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppColors.brandOrange, width: 2),
                                  ),
                                ),
                                onChanged: (val) {
                                  if (val.isNotEmpty && i < 5) {
                                    _focusNodes[i + 1].requestFocus();
                                  } else if (val.isEmpty && i > 0) {
                                    _focusNodes[i - 1].requestFocus();
                                  }
                                },
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 24),

                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(color: Color(0x40FF7A00), blurRadius: 14, offset: Offset(0, 6)),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('OTP सत्यापित करें (Verify OTP)', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 18),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('← नंबर बदलें', style: TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
                            ),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('नया OTP भेजा गया (Test OTP: 123456)')),
                                );
                              },
                              child: const Text('OTP दोबारा भेजें', style: TextStyle(color: AppColors.brandOrangeDark, fontWeight: FontWeight.bold, fontSize: 12.5)),
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
      ),
    ),
  );
}
}
