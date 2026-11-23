import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic>? provider;

  const ProfileScreen({super.key, this.provider});

  @override
  Widget build(BuildContext context) {
    final name = (provider?['name'] as String?) ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '-';
    final category = (provider?['category'] as String?) ?? '-';
    final city = (provider?['city'] as String?) ?? '-';
    final phone = (provider?['phone'] as String?) ?? '-';
    final email = (provider?['email'] as String?) ?? '-';
    final exp = (provider?['experience_years'] != null) ? '${provider!['experience_years']}' : '-';
    final idType = ((provider?['id_type'] as String?) ?? 'Aadhaar').toUpperCase();
    final rawId = (provider?['id_number'] as String?) ?? '';
    final idNumber = rawId.isNotEmpty
        ? (rawId.length > 4 ? 'XXXX-XXXX-${rawId.substring(rawId.length - 4)}' : rawId)
        : 'सत्यापित डिजिटल आईडी';
    final isVerified = provider?['verification_status'] == 'verified';

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: const Color(0x1A000000),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.brandOrangeDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'मेरी प्रोफाइल (My Profile)',
          style: TextStyle(
            color: AppColors.textHeading,
            fontWeight: FontWeight.w900,
            fontSize: 16.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Hero Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: const [
                      BoxShadow(color: Color(0x14FF7A00), blurRadius: 18, offset: Offset(0, 6)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFEDD5),
                          border: Border.fromBorderSide(BorderSide(color: AppColors.brandOrange, width: 2.5)),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.brandOrangeDark),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        name,
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.black87),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$category • $city',
                        style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isVerified ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isVerified ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A)),
                        ),
                        child: Text(
                          isVerified ? '✓ सत्यापित सेवा साथी (Verified Partner)' : 'सत्यापन प्रक्रियाधीन (Under Review)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isVerified ? const Color(0xFF047857) : const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Section 1: व्यक्तिगत विवरण (Personal Details)
                _buildSectionCard(
                  title: 'व्यक्तिगत विवरण (Personal Info)',
                  icon: Icons.person_rounded,
                  iconColor: AppColors.brandOrange,
                  children: [
                    _buildInfoRow('पूरा नाम', name),
                    _buildInfoRow('मोबाइल नंबर', '+91 $phone'),
                    _buildInfoRow('ईमेल पता', email),
                    _buildInfoRow('सेवा श्रेणियां', category),
                    _buildInfoRow('कार्य क्षेत्र / शहर', city),
                    _buildInfoRow('कार्य अनुभव', '$exp वर्ष'),
                  ],
                ),
                const SizedBox(height: 12),

                // Section 2: केवाईसी एवं दस्तावेज़ (KYC & Documents)
                _buildSectionCard(
                  title: 'केवाईसी एवं दस्तावेज़ (KYC & Documents)',
                  icon: Icons.badge_rounded,
                  iconColor: const Color(0xFF059669),
                  children: [
                    _buildInfoRow('आईडी प्रकार', idType),
                    _buildInfoRow('आईडी संख्या', idNumber),
                    _buildInfoRow('सत्यापन स्तर', isVerified ? '✓ एडमिन स्वीकृत (Level 1)' : 'प्रक्रियाधीन'),
                    _buildInfoRow('डेटा सुरक्षा', '256-Bit SSL Encrypted'),
                  ],
                ),
                const SizedBox(height: 12),

                // Section 3: 2-3 Future Options
                _buildSectionCard(
                  title: 'आगामी सुविधाएं (Future Features)',
                  icon: Icons.auto_awesome_rounded,
                  iconColor: const Color(0xFFD97706),
                  children: [
                    _buildFeatureTile(
                      icon: Icons.edit_note_rounded,
                      iconBg: const Color(0xFFFFF7ED),
                      iconColor: AppColors.brandOrange,
                      title: 'प्रोफाइल संपादन (Edit Profile)',
                      subtitle: 'विवरण, फोटो व कार्य क्षेत्र बदलें',
                      tag: 'Soon',
                    ),
                    const Divider(height: 12),
                    _buildFeatureTile(
                      icon: Icons.account_balance_rounded,
                      iconBg: const Color(0xFFECFDF5),
                      iconColor: const Color(0xFF059669),
                      title: 'बैंक खाता एवं भुगतान (Bank & Payouts)',
                      subtitle: 'दैनिक कमाई का सीधा बैंक ट्रांसफर',
                      tag: 'Soon',
                    ),
                    const Divider(height: 12),
                    _buildFeatureTile(
                      icon: Icons.headset_mic_rounded,
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: '24x7 पार्टनर सहायता (Help & Support)',
                      subtitle: 'टोल-फ्री: 1800-889-CLAP • WhatsApp',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Logout Button
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ApiClient.clearAuth();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.red),
                    label: const Text(
                      'लॉगआउट (Logout)',
                      style: TextStyle(fontWeight: FontWeight.w800, color: Colors.red, fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: const Color(0xFFFEF2F2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 19),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.textHeading),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.grey, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? tag,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black87)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          if (tag != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
            )
          else
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
        ],
      ),
    );
  }
}
