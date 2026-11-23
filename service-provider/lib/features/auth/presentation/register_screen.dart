import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_endpoints.dart';
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

  // Multi-select categories
  List<String> _selectedCategories = ['Electrician'];
  bool _isLoading = false;

  final List<Map<String, dynamic>> _allCategories = [
    {'name': 'Electrician', 'label': 'इलेक्ट्रिशियन (Electrician)', 'icon': Icons.bolt_rounded},
    {'name': 'Plumber', 'label': 'प्लंबर (Plumber)', 'icon': Icons.plumbing_rounded},
    {'name': 'AC & Appliance', 'label': 'एसी व उपकरण (AC & Appliance)', 'icon': Icons.ac_unit_rounded},
    {'name': 'Home Cleaning', 'label': 'होम क्लीनिंग (Home Cleaning)', 'icon': Icons.cleaning_services_rounded},
    {'name': 'Painter', 'label': 'पेंटर (Painter)', 'icon': Icons.format_paint_rounded},
    {'name': 'Carpenter', 'label': 'कारपेंटर (Carpenter)', 'icon': Icons.handyman_rounded},
    {'name': 'Salon & Grooming', 'label': 'सैलून व ग्रूमिंग (Salon & Grooming)', 'icon': Icons.content_cut_rounded},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone != null) {
      _phoneController.text = widget.initialPhone!;
    }
  }

  // Open Multi-Select Modal Dialog
  void _openMultiSelectDropdown() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                maxWidth: 520,
              ),
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 500) / 2 : 12,
                right: MediaQuery.of(context).size.width > 600 ? (MediaQuery.of(context).size.width - 500) / 2 : 12,
                bottom: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 25, offset: Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'सेवा श्रेणियां चुनें',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textHeading),
                            ),
                            Text(
                              'आप एक से अधिक श्रेणियां चुन सकते हैं (Multi-Select)',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.grey),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Category Options
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      itemCount: _allCategories.length,
                      itemBuilder: (context, i) {
                        final cat = _allCategories[i];
                        final catName = cat['name'] as String;
                        final isSelected = _selectedCategories.contains(catName);

                        return CheckboxListTile(
                          value: isSelected,
                          activeColor: AppColors.brandOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          secondary: CircleAvatar(
                            radius: 18,
                            backgroundColor: isSelected ? const Color(0xFFFFEDD5) : const Color(0xFFF3F4F6),
                            child: Icon(cat['icon'] as IconData, size: 18, color: isSelected ? AppColors.brandOrange : Colors.grey),
                          ),
                          title: Text(
                            cat['label'] as String,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                              color: isSelected ? AppColors.textHeading : Colors.black87,
                            ),
                          ),
                          onChanged: (bool? val) {
                            setModalState(() {
                              if (val == true) {
                                if (!_selectedCategories.contains(catName)) {
                                  _selectedCategories.add(catName);
                                }
                              } else {
                                if (_selectedCategories.length > 1) {
                                  _selectedCategories.remove(catName);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('कम से कम 1 श्रेणी चुनना आवश्यक है')),
                                  );
                                }
                              }
                            });
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),

                  // Done Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          'पूर्ण करें (${_selectedCategories.length} चयनित)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया कम से कम एक श्रेणी चुनें')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await ApiClient.dio.post(
        '',
        queryParameters: {'action': ApiEndpoints.register},
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'category': _selectedCategories.join(', '), // sends comma-separated or array
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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textHeading),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'पार्टनर रजिस्ट्रेशन',
          style: TextStyle(color: AppColors.textHeading, fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: Center(
        // RESPONSIVE CONSTRAINED CONTAINER: Looks beautiful on Desktop & Mobile!
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderLight.withOpacity(0.6)),
                boxShadow: const [
                  BoxShadow(color: Color(0x14FF7A00), blurRadius: 30, offset: Offset(0, 10)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField('पूरा नाम (Full Name) *', _nameController, 'रमेश कुमार', Icons.person_rounded),
                  _buildField('मोबाइल नंबर (Phone) *', _phoneController, '98XXXXXXXX', Icons.phone_android_rounded, isPhone: true),
                  _buildField('ईमेल पता (Email) *', _emailController, 'ramesh@gmail.com', Icons.email_rounded),

                  // MULTI-SELECT CATEGORY DROPDOWN
                  const Text(
                    'सेवा श्रेणियां चुनें (Select Skills - Multiple) *',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: _openMultiSelectDropdown,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.brandOrange, width: 1.5),
                        boxShadow: const [
                          BoxShadow(color: Color(0x0DFF7A00), blurRadius: 8, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.category_rounded, color: AppColors.brandOrange, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedCategories.isEmpty
                                  ? 'श्रेणियां चुनें (Click to Select)'
                                  : '${_selectedCategories.length} श्रेणियां चयनित: ${_selectedCategories.join(", ")}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: _selectedCategories.isEmpty ? Colors.grey : AppColors.textHeading,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down_circle_rounded, color: AppColors.brandOrange, size: 22),
                        ],
                      ),
                    ),
                  ),

                  // Selected Chips Display
                  if (_selectedCategories.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _selectedCategories.map((cat) {
                        return Chip(
                          label: Text(cat, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.brandOrangeDark)),
                          backgroundColor: const Color(0xFFFFEDD5),
                          deleteIcon: const Icon(Icons.cancel_rounded, size: 16, color: AppColors.brandOrangeDark),
                          onDeleted: () {
                            if (_selectedCategories.length > 1) {
                              setState(() => _selectedCategories.remove(cat));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('कम से कम 1 श्रेणी अनिवार्य है')),
                              );
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: AppColors.borderLight),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 14),

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
                        elevation: 4,
                        shadowColor: const Color(0x66FF7A00),
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
