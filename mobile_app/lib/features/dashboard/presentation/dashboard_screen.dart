import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _dashData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    try {
      final token = await ApiClient.getToken();
      final response = await ApiClient.dio.get(
        '',
        queryParameters: {'action': ApiEndpoints.dashboard},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success'] == true) {
        setState(() {
          _dashData = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Profile Modal BottomSheet with 2-3 Future Options
  void _showProfileModal() {
    final provider = _dashData?['provider'];
    final name = (provider?['name'] as String?) ?? 'पार्टनर';
    final category = (provider?['category'] as String?) ?? '';
    final city = (provider?['city'] as String?) ?? '';

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
                // Profile Avatar & Info
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
                          Text(
                            name,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.black87),
                          ),
                          Text(
                            '$category • $city',
                            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '✓ सत्यापित सेवा साथी (Verified)',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
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

                // 2-3 Future Options requested by user
                _buildProfileOption(
                  icon: Icons.person_outline_rounded,
                  title: 'मेरी प्रोफाइल (My Profile)',
                  subtitle: 'व्यक्तिगत जानकारी एवं कार्य अनुभव',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showProfileDetailsDialog(provider);
                  },
                ),
                _buildProfileOption(
                  icon: Icons.badge_outlined,
                  title: 'केवाईसी एवं दस्तावेज़ (KYC & Documents)',
                  subtitle: 'आधार, पैन एवं सत्यापन स्थिति',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showKycDetailsDialog(provider);
                  },
                ),
                _buildProfileOption(
                  icon: Icons.headset_mic_outlined,
                  title: 'सेटिंग्स एवं सहायता (Settings & Support)',
                  subtitle: 'ऐप सेटिंग्स एवं 24x7 पार्टनर हेल्पलाइन',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showSupportDetailsDialog();
                  },
                ),

                const Divider(height: 16),

                // Logout Tile
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFFEE2E2),
                    child: Icon(Icons.logout_rounded, color: Colors.red, size: 18),
                  ),
                  title: const Text(
                    'लॉगआउट (Logout)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.red),
                  ),
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

  Widget _buildProfileOption({
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

  void _showProfileDetailsDialog(Map<String, dynamic>? provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.person, color: AppColors.brandOrange),
            SizedBox(width: 8),
            Text('मेरी प्रोफाइल विवरण', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogRow('पूरा नाम', provider?['name'] ?? '-'),
            _buildDialogRow('मोबाइल', '+91 ${provider?['phone'] ?? '-'}'),
            _buildDialogRow('ईमेल', provider?['email'] ?? '-'),
            _buildDialogRow('सेवा श्रेणियां', provider?['category'] ?? '-'),
            _buildDialogRow('कार्य क्षेत्र', provider?['city'] ?? '-'),
            _buildDialogRow('अनुभव', '${provider?['experience_years'] ?? 1} वर्ष'),
            _buildDialogRow('आईडी प्रकार', (provider?['id_type'] ?? 'aadhaar').toString().toUpperCase()),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: const Border(left: BorderSide(color: AppColors.brandOrange, width: 3)),
              ),
              child: const Text(
                'भविष्य में प्रोफाइल एडिट करने की सुविधा सक्रिय होगी।',
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('बंद करें', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandOrange)),
          ),
        ],
      ),
    );
  }

  void _showKycDetailsDialog(Map<String, dynamic>? provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.badge, color: Color(0xFF059669)),
            SizedBox(width: 8),
            Text('केवाईसी एवं दस्तावेज़', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogRow('दस्तावेज़ प्रकार', (provider?['id_type'] ?? 'aadhaar').toString().toUpperCase()),
            _buildDialogRow('सत्यापन स्थिति', '✓ सत्यापित (Verified)'),
            _buildDialogRow('सत्यापन स्तर', 'एडमिन स्वीकृत (Level 1)'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, size: 16, color: Color(0xFF047857)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'आपके सभी दस्तावेज़ एन्क्रिप्टेड और सुरक्षित हैं।',
                      style: TextStyle(fontSize: 11, color: Color(0xFF047857), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ठीक है', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandOrange)),
          ),
        ],
      ),
    );
  }

  void _showSupportDetailsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.headset_mic, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text('सेटिंग्स एवं 24x7 सहायता', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('पार्टनर टोल-फ्री हेल्पलाइन', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textHeading)),
                  SizedBox(height: 4),
                  Text('1800-889-CLAP (2527)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.brandOrangeDark)),
                  Text('सोमवार - रविवार (24x7 सेवा)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text('व्हाट्सएप: +91 98765 43210\nईमेल: partner@cooperativeclap.com', style: TextStyle(fontSize: 12, height: 1.4)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('बंद करें', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.brandOrange)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black87)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      // RICH POLISHED APP HEADER BAR
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

                  // Right Action: Profile Option with Avatar & Dropdown
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
                              ((_dashData?['provider']?['name'] as String?) ?? 'P')[0].toUpperCase(),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brandOrange))
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exact Figma "नमस्ते 🙏" Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(color: Color(0x4DFF7A00), blurRadius: 24, offset: Offset(0, 10)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'नमस्ते 🙏',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'आपकी सेवा के लिए तैयार • प्रमाणित सेवा साथी',
                              style: TextStyle(fontSize: 13, color: Color(0xFFFFEDD5)),
                            ),
                            const SizedBox(height: 14),

                            // Requested Message
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(50),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withAlpha(90)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _dashData?['welcome_message'] ?? 'Thank you for joining CP Clap, we will serve soon',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Provider Profile Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 22,
                              backgroundColor: Color(0xFFFFF7ED),
                              child: Icon(Icons.verified_user_rounded, color: AppColors.brandOrange),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _dashData?['provider']?['name'] ?? 'पार्टनर नाम',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                  ),
                                  Text(
                                    '${_dashData?['provider']?['category'] ?? ''} • ${_dashData?['provider']?['city'] ?? ''}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(10)),
                              child: const Text('सक्रिय साथी', style: TextStyle(color: Color(0xFF047857), fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Stats Row
                      Row(
                        children: [
                          _buildStatCard('आज की कमाई', '₹0.00'),
                          const SizedBox(width: 10),
                          _buildStatCard('पूर्ण कार्य', '0'),
                          const SizedBox(width: 10),
                          _buildStatCard('रेटिंग', '5.0 ★'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
