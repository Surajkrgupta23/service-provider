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
  List<String> _selectedCategories = [];
  bool _isLoading = false;
  bool _isLoadingCategories = true;
  List<Map<String, dynamic>> _allCategories = [];

  // PACS & Location Hierarchy State
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _tehseels = [];
  List<Map<String, dynamic>> _blocks = [];
  List<Map<String, dynamic>> _pacsList = [];

  String? _selectedDistrictId;
  String? _selectedDistrictName;
  String? _selectedTehseelId;
  String? _selectedTehseelName;
  String? _selectedBlockId;
  String? _selectedBlockName;
  String? _selectedPacsId;
  String? _selectedPacsName;

  bool _loadingDistricts = false;
  bool _loadingTehseels = false;
  bool _loadingBlocks = false;
  bool _loadingPacs = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone != null) {
      _phoneController.text = widget.initialPhone!;
    }
    _loadCategories();
    _loadDistricts();
  }

  // Load Categories from Backend API
  Future<void> _loadCategories() async {
    final response = await ApiClient.dio.get(
      '',
      queryParameters: {'action': ApiEndpoints.categories},
    );
    if (!mounted) return;
    if (response.data != null && response.data['success'] == true) {
      final List raw = response.data['data'] ?? [];
      setState(() {
        _allCategories = raw.map((item) => Map<String, dynamic>.from(item)).toList();
        _isLoadingCategories = false;
        if (_allCategories.isNotEmpty && _selectedCategories.isEmpty) {
          _selectedCategories = [_allCategories.first['name'].toString()];
        }
      });
    } else {
      setState(() => _isLoadingCategories = false);
      final msg = response.data?['message'] ?? 'श्रेणियां लोड करने में त्रुटि';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.toString())),
      );
    }
  }

  // Load Districts from Backend API
  Future<void> _loadDistricts() async {
    setState(() => _loadingDistricts = true);
    final response = await ApiClient.dio.get(
      '',
      queryParameters: {'action': ApiEndpoints.districts},
    );
    if (!mounted) return;
    setState(() => _loadingDistricts = false);
    if (response.data != null && response.data['success'] == true) {
      final List raw = response.data['data'] ?? [];
      setState(() {
        _districts = raw.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    }
  }

  // On District Changed
  Future<void> _onDistrictChanged(String? distId) async {
    if (distId == null) return;
    final dist = _districts.firstWhere((d) => d['id'].toString() == distId, orElse: () => {});
    setState(() {
      _selectedDistrictId = distId;
      _selectedDistrictName = dist['name']?.toString() ?? '';
      _selectedTehseelId = null;
      _selectedTehseelName = null;
      _selectedBlockId = null;
      _selectedBlockName = null;
      _selectedPacsId = null;
      _selectedPacsName = null;
      _tehseels = [];
      _blocks = [];
      _pacsList = [];
      _loadingTehseels = true;
      _loadingBlocks = true;
      _loadingPacs = true;
      if (_cityController.text.trim().isEmpty) {
        _cityController.text = _selectedDistrictName ?? '';
      }
    });

    // Fetch Tehseels, Blocks, and PACS concurrently
    final tehseelsRes = await ApiClient.dio.get('', queryParameters: {
      'action': ApiEndpoints.tehseels,
      'district_id': distId,
    });
    final blocksRes = await ApiClient.dio.get('', queryParameters: {
      'action': ApiEndpoints.blocks,
      'district_id': distId,
    });
    final pacsRes = await ApiClient.dio.get('', queryParameters: {
      'action': ApiEndpoints.pacs,
      'district_id': distId,
    });

    if (!mounted) return;
    setState(() {
      _loadingTehseels = false;
      _loadingBlocks = false;
      _loadingPacs = false;

      if (tehseelsRes.data != null && tehseelsRes.data['success'] == true) {
        final List raw = tehseelsRes.data['data'] ?? [];
        _tehseels = raw.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      if (blocksRes.data != null && blocksRes.data['success'] == true) {
        final List raw = blocksRes.data['data'] ?? [];
        _blocks = raw.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      if (pacsRes.data != null && pacsRes.data['success'] == true) {
        final List raw = pacsRes.data['data'] ?? [];
        _pacsList = raw.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    });
  }

  // On Tehseel Changed
  Future<void> _onTehseelChanged(String? tehId) async {
    if (tehId == null) return;
    final teh = _tehseels.firstWhere((t) => t['id'].toString() == tehId, orElse: () => {});
    setState(() {
      _selectedTehseelId = tehId;
      _selectedTehseelName = teh['name']?.toString() ?? '';
      _selectedBlockId = null;
      _selectedBlockName = null;
      _selectedPacsId = null;
      _selectedPacsName = null;
      _loadingBlocks = true;
      _loadingPacs = true;
    });

    final blocksRes = await ApiClient.dio.get('', queryParameters: {
      'action': ApiEndpoints.blocks,
      'district_id': _selectedDistrictId,
      'tehseel_id': tehId,
    });
    final pacsRes = await ApiClient.dio.get('', queryParameters: {
      'action': ApiEndpoints.pacs,
      'district_id': _selectedDistrictId,
      'tehseel_id': tehId,
    });

    if (!mounted) return;
    setState(() {
      _loadingBlocks = false;
      _loadingPacs = false;
      if (blocksRes.data != null && blocksRes.data['success'] == true) {
        final List raw = blocksRes.data['data'] ?? [];
        _blocks = raw.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      if (pacsRes.data != null && pacsRes.data['success'] == true) {
        final List raw = pacsRes.data['data'] ?? [];
        _pacsList = raw.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    });
  }

  // On Block Changed
  Future<void> _onBlockChanged(String? blkId) async {
    if (blkId == null) return;
    final blk = _blocks.firstWhere((b) => b['id'].toString() == blkId, orElse: () => {});
    setState(() {
      _selectedBlockId = blkId;
      _selectedBlockName = blk['name']?.toString() ?? '';
      _selectedPacsId = null;
      _selectedPacsName = null;
      _loadingPacs = true;
      if (_selectedDistrictName != null && _selectedDistrictName!.isNotEmpty) {
        _cityController.text = '${_selectedDistrictName!} - ${_selectedBlockName!}';
      }
    });

    final pacsRes = await ApiClient.dio.get('', queryParameters: {
      'action': ApiEndpoints.pacs,
      'district_id': _selectedDistrictId,
      'block_id': blkId,
    });

    if (!mounted) return;
    setState(() {
      _loadingPacs = false;
      if (pacsRes.data != null && pacsRes.data['success'] == true) {
        final List raw = pacsRes.data['data'] ?? [];
        _pacsList = raw.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    });
  }

  // On PACS Changed
  void _onPacsChanged(String? pacsId) {
    if (pacsId == null) return;
    final pacs = _pacsList.firstWhere((p) => p['id'].toString() == pacsId, orElse: () => {});
    setState(() {
      _selectedPacsId = pacsId;
      _selectedPacsName = pacs['name']?.toString() ?? '';
    });
  }

  // Open Multi-Select Modal Dialog (Fixed for Web & Mobile with Search & Clear Scroll)
  void _openMultiSelectDialog() {
    String searchQuery = '';
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filtered = _allCategories.where((c) {
              final name = (c['name'] ?? '').toString().toLowerCase();
              final desc = (c['description'] ?? '').toString().toLowerCase();
              return name.contains(searchQuery.toLowerCase()) || desc.contains(searchQuery.toLowerCase());
            }).toList();

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'सेवा श्रेणियां चुनें',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textHeading),
                              ),
                              Text(
                                'एक या अधिक श्रेणियां चुनें (Multi-Select)',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.grey),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Search box
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'श्रेणी खोजें (Search category)...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.brandOrange),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                        onChanged: (val) {
                          setDialogState(() => searchQuery = val);
                        },
                      ),
                      const SizedBox(height: 12),

                      // Category List
                      Flexible(
                        child: _isLoadingCategories
                            ? const Center(child: CircularProgressIndicator(color: AppColors.brandOrange))
                            : filtered.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text('कोई श्रेणी नहीं मिली', style: TextStyle(color: Colors.grey)),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: filtered.length,
                                    itemBuilder: (context, i) {
                                      final cat = filtered[i];
                                      final catName = cat['name']?.toString() ?? '';
                                      final catIcon = cat['icon']?.toString() ?? '🛠️';
                                      final isSelected = _selectedCategories.contains(catName);

                                      return CheckboxListTile(
                                        value: isSelected,
                                        activeColor: AppColors.brandOrange,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        secondary: CircleAvatar(
                                          radius: 18,
                                          backgroundColor: isSelected ? const Color(0xFFFFEDD5) : const Color(0xFFF3F4F6),
                                          child: Text(catIcon, style: const TextStyle(fontSize: 16)),
                                        ),
                                        title: Text(
                                          catName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                            color: isSelected ? AppColors.textHeading : Colors.black87,
                                          ),
                                        ),
                                        subtitle: cat['description'] != null && cat['description'].toString().isNotEmpty
                                            ? Text(
                                                cat['description'].toString(),
                                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : null,
                                        onChanged: (bool? val) {
                                          setDialogState(() {
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
                      const SizedBox(height: 12),

                      // Done Button
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'पूर्ण करें (${_selectedCategories.length} चयनित)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Register Handler
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
        const SnackBar(content: Text('कृपया कम से कम एक सेवा श्रेणी चुनें')),
      );
      return;
    }

    if (_selectedDistrictId == null || _selectedBlockId == null || _selectedPacsId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया अपना जिला, ब्लॉक व पैक्स समिति चुनें (PACS Selection Required)')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final response = await ApiClient.dio.post(
      '',
      queryParameters: {'action': ApiEndpoints.register},
      data: {
        'name': name,
        'phone': phone,
        'email': email,
        'category': _selectedCategories.join(', '),
        'city': city,
        'password': password,
        'experience_years': 3,
        'district_id': _selectedDistrictId,
        'district_name': _selectedDistrictName,
        'tehseel_id': _selectedTehseelId,
        'tehseel_name': _selectedTehseelName,
        'block_id': _selectedBlockId,
        'block_name': _selectedBlockName,
        'pacs_id': _selectedPacsId,
        'pacs_name': _selectedPacsName,
      },
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    final data = response.data;
    if (data != null && data['success'] == true) {
      final token = data['data']['auth_token'];
      await ApiClient.saveToken(token);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => PendingScreen(phone: phone)),
        (route) => false,
      );
    } else {
      final msg = data?['message'] ?? 'रजिस्ट्रेशन विफल';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg.toString())),
      );
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
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

                  // MULTI-SELECT CATEGORY DROPDOWN TRIGGER
                  const Text(
                    'सेवा श्रेणियां चुनें (Select Skills - Multiple) *',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: _openMultiSelectDialog,
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
                                  ? 'श्रेणियां चुनें (Click to Select Categories)'
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
                  const SizedBox(height: 18),

                  // ================= PACS HIERARCHY SECTION =================
                  _buildPacsSection(),
                  const SizedBox(height: 8),

                  _buildField('कार्य क्षेत्र / शहर (City / Area) *', _cityController, 'नोएडा / आगरा / लखनऊ', Icons.location_on_rounded),
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

  // Build PACS Section
  Widget _buildPacsSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7AA), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_rounded, color: AppColors.brandOrange, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'रजिस्टर्ड पैक्स (Registered PACS) *',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textHeading),
                    ),
                    Text(
                      'अपना जिला, ब्लॉक व पैक्स समिति चुनें',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. District Dropdown
          _buildDropdownField(
            label: '1. जिला चुनें (Select District) *',
            hint: _loadingDistricts ? 'लोड हो रहा है...' : 'जिला चुनें',
            value: _selectedDistrictId,
            items: _districts.map((d) {
              return DropdownMenuItem<String>(
                value: d['id'].toString(),
                child: Text(d['name'].toString(), overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: _onDistrictChanged,
            isLoading: _loadingDistricts,
          ),

          // 2. Tehseel Dropdown
          _buildDropdownField(
            label: '2. तहसील चुनें (Select Tehseel)',
            hint: _selectedDistrictId == null
                ? 'पहले जिला चुनें'
                : (_loadingTehseels ? 'लोड हो रहा है...' : 'तहसील चुनें (वैकल्पिक)'),
            value: _selectedTehseelId,
            items: _tehseels.map((t) {
              return DropdownMenuItem<String>(
                value: t['id'].toString(),
                child: Text(t['name'].toString(), overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: _selectedDistrictId == null ? null : _onTehseelChanged,
            isLoading: _loadingTehseels,
          ),

          // 3. Block Dropdown
          _buildDropdownField(
            label: '3. विकास खण्ड / ब्लॉक चुनें (Select Block) *',
            hint: _selectedDistrictId == null
                ? 'पहले जिला चुनें'
                : (_loadingBlocks ? 'लोड हो रहा है...' : 'ब्लॉक चुनें'),
            value: _selectedBlockId,
            items: _blocks.map((b) {
              return DropdownMenuItem<String>(
                value: b['id'].toString(),
                child: Text(b['name'].toString(), overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: _selectedDistrictId == null ? null : _onBlockChanged,
            isLoading: _loadingBlocks,
          ),

          // 4. PACS Society Dropdown
          _buildDropdownField(
            label: '4. पंजीकृत पैक्स समिति (Registered PACS) *',
            hint: _selectedDistrictId == null
                ? 'पहले जिला व ब्लॉक चुनें'
                : (_loadingPacs
                    ? 'पैक्स लोड हो रहे हैं...'
                    : (_pacsList.isEmpty ? 'इस ब्लॉक में कोई पैक्स नहीं मिला' : 'पैक्स समिति चुनें')),
            value: _selectedPacsId,
            items: _pacsList.map((p) {
              return DropdownMenuItem<String>(
                value: p['id'].toString(),
                child: Text(p['name'].toString(), overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: _selectedDistrictId == null || _pacsList.isEmpty ? null : _onPacsChanged,
            isLoading: _loadingPacs,
          ),

          // Selected PACS confirmation info box
          if (_selectedPacsName != null && _selectedPacsName!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'चयनित पैक्स: $_selectedPacsName',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?>? onChanged,
    bool isLoading = false,
  }) {
    final hasMatchingValue = value != null && items.any((item) => item.value == value);
    final safeValue = hasMatchingValue ? value : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: safeValue,
            hint: Row(
              children: [
                if (isLoading) ...[
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brandOrange),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    hint,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: onChanged == null ? const Color(0xFFF3F4F6) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: onChanged == null ? const Color(0xFFE5E7EB) : AppColors.borderLight),
              ),
            ),
            items: items,
            onChanged: onChanged,
          ),
        ],
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
            keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              prefixIcon: Icon(icon, color: AppColors.brandOrange, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.brandOrange, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}
