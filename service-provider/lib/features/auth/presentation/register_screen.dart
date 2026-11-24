import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../verification/presentation/pending_screen.dart';
import 'location_picker_screen.dart';

class ExtraKycDocItem {
  String type;
  TextEditingController numberController;
  String? fileName;
  String? fileBase64;
  Uint8List? fileBytes;

  ExtraKycDocItem({
    required this.type,
    String initialNumber = '',
  }) : numberController = TextEditingController(text: initialNumber);
}

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
  final _addressStreetController = TextEditingController();
  final _addressPincodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  double? _selectedLatitude;
  double? _selectedLongitude;
  double _serviceRadius = 15.0;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  List<String> _selectedCategories = [];
  bool _isLoading = false;
  bool _isLoadingCategories = true;
  List<Map<String, dynamic>> _allCategories = [];

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

  final ImagePicker _picker = ImagePicker();
  String? _profilePhotoBase64;
  Uint8List? _profilePhotoBytes;

  final _bankNameController = TextEditingController();
  final _accHolderNameController = TextEditingController();
  final _accNumberController = TextEditingController();
  final _confirmAccNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _branchController = TextEditingController();

  final _aadhaarNumberController = TextEditingController();
  String? _aadhaarFileName;
  String? _aadhaarBase64;
  Uint8List? _aadhaarBytes;

  final _panNumberController = TextEditingController();
  String? _panFileName;
  String? _panBase64;
  Uint8List? _panBytes;

  final List<ExtraKycDocItem> _extraDocs = [];
  final List<String> _extraDocTypes = [
    'बैंक पासबुक (Bank Passbook)',
    'ड्राइविंग लाइसेंस (Driving License)',
    'वोटर आईडी (Voter ID)',
    'राशन कार्ड / बिजली बिल (Address Proof)',
    'व्यावसायिक / ITI प्रमाण पत्र (Skill Certificate)',
  ];

  Map<String, dynamic>? _parseMap(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone != null) {
      _phoneController.text = widget.initialPhone!;
    }
    _loadCategories();
    _loadDistricts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _addressStreetController.dispose();
    _addressPincodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bankNameController.dispose();
    _accHolderNameController.dispose();
    _accNumberController.dispose();
    _confirmAccNumberController.dispose();
    _ifscController.dispose();
    _branchController.dispose();
    _aadhaarNumberController.dispose();
    _panNumberController.dispose();
    for (final doc in _extraDocs) {
      doc.numberController.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final response = await ApiClient.dio.get(
      '',
      queryParameters: {'action': ApiEndpoints.categories},
    );
    if (!mounted) return;
    final map = _parseMap(response.data);
    if (map != null && map['success'] == true) {
      final List raw = map['data'] ?? [];
      setState(() {
        _allCategories = raw.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        _isLoadingCategories = false;
        if (_allCategories.isNotEmpty && _selectedCategories.isEmpty) {
          _selectedCategories = [_allCategories.first['name'].toString()];
        }
      });
    } else {
      setState(() => _isLoadingCategories = false);
      final msg = map?['message'] ?? 'श्रेणियां लोड करने में त्रुटि';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg.toString())));
    }
  }

  Future<void> _loadDistricts() async {
    setState(() => _loadingDistricts = true);
    final response = await ApiClient.dio.get(
      '',
      queryParameters: {'action': ApiEndpoints.districts},
    );
    if (!mounted) return;
    final map = _parseMap(response.data);
    setState(() {
      _loadingDistricts = false;
      if (map != null && map['success'] == true) {
        final List raw = map['data'] ?? [];
        _districts = raw.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
    });
  }

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
      _loadingPacs = false;
      if (_cityController.text.trim().isEmpty) {
        _cityController.text = _selectedDistrictName ?? '';
      }
    });

    final tehseelsRes = await ApiClient.dio.get('', queryParameters: {
      'action': ApiEndpoints.tehseels,
      'district_id': distId,
    });
    final blocksRes = await ApiClient.dio.get('', queryParameters: {
      'action': ApiEndpoints.blocks,
      'district_id': distId,
    });

    if (!mounted) return;
    final tehMap = _parseMap(tehseelsRes.data);
    final blkMap = _parseMap(blocksRes.data);
    setState(() {
      _loadingTehseels = false;
      _loadingBlocks = false;
      if (tehMap != null && tehMap['success'] == true) {
        final List raw = tehMap['data'] ?? [];
        _tehseels = raw.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
      if (blkMap != null && blkMap['success'] == true) {
        final List raw = blkMap['data'] ?? [];
        _blocks = raw.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
    });
  }

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
      _loadingPacs = false;
    });

    final blocksRes = await ApiClient.dio.get('', queryParameters: {
      'action': ApiEndpoints.blocks,
      'district_id': _selectedDistrictId,
      'tehseel_id': tehId,
    });

    if (!mounted) return;
    final blkMap = _parseMap(blocksRes.data);
    setState(() {
      _loadingBlocks = false;
      if (blkMap != null && blkMap['success'] == true) {
        final List raw = blkMap['data'] ?? [];
        _blocks = raw.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
    });
  }

  Future<void> _onBlockChanged(String? blkId) async {
    if (blkId == null) return;
    final blk = _blocks.firstWhere((b) => b['id'].toString() == blkId, orElse: () => {});
    setState(() {
      _selectedBlockId = blkId;
      _selectedBlockName = blk['name']?.toString() ?? '';
      _selectedPacsId = null;
      _selectedPacsName = null;
      _pacsList = [];
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
    final pacsMap = _parseMap(pacsRes.data);
    setState(() {
      _loadingPacs = false;
      if (pacsMap != null && pacsMap['success'] == true) {
        final List raw = pacsMap['data'] ?? [];
        _pacsList = raw.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
    });
  }

  void _onPacsChanged(String? pacsId) {
    if (pacsId == null) return;
    final pacs = _pacsList.firstWhere((p) => p['id'].toString() == pacsId, orElse: () => {});
    setState(() {
      _selectedPacsId = pacsId;
      _selectedPacsName = pacs['name']?.toString() ?? '';
    });
  }

  Future<void> _pickProfilePhoto() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 75,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      final base64Str = base64Encode(bytes);
      setState(() {
        _profilePhotoBytes = bytes;
        _profilePhotoBase64 = 'data:image/jpeg;base64,$base64Str';
      });
    }
  }

  Future<void> _pickAadhaarFile() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 75,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      final base64Str = base64Encode(bytes);
      setState(() {
        _aadhaarFileName = file.name;
        _aadhaarBytes = bytes;
        _aadhaarBase64 = 'data:image/jpeg;base64,$base64Str';
      });
    }
  }

  Future<void> _pickPanFile() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 75,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      final base64Str = base64Encode(bytes);
      setState(() {
        _panFileName = file.name;
        _panBytes = bytes;
        _panBase64 = 'data:image/jpeg;base64,$base64Str';
      });
    }
  }

  Future<void> _pickExtraDocFile(int index) async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 75,
    );
    if (file != null) {
      final bytes = await file.readAsBytes();
      final base64Str = base64Encode(bytes);
      setState(() {
        _extraDocs[index].fileName = file.name;
        _extraDocs[index].fileBytes = bytes;
        _extraDocs[index].fileBase64 = 'data:image/jpeg;base64,$base64Str';
      });
    }
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<PickedLocation>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialQuery: _cityController.text.trim().isNotEmpty
              ? _cityController.text.trim()
              : (_selectedDistrictName ?? ''),
          initialLatitude: _selectedLatitude,
          initialLongitude: _selectedLongitude,
          initialRadiusKm: _serviceRadius,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLatitude = result.latitude;
        _selectedLongitude = result.longitude;
        _serviceRadius = result.radiusKm;

        if (result.road != null && result.road!.isNotEmpty) {
          _addressStreetController.text = result.road!;
        } else if (result.landmark != null && result.landmark!.isNotEmpty) {
          _addressStreetController.text = result.landmark!;
        }

        final cityPart = result.city ?? result.district ?? '';
        if (cityPart.isNotEmpty) {
          _cityController.text = cityPart;
        } else {
          _cityController.text = result.address;
        }

        if (result.postcode != null && result.postcode!.isNotEmpty) {
          _addressPincodeController.text = result.postcode!;
        }
      });
    }
  }

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
                                'अपनी कार्य कुशलता के अनुसार श्रेणियां चुनें',
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'श्रेणी खोजें (Search category)...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.brandOrange),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          filled: true,
                          fillColor: const Color(0xFFFFFDFB),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFED7AA))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFED7AA))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.brandOrange, width: 1.8)),
                        ),
                        onChanged: (val) => setDialogState(() => searchQuery = val),
                      ),
                      const SizedBox(height: 12),
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
                                      final catDesc = cat['description']?.toString() ?? '';
                                      final isSelected = _selectedCategories.contains(catName);

                                      return CheckboxListTile(
                                        value: isSelected,
                                        activeColor: AppColors.brandOrange,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        title: Text(
                                          catName,
                                          style: TextStyle(
                                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                            fontSize: 14,
                                            color: isSelected ? AppColors.brandOrangeDark : AppColors.textHeading,
                                          ),
                                        ),
                                        subtitle: catDesc.isNotEmpty ? Text(catDesc, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)) : null,
                                        onChanged: (val) {
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
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'पूर्ण करें (${_selectedCategories.length} चयनित)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
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

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final city = _cityController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || phone.isEmpty || email.isEmpty || city.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया सभी अनिवार्य व्यक्तिगत फ़ील्ड भरें')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('पासवर्ड कम से कम 6 अक्षरों का होना चाहिए')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('पासवर्ड और कन्फर्म पासवर्ड मेल नहीं खाते')),
      );
      return;
    }

    if (_profilePhotoBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया अपनी प्रोफाइल फोटो अपलोड करें (Profile Photo Required)')),
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

    final bankName = _bankNameController.text.trim();
    final accNumber = _accNumberController.text.trim();
    final confirmAccNumber = _confirmAccNumberController.text.trim();
    final ifscCode = _ifscController.text.trim().toUpperCase();

    if (bankName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया बैंक का नाम दर्ज करें (Bank Name Required)')),
      );
      return;
    }

    if (accNumber.isEmpty || accNumber.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया मान्य बैंक खाता संख्या दर्ज करें (Valid Account Number Required)')),
      );
      return;
    }

    if (accNumber != confirmAccNumber) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('खाता संख्या और कन्फर्म खाता संख्या मेल नहीं खाते हैं')),
      );
      return;
    }

    if (ifscCode.isEmpty || ifscCode.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया मान्य IFSC कोड दर्ज करें (Valid IFSC Code Required)')),
      );
      return;
    }

    final aadhaarNo = _aadhaarNumberController.text.trim();
    if (aadhaarNo.isEmpty || _aadhaarBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया आधार कार्ड संख्या एवं फोटो दोनों अपलोड करें (Aadhaar Card Required)')),
      );
      return;
    }

    final panNo = _panNumberController.text.trim();
    if (panNo.isEmpty || _panBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया पैन कार्ड संख्या एवं फोटो दोनों अपलोड करें (PAN Card Required)')),
      );
      return;
    }

    final List<Map<String, dynamic>> documentsList = [
      {
        'type': 'आधार कार्ड (Aadhaar Card)',
        'number': aadhaarNo,
        'file_base64': _aadhaarBase64,
      },
      {
        'type': 'पैन कार्ड (PAN Card)',
        'number': panNo.toUpperCase(),
        'file_base64': _panBase64,
      },
    ];

    for (final extra in _extraDocs) {
      final num = extra.numberController.text.trim();
      if (extra.type.isNotEmpty && num.isNotEmpty && extra.fileBase64 != null) {
        documentsList.add({
          'type': extra.type,
          'number': num,
          'file_base64': extra.fileBase64,
        });
      }
    }

    final fullCityParts = [
      if (_addressStreetController.text.trim().isNotEmpty) _addressStreetController.text.trim(),
      city,
      if (_addressPincodeController.text.trim().isNotEmpty) 'पिन: ${_addressPincodeController.text.trim()}',
    ];
    final fullCity = fullCityParts.isNotEmpty ? fullCityParts.join(', ') : city;

    setState(() => _isLoading = true);
    final response = await ApiClient.dio.post(
      '',
      queryParameters: {'action': ApiEndpoints.register},
      data: {
        'name': name,
        'phone': phone,
        'email': email,
        'category': _selectedCategories.join(', '),
        'city': fullCity,
        'latitude': _selectedLatitude,
        'longitude': _selectedLongitude,
        'service_radius': _serviceRadius.round(),
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
        'profile_photo_base64': _profilePhotoBase64,
        'bank_name': bankName,
        'account_holder_name': name,
        'account_number': accNumber,
        'ifsc_code': ifscCode,
        'bank_branch': '',
        'documents': documentsList,
      },
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    final data = _parseMap(response.data);
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
      backgroundColor: Colors.white,
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
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 768;

                    return Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 14, vertical: 14),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 880),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeaderBanner(context),
                              const SizedBox(height: 16),

                              Container(
                                padding: EdgeInsets.all(isWide ? 28 : 18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: const Color(0xFFFED7AA), width: 1.2),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x10FF7A00),
                                      blurRadius: 26,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                              _buildHeaderAndPhotoSection(isWide),
                              const SizedBox(height: 22),
                              const Divider(color: Color(0xFFFFEDD5), height: 1, thickness: 1),
                              const SizedBox(height: 22),

                              _buildSectionHeader(
                                icon: Icons.person_rounded,
                                title: 'व्यक्तिगत विवरण (Personal Details)',
                              //  badgeText: 'अनिवार्य फ़ील्ड',
                              ),
                              const SizedBox(height: 16),
                              _buildResponsiveRow(
                                isWide,
                                _buildField('पूरा नाम (Full Name) *', _nameController, 'उदा. रमेश कुमार', Icons.person_rounded),
                                _buildField('मोबाइल नंबर (Phone Number) *', _phoneController, '98XXXXXXXX', Icons.phone_android_rounded, isPhone: true),
                              ),
                              _buildResponsiveRow(
                                isWide,
                                _buildField('ईमेल पता (Email Address) *', _emailController, 'ramesh@gmail.com', Icons.mail_rounded),
                                _buildPasswordField('पासवर्ड (Password) *', _passwordController, 'न्यूनतम 6 अक्षर', _obscurePassword, () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                }),
                              ),
                              _buildPasswordField('पासवर्ड की पुष्टि करें (Confirm Password) *', _confirmPasswordController, 'पासवर्ड पुनः दर्ज करें', _obscureConfirmPassword, () {
                                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                              }),
                              const SizedBox(height: 12),

                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFDFB),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _selectedLatitude != null ? const Color(0xFFBFDBFE) : const Color(0xFFFED7AA),
                                    width: 1.2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: _selectedLatitude != null ? const Color(0xFFEFF6FF) : const Color(0xFFFFF7ED),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                _selectedLatitude != null ? Icons.check_circle_rounded : Icons.location_on_rounded,
                                                color: _selectedLatitude != null ? AppColors.brandBlue : AppColors.brandOrange,
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'कार्यक्षेत्र व सेवा पता *',
                                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textHeading),
                                                ),
                                                Text(
                                                  _selectedLatitude != null
                                                      ? '📍 स्थान सेट: (${_selectedLatitude!.toStringAsFixed(3)}, ${_selectedLongitude!.toStringAsFixed(3)})'
                                                      : 'नक्शे पर पिन करके सटीक पता भरें',
                                                  style: TextStyle(
                                                    fontSize: 10.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: _selectedLatitude != null ? AppColors.brandBlue : AppColors.textMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        InkWell(
                                          onTap: _openLocationPicker,
                                          borderRadius: BorderRadius.circular(10),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              gradient: _selectedLatitude != null ? null : AppColors.brandGradient,
                                              color: _selectedLatitude != null ? const Color(0xFFEFF6FF) : null,
                                              borderRadius: BorderRadius.circular(10),
                                              border: _selectedLatitude != null ? Border.all(color: AppColors.brandBlue, width: 1.2) : null,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  _selectedLatitude != null ? Icons.edit_location_alt_rounded : Icons.my_location_rounded,
                                                  size: 14,
                                                  color: _selectedLatitude != null ? AppColors.brandBlue : Colors.white,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  _selectedLatitude != null ? 'स्थान बदलें' : '📍 नक्शे पर चुनें',
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: _selectedLatitude != null ? AppColors.brandBlue : Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    _buildResponsiveRow(
                                      isWide,
                                      _buildField('कार्य क्षेत्र / शहर (City / District) *', _cityController, 'उदा. लखनऊ / अयोध्या', Icons.location_city_rounded),
                                      _buildField('पिनकोड (Pincode)', _addressPincodeController, 'उदा. 226001', Icons.pin_drop_rounded, isPhone: true),
                                    ),
                                    const SizedBox(height: 8),

                                    _buildField('मकान / दुकान नं. या लैंडमार्क (House / Shop / Landmark)', _addressStreetController, 'उदा. दुकान नं. 4, बस स्टैंड के पास', Icons.storefront_rounded),
                                    const SizedBox(height: 10),

                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF7ED),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFFED7AA)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.radar_rounded, color: Color(0xFFEA580C), size: 16),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'सेवा दायरा:',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.textHeading),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.brandOrange,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${_serviceRadius.round()} km',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: SliderTheme(
                                              data: SliderTheme.of(context).copyWith(
                                                activeTrackColor: AppColors.brandOrange,
                                                inactiveTrackColor: const Color(0xFFFED7AA),
                                                thumbColor: AppColors.brandOrangeDark,
                                                overlayColor: AppColors.brandOrange.withOpacity(0.18),
                                                trackHeight: 3,
                                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                              ),
                                              child: Slider(
                                                value: _serviceRadius,
                                                min: 1,
                                                max: 50,
                                                divisions: 49,
                                                onChanged: (val) {
                                                  setState(() => _serviceRadius = val);
                                                },
                                              ),
                                            ),
                                          ),
                                          const Text(
                                            '50 km',
                                            style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildCategorySelectorField(),

                              const SizedBox(height: 22),
                              const Divider(color: Color(0xFFFFEDD5), height: 1, thickness: 1),
                              const SizedBox(height: 22),

                              _buildPacsSection(isWide),

                              const SizedBox(height: 22),
                              const Divider(color: Color(0xFFFFEDD5), height: 1, thickness: 1),
                              const SizedBox(height: 22),

                              _buildBankSection(isWide),

                              const SizedBox(height: 22),
                              const Divider(color: Color(0xFFFFEDD5), height: 1, thickness: 1),
                              const SizedBox(height: 22),

                              _buildKycSection(isWide),

                              const SizedBox(height: 28),

                              _buildSubmitButton(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const _BottomWavesBar(),
      ],
    ),
  ),
),
);
  }

  // Curved Header Banner Matching Reference Design (Image 2)
  Widget _buildHeaderBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x35FF6A00),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x18000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.handshake_rounded, color: AppColors.brandOrange, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'पार्टनर रजिस्ट्रेशन | सेवा साथी',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16.5,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Cooperative Clap',
                  style: TextStyle(
                    color: Color(0xFFFFE4D6),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(bool isWide, Widget left, Widget right) {
    if (isWide) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 16),
            Expanded(child: right),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          left,
          const SizedBox(height: 14),
          right,
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? badgeText,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(color: Color(0x33FF7A00), blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textHeading),
          ),
        ),
        if (badgeText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Text(
              badgeText,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFEA580C)),
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderAndPhotoSection(bool isWide) {
    return Container(
      padding: EdgeInsets.all(isWide ? 18 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFED7AA), width: 1.2),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Color(0x18FF7A00), blurRadius: 10, offset: Offset(0, 3)),
                  ],
                ),
                child: CircleAvatar(
                  radius: isWide ? 38 : 32,
                  backgroundColor: const Color(0xFFFFF7ED),
                  backgroundImage: _profilePhotoBytes != null ? MemoryImage(_profilePhotoBytes!) : null,
                  child: _profilePhotoBytes == null
                      ? const Icon(Icons.person_rounded, size: 38, color: Color(0xFFEA580C))
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: _pickProfilePhoto,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      gradient: AppColors.brandGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0x33000000), blurRadius: 4),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'पार्टनर फोटो (Profile Photo) *',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.textHeading),
                ),
                const SizedBox(height: 2),
                Text(
                  _profilePhotoBytes != null
                      ? '✓ फोटो चयनित (Ready to upload)'
                      : 'स्पष्ट पासपोर्ट साइज फोटो अपलोड करें',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: _profilePhotoBytes != null ? const Color(0xFF059669) : AppColors.textMuted,
                    fontWeight: _profilePhotoBytes != null ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _pickProfilePhoto,
                  icon: const Icon(Icons.cloud_upload_rounded, size: 15, color: Color(0xFFEA580C)),
                  label: Text(
                    _profilePhotoBytes != null ? 'फोटो बदलें' : 'फोटो अपलोड करें',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFEA580C)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF7ED),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFFED7AA), width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPacsSection(bool isWide) {
    return Container(
      padding: EdgeInsets.all(isWide ? 18 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFED7AA), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.account_balance_rounded,
            title: 'रजिस्टर्ड पैक्स विवरण (Registered PACS) *',
          //  badgeText: 'सहकारी नेटवर्क',
          ),
          const SizedBox(height: 16),

          _buildResponsiveRow(
            isWide,
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
          ),
          _buildResponsiveRow(
            isWide,
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
          ),

          if (_selectedPacsName != null && _selectedPacsName!.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA7F3D0), width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'सत्यापित पैक्स समिति: $_selectedPacsName',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF047857),
                      ),
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

  Widget _buildBankSection(bool isWide) {
    return Container(
      padding: EdgeInsets.all(isWide ? 18 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFED7AA), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.account_balance_wallet_rounded,
            title: 'बैंक खाता विवरण (Bank Details) *',
           // badgeText: 'भुगतान विवरण',
          ),
          const SizedBox(height: 16),
          _buildResponsiveRow(
            isWide,
            _buildField('बैंक का नाम (Bank Name) *', _bankNameController, 'उदा. State Bank of India, HDFC', Icons.business_rounded),
            _buildField('IFSC कोड (IFSC Code) *', _ifscController, 'उदा. SBIN0001234', Icons.pin_rounded),
          ),
          _buildResponsiveRow(
            isWide,
            _buildField('बैंक खाता संख्या (Account Number) *', _accNumberController, 'खाता संख्या दर्ज करें', Icons.credit_card_rounded, isPhone: true),
            _buildField('खाता संख्या पुनः दर्ज करें (Confirm Account Number) *', _confirmAccNumberController, 'खाता संख्या पुनः दर्ज करें', Icons.credit_card_rounded, isPhone: true),
          ),
        ],
      ),
    );
  }

  Widget _buildKycSection(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.verified_user_rounded,
          title: 'केवाईसी सत्यापन (KYC Verification) *',
          //badgeText: '2 अनिवार्य दस्तावेज़',
        ),
        const SizedBox(height: 16),

        _buildDocumentCard(
          docTitle: '1. आधार कार्ड (Aadhaar Card) *',
          icon: Icons.badge_rounded,
          numberController: _aadhaarNumberController,
          numberHint: '12 अंकों का आधार नंबर दर्ज करें',
          isNumeric: true,
          fileName: _aadhaarFileName,
          fileBytes: _aadhaarBytes,
          onPickFile: _pickAadhaarFile,
          isWide: isWide,
        ),
        const SizedBox(height: 14),

        _buildDocumentCard(
          docTitle: '2. पैन कार्ड (PAN Card) *',
          icon: Icons.credit_card_rounded,
          numberController: _panNumberController,
          numberHint: '10 अक्षरों का पैन नंबर (उदा. ABCDE1234F)',
          fileName: _panFileName,
          fileBytes: _panBytes,
          onPickFile: _pickPanFile,
          isWide: isWide,
        ),

        if (_extraDocs.isNotEmpty) ...[
          const SizedBox(height: 14),
          ..._extraDocs.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'अतिरिक्त दस्तावेज़ #${idx + 1}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textHeading),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                        onPressed: () {
                          setState(() {
                            item.numberController.dispose();
                            _extraDocs.removeAt(idx);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: item.type,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      labelText: 'दस्तावेज़ का प्रकार चुनें',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFED7AA))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFFED7AA))),
                    ),
                    items: _extraDocTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => item.type = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildDocumentCard(
                    docTitle: item.type,
                    icon: Icons.description_rounded,
                    numberController: item.numberController,
                    numberHint: 'दस्तावेज़ संख्या दर्ज करें',
                    fileName: item.fileName,
                    fileBytes: item.fileBytes,
                    onPickFile: () => _pickExtraDocFile(idx),
                    isWide: isWide,
                    hideCardBorder: true,
                  ),
                ],
              ),
            );
          }),
        ],

        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _extraDocs.add(ExtraKycDocItem(type: _extraDocTypes.first));
              });
            },
            icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.brandOrange),
            label: const Text(
              '+ अन्य अतिरिक्त दस्तावेज़ जोड़ें (वैकल्पिक)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.brandOrangeDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard({
    required String docTitle,
    required IconData icon,
    required TextEditingController numberController,
    required String numberHint,
    required String? fileName,
    required Uint8List? fileBytes,
    required VoidCallback onPickFile,
    required bool isWide,
    bool isNumeric = false,
    bool hideCardBorder = false,
  }) {
    final hasFile = fileBytes != null;

    final numberField = TextField(
      controller: numberController,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: numberHint,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.brandOrange, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: const Color(0xFFFFFDFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFFED7AA))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFFED7AA))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.brandOrange, width: 1.8)),
      ),
    );

    final uploadBox = InkWell(
      onTap: onPickFile,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: hasFile ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFile ? const Color(0xFFA7F3D0) : const Color(0xFFFED7AA),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasFile ? Icons.check_circle_rounded : Icons.cloud_upload_rounded,
              color: hasFile ? const Color(0xFF059669) : AppColors.brandOrange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasFile ? (fileName ?? 'अपलोड तैयार') : 'फ़ाइल / फोटो अपलोड करें',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: hasFile ? FontWeight.bold : FontWeight.w600,
                  color: hasFile ? const Color(0xFF047857) : AppColors.textSubheading,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: hasFile ? const Color(0xFFD1FAE5) : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: hasFile ? const Color(0xFFA7F3D0) : const Color(0xFFFED7AA)),
              ),
              child: Text(
                hasFile ? 'बदलें' : 'अपलोड',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: hasFile ? const Color(0xFF047857) : AppColors.brandOrangeDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (hideCardBorder) {
      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: numberField),
            const SizedBox(width: 14),
            Expanded(flex: 5, child: uploadBox),
          ],
        );
      }
      return Column(
        children: [
          numberField,
          const SizedBox(height: 10),
          uploadBox,
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7AA), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                docTitle,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textHeading),
              ),
              if (hasFile)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Ready',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: numberField),
                const SizedBox(width: 14),
                Expanded(flex: 5, child: uploadBox),
              ],
            )
          else ...[
            numberField,
            const SizedBox(height: 10),
            uploadBox,
          ],
        ],
      ),
    );
  }

  Widget _buildCategorySelectorField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'सेवा श्रेणियां (Skills / Categories) *',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textHeading),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: _openMultiSelectDialog,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.category_rounded, color: AppColors.brandOrange, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedCategories.isEmpty
                        ? 'श्रेणियां चुनें (Select Categories)'
                        : '${_selectedCategories.length} श्रेणियां: ${_selectedCategories.join(", ")}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _selectedCategories.isEmpty ? AppColors.textMuted : AppColors.textHeading,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down_rounded, color: AppColors.brandOrange, size: 24),
              ],
            ),
          ),
        ),
        if (_selectedCategories.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _selectedCategories.map((cat) {
              return Chip(
                label: Text(cat, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFEA580C))),
                backgroundColor: const Color(0xFFFFF7ED),
                deleteIcon: const Icon(Icons.cancel_rounded, size: 15, color: Color(0xFFEA580C)),
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
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFFFED7AA)),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, IconData icon, {bool isPhone = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textHeading)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            prefixIcon: Icon(icon, color: AppColors.brandOrange, size: 20),
            filled: true,
            fillColor: const Color(0xFFFFFDFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFFED7AA))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFFED7AA))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.brandOrange, width: 1.8)),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, String hint, bool obscureText, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textHeading)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.brandOrange, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: const Color(0xFF94A3B8),
                size: 20,
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: const Color(0xFFFFFDFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFFED7AA))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFFED7AA))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.brandOrange, width: 1.8)),
          ),
        ),
      ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textHeading)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: safeValue,
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
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: onChanged == null ? const Color(0xFFF8FAFC) : const Color(0xFFFFFDFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFFED7AA))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: onChanged == null ? const Color(0xFFE2E8F0) : const Color(0xFFFED7AA))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.brandOrange, width: 1.8)),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40FF6A00),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'रजिस्टर करें (Register)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ],
              ),
      ),
    );
  }
}

class _BottomWavesBar extends StatelessWidget {
  const _BottomWavesBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      width: double.infinity,
      child: CustomPaint(
        painter: _WavePainter(),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bluePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width * 0.55, size.height));

    final bluePath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.18, 0, size.width * 0.38, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.48, size.height * 0.9, size.width * 0.6, size.height)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    final orangePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF7A00), Color(0xFFFF5200)],
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
      ).createShader(Rect.fromLTWH(size.width * 0.4, 0, size.width * 0.6, size.height));

    final orangePath = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(size.width, size.height * 0.15)
      ..quadraticBezierTo(size.width * 0.8, 0, size.width * 0.55, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.95, size.width * 0.38, size.height)
      ..close();
    canvas.drawPath(orangePath, orangePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
