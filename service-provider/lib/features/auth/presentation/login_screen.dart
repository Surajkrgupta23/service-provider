import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../verification/presentation/pending_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithPassword() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया 10 अंकों का मान्य मोबाइल नंबर दर्ज करें')),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया अपना पासवर्ड दर्ज करें')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.dio.post(
        '',
        queryParameters: {'action': ApiEndpoints.login},
        data: {
          'login_id': phone,
          'phone': phone,
          'password': password,
        },
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : null;

      if (data != null && data['success'] == true) {
        final token = data['data']?['auth_token'];
        final status = data['data']?['status'] ?? data['data']?['provider']?['verification_status'];

        if (token != null) {
          await ApiClient.saveToken(token.toString());
        }

        if (!mounted) return;
        if (status == 'verified' || status == 'approved') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => PendingScreen(phone: phone)),
            (route) => false,
          );
        }
      } else {
        final msg = data?['message'] ?? 'लॉगिन विफल। कृपया मोबाइल नंबर और पासवर्ड जांचें।';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg.toString())),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('त्रुटि: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 500;
          final double containerWidth = isWide ? 440 : constraints.maxWidth;
          final double containerHeight = isWide
              ? (constraints.maxHeight > 880 ? 860 : constraints.maxHeight)
              : constraints.maxHeight;

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: isWide
                ? const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/register_bg.jpg'),
                      fit: BoxFit.cover,
                    ),
                  )
                : null,
            child: Center(
              child: Container(
                width: containerWidth,
                height: containerHeight,
                decoration: BoxDecoration(
                  borderRadius: isWide ? BorderRadius.circular(28) : BorderRadius.zero,
                  boxShadow: isWide
                      ? [
                          const BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 36,
                            offset: Offset(0, 10),
                          ),
                        ]
                      : const [],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/login_bg.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: isWide ? BorderRadius.circular(28) : BorderRadius.zero,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),

                          Container(
                            width: 58,
                            height: 58,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.brandGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x33FF7A00),
                                  blurRadius: 16,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.handshake_rounded, color: Colors.white, size: 32),
                          ),
                          const SizedBox(height: 6),

                          const Text(
                            'Cooperative Clap',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textHeading,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),

                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('✪', style: TextStyle(fontSize: 11, color: AppColors.brandOrangeDark)),
                              SizedBox(width: 5),
                              Text(
                                'आपका विश्वसनीय सेवा साथी',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.brandOrangeDark,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              SizedBox(width: 5),
                              Text('✪', style: TextStyle(fontSize: 11, color: AppColors.brandOrangeDark)),
                            ],
                          ),

                          const Spacer(flex: 4),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED).withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: const Color(0xFFFFB270), width: 1.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x22FF7A00),
                                      blurRadius: 14,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.lock_rounded, size: 11, color: Color(0xFFC2410C)),
                                    SizedBox(width: 4),
                                    Text(
                                      'सेवा साथी लॉगिन (Seva Sathi Login)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFC2410C),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Field 1: मोबाइल नंबर (Mobile Number) * (Directly on canvas)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'मोबाइल नंबर (Mobile Number) *',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textHeading,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),

                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textHeading,
                              letterSpacing: 0.8,
                            ),
                            decoration: InputDecoration(
                              hintText: '98XXXXXXXX',
                              hintStyle: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 0.5,
                              ),
                              counterText: '',
                              prefixIcon: const Icon(Icons.phone_android_rounded, color: AppColors.brandOrange, size: 21),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: const BorderSide(color: Color(0xFFFED7AA), width: 1.2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: const BorderSide(color: Color(0xFFFED7AA), width: 1.2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: const BorderSide(color: AppColors.brandOrange, width: 2.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Field 2: पासवर्ड (Password) * (Directly on canvas)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'पासवर्ड (Password) *',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textHeading,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),

                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textHeading,
                            ),
                            decoration: InputDecoration(
                              hintText: 'पासवर्ड दर्ज करें',
                              hintStyle: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF94A3B8),
                              ),
                              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.brandOrange, size: 21),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  color: const Color(0xFF94A3B8),
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: const BorderSide(color: Color(0xFFFED7AA), width: 1.2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: const BorderSide(color: Color(0xFFFED7AA), width: 1.2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: const BorderSide(color: AppColors.brandOrange, width: 2.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: AppColors.brandGradient,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x38FF7A00),
                                  blurRadius: 16,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _loginWithPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'लॉगिन करें (Login)',
                                          style: TextStyle(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              );
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: double.infinity,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFFED7AA), width: 1.3),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_add_alt_1_rounded, size: 18, color: Color(0xFFEA580C)),
                                  SizedBox(width: 8),
                                  Text(
                                    'नया पार्टनर रजिस्ट्रेशन (Register as Partner)',
                                    style: TextStyle(
                                      color: Color(0xFFEA580C),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          const Text(
                            'या',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),

                          InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('हेल्पलाइन: 1800-XXX-XXXX पर कॉल करें या support@cooperativeclap.com पर ईमेल करें')),
                              );
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.headset_mic_rounded, size: 16, color: Color(0xFF1D4ED8)),
                                SizedBox(width: 6),
                                Text(
                                  'किसी समस्या है? सहायता केंद्र से संपर्क करें',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(flex: 1),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
