import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/network/api_client.dart';
import '../../verification/presentation/pending_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String? initialPhone;
  const RegisterScreen({super.key, this.initialPhone});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedCategory = 'Electrician';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Electrician', 'icon': Icons.bolt_rounded},
    {'name': 'Plumber', 'icon': Icons.plumbing_rounded},
    {'name': 'AC & Appliance', 'icon': Icons.ac_unit_rounded},
    {'name': 'Home Cleaning', 'icon': Icons.cleaning_services_rounded},
    {'name': 'Painter', 'icon': Icons.format_paint_rounded},
    {'name': 'Carpenter', 'icon': Icons.handyman_rounded},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone != null) {
      _phoneController.text = widget.initialPhone!;
    }
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final city = _cityController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || phone.isEmpty || email.isEmpty || city.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया सभी अनिवार्य फ़ील्ड भरें')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.dio.post(
        '',
        queryParameters: {'action': 'register'},
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'category': _selectedCategory,
          'city': city,
          'password': password,
          'experience_years': 3,
        },
      );

      final data = response.data;
      if (data['success'] == true) {
        final token = data['data']['auth_token'];
        await ApiClient.saveToken(token);

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => PendingScreen(phone: phone)),
          (route) => false,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'रजिस्ट्रेशन विफल')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('नेटवर्क त्रुटि')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textHeading),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'पार्टनर रजिस्ट्रेशन',
          style: TextStyle(color: AppColors.textHeading, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight.withOpacity(0.6)),
            boxShadow: const [
              BoxShadow(color: Color(0x14FF7A00), blurRadius: 20, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField('पूरा नाम (Full Name) *', _nameController, 'रमेश कुमार', Icons.person_rounded),
              _buildField('मोबाइल नंबर (Phone) *', _phoneController, '98XXXXXXXX', Icons.phone_android_rounded, isPhone: true),
              _buildField('ईमेल पता (Email) *', _emailController, 'ramesh@gmail.com', Icons.email_rounded),

              const Text('सेवा श्रेणी चुनें (Select Skill) *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSel = _selectedCategory == cat['name'];
                  return ChoiceChip(
                    label: Text(cat['name']),
                    selected: isSel,
                    selectedColor: const Color(0xFFFFEDD5),
                    backgroundColor: const Color(0xFFFFFBF7),
                    avatar: Icon(cat['icon'], size: 16, color: isSel ? AppColors.brandOrange : Colors.grey),
                    labelStyle: TextStyle(
                      color: isSel ? AppColors.brandOrangeDark : Colors.black87,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(color: isSel ? AppColors.brandOrange : AppColors.borderLight),
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat['name']);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              _buildField('शहर / कार्य क्षेत्र (City) *', _cityController, 'नोएडा / दिल्ली', Icons.location_on_rounded),
              _buildField('पासवर्ड (Password) *', _passwordController, 'न्यूनतम 6 अक्षर', Icons.lock_rounded, isPassword: true),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('रजिस्ट्रेशन सबमिट करें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, IconData icon, {bool isPhone = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: AppColors.brandOrange, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderInput)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.brandOrange, width: 2)),
            ),
          ),
        ],
      ),
    );
  }
}
