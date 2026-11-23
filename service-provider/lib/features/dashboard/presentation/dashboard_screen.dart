import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/login_screen.dart';
import '../../profile/presentation/profile_screen.dart';

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
    final token = await ApiClient.getToken();
    final response = await ApiClient.dio.get(
      '',
      queryParameters: {'action': ApiEndpoints.dashboard},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (response.data != null && response.data['success'] == true) {
        _dashData = response.data['data'];
      }
    });

    if (response.data == null || response.data['success'] != true) {
      final msg = response.data?['message'] ?? 'डैशबोर्ड लोड नहीं हो सका';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.toString())),
      );
    }
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

                  // Right Action: Profile Option with Avatar (Navigates to Full Page)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(provider: _dashData?['provider']),
                        ),
                      );
                    },
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
                          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.brandOrange, size: 13),
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
          : Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                    _dashData?['provider']?['name']?.toString() ?? '',
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
                          _buildStatCard('आज की कमाई', _dashData?['metrics']?['today_earnings']?.toString() ?? '₹0.00'),
                          const SizedBox(width: 10),
                          _buildStatCard('पूर्ण कार्य', _dashData?['metrics']?['completed_jobs']?.toString() ?? '0'),
                          const SizedBox(width: 10),
                          _buildStatCard('रेटिंग', '${_dashData?['metrics']?['rating'] ?? '5.0'} ★'),
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
