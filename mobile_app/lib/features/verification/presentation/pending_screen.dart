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
  Map<String, dynamic>? _providerData;

  @override
  void initState() {
    super.initState();
    _fetchProviderInfo();
  }

  Future<void> _fetchProviderInfo() async {
    try {
      final token = await ApiClient.getToken();
      final response = await ApiClient.dio.get(
        '',
        queryParameters: {'action': ApiEndpoints.status},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['success'] == true) {
        setState(() {
          _providerData = response.data['data'];
        });
      }
    } catch (_) {}
  }

  void _showProfileModal() {
    final name = (_providerData?['name'] as String?) ?? 'पार्टनर';
    final category = (_providerData?['category'] as String?) ?? 'सेवा साथी';
    final city = (_providerData?['city'] as String?) ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 480),
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width > 500 ? (MediaQuery.of(context).size.width - 440) / 2 : 12,
            right: MediaQuery.of(context).size.width > 500 ? (MediaQuery.of(context).size.width - 440) / 2 : 12,
            bottom: 24,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 30, offset: Offset(0, 10)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFFFEDD5),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'P',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.brandOrangeDark),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black87)),
                          Text('$category • $city', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'सत्यापन प्रक्रियाधीन (Under Review)',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // 3 Options
                _buildOptionTile(
                  icon: Icons.person_outline_rounded,
                  title: 'मेरी प्रोफाइल (My Profile)',
                  subtitle: 'व्यक्तिगत जानकारी एवं कार्य अनुभव',
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('नाम: $name | मोबाइल: ${_providerData?['phone'] ?? widget.phone ?? '-'}')),
                    );
                  },
                ),
                _buildOptionTile(
                  icon: Icons.badge_outlined,
                  title: 'केवाईसी एवं दस्तावेज़ (KYC & Documents)',
                  subtitle: 'आधार, पैन एवं सत्यापन स्थिति',
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('दस्तावेज़ समीक्षाधीन (Under Review)')),
                    );
                  },
                ),
                _buildOptionTile(
                  icon: Icons.headset_mic_outlined,
                  title: 'सेटिंग्स एवं सहायता (Settings & Support)',
                  subtitle: '24x7 हेल्पलाइन: 1800-889-CLAP',
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('पार्टनर हेल्पलाइन: 1800-889-CLAP')),
                    );
                  },
                ),

                const Divider(height: 16),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFFEE2E2),
                    child: Icon(Icons.logout_rounded, color: Colors.red, size: 18),
                  ),
                  title: const Text('लॉगआउट (Logout)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ApiClient.clearAuth();
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: const Color(0xFFFFF7ED),
        child: Icon(icon, color: AppColors.brandOrange, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.black87)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

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
    final name = (_providerData?['name'] as String?) ?? 'पार्टनर';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFFED7AA), width: 1.5)),
            boxShadow: [
              BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 3)),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Brand: Logo + Name
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.brandGradient,
                          boxShadow: [
                            BoxShadow(color: Color(0x33FF7A00), blurRadius: 8, offset: Offset(0, 2)),
                          ],
                        ),
                        child: const Icon(Icons.handshake_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cooperative Clap',
                            style: TextStyle(
                              color: AppColors.textHeading,
                              fontWeight: FontWeight.w900,
                              fontSize: 16.5,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'पार्टनर पोर्टल (Partner Portal)',
                            style: TextStyle(
                              color: AppColors.brandOrangeDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Right Action: Profile Option
                  InkWell(
                    onTap: _showProfileModal,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: AppColors.brandOrange,
                            child: Text(
                              initial,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'प्रोफाइल',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textHeading,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down_rounded, color: AppColors.brandOrange, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
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
    ),
      ),
    );
  }
}
