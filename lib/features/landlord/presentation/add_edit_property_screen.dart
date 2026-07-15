import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/property_store.dart';
import '../../../models/property_listing.dart';
import '../../profile/presentation/edit_profile_screen.dart';

const _addOrange = Color(0xFFF57C00);
const _addOrangeStrong = Color(0xFFE06300);
const _addOrangeSoft = Color(0xFFFFF1DF);

class AddEditPropertyScreen extends StatefulWidget {
  const AddEditPropertyScreen({super.key});

  @override
  State<AddEditPropertyScreen> createState() => _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends State<AddEditPropertyScreen> {
  static const String _coverPhotoLabel = 'Listing Cover Photo (Home Preview)';

  int _currentStep = 0;

  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _unitsController = TextEditingController(text: '1');
  final _bedroomsController = TextEditingController(text: '2');
  final _bathroomsController = TextEditingController(text: '2');
  final _kitchensController = TextEditingController(text: '1');
  final _garagesController = TextEditingController(text: '1');
  final _amenitiesController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final Map<String, XFile> _capturedUnitImages = <String, XFile>{};

  String _selectedPropertyType = PropertyListing.propertyTypeOptions.first;
  bool _wifi = true;
  bool _parking = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureCompletedProfile();
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _locationController.dispose();
    _unitsController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _kitchensController.dispose();
    _garagesController.dispose();
    _amenitiesController.dispose();
    super.dispose();
  }

  Future<void> _ensureCompletedProfile() async {
    final profile = PropertyStore.instance.activeOwnerProfile;
    if (profile != null && profile.isComplete) {
      return;
    }
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Complete and save your profile before uploading properties.',
        ),
      ),
    );

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => EditProfileScreen(initialProfile: profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps();

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _onBackPressed();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFBF6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: _onBackPressed,
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1B1B)),
          ),
          title: const Text(
            'Add/Edit Property',
            style: TextStyle(
              color: _addOrangeStrong,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF1B1B1B),
                size: 30,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
              child: _StepProgress(currentStep: _currentStep),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD8B0)),
                  ),
                  child: steps[_currentStep],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _addOrangeStrong,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _currentStep == 3
                      ? (_isSaving ? 'Saving...' : 'Save Property')
                      : 'Next',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _steps() {
    return [
      _StepSection(
        title: 'Basic Information',
        children: [
          _LabeledField(
            label: 'Price',
            child: TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('440000'),
            ),
          ),
          _LabeledField(
            label: 'Property Type',
            child: DropdownButtonFormField<String>(
              initialValue: _selectedPropertyType,
              items: PropertyListing.propertyTypeOptions
                  .map(
                    (type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPropertyType = value);
                }
              },
              decoration: _inputDecoration(null),
            ),
          ),
          _LabeledField(
            label: 'Total Units',
            child: TextField(
              controller: _unitsController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('1'),
            ),
          ),
          _LabeledField(
            label: 'Total Bedrooms',
            child: TextField(
              controller: _bedroomsController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('2'),
            ),
          ),
          _LabeledField(
            label: 'Total Bathrooms',
            child: TextField(
              controller: _bathroomsController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('2'),
            ),
          ),
          _LabeledField(
            label: 'Total Kitchens',
            child: TextField(
              controller: _kitchensController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('1'),
            ),
          ),
          _LabeledField(
            label: 'Total Garages',
            child: TextField(
              controller: _garagesController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('1'),
            ),
          ),
        ],
      ),
      _StepSection(
        title: 'Location Information',
        children: [
          _LabeledField(
            label: 'Location',
            child: TextField(
              controller: _locationController,
              decoration: _inputDecoration('Ntinda, Kampala'),
            ),
          ),
        ],
      ),
      _StepSection(
        title: 'Property Images',
        children: [
          const Text(
            'Capture the listing cover photo first. This image appears on the home screen before users open details.',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ..._buildUnitImageCaptureFields(),
        ],
      ),
      _StepSection(
        title: 'Amenities',
        children: [
          SwitchListTile.adaptive(
            value: _wifi,
            activeThumbColor: _addOrange,
            activeTrackColor: const Color(0xFFFFC98E),
            contentPadding: EdgeInsets.zero,
            title: const Text('WiFi'),
            onChanged: (value) => setState(() => _wifi = value),
          ),
          SwitchListTile.adaptive(
            value: _parking,
            activeThumbColor: _addOrange,
            activeTrackColor: const Color(0xFFFFC98E),
            contentPadding: EdgeInsets.zero,
            title: const Text('Parking'),
            onChanged: (value) => setState(() => _parking = value),
          ),
          _LabeledField(
            label: 'Other Amenities (comma separated)',
            child: TextField(
              controller: _amenitiesController,
              minLines: 2,
              maxLines: 3,
              decoration: _inputDecoration('Gym, Balcony'),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildUnitImageCaptureFields() {
    final requiredLabels = _requiredUnitLabels();
    if (requiredLabels.isEmpty) {
      return const [
        Text(
          'Add unit counts in Basic Information to request image captures.',
          style: TextStyle(color: Color(0xFF7A7A7A), fontSize: 13),
        ),
      ];
    }

    return requiredLabels
        .map(
          (label) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _addOrangeSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD8B0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ),
                  Text(
                    _capturedUnitImages.containsKey(label)
                        ? 'Captured'
                        : 'Pending',
                    style: TextStyle(
                      color: _capturedUnitImages.containsKey(label)
                          ? const Color(0xFF2E7D32)
                          : _addOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () => _captureUnitImage(label),
                    icon: const Icon(Icons.photo_camera_rounded, size: 18),
                    label: const Text('Camera'),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  List<String> _requiredUnitLabels() {
    final labels = <String>[_coverPhotoLabel];
    final units = [
      ('bedroom', _parseCount(_bedroomsController.text)),
      ('bathroom', _parseCount(_bathroomsController.text)),
      ('kitchen', _parseCount(_kitchensController.text)),
      ('garage', _parseCount(_garagesController.text)),
    ];

    for (final unit in units) {
      for (var i = 1; i <= unit.$2; i++) {
        labels.add('${unit.$1}$i');
      }
    }

    return labels;
  }

  int _parseCount(String rawValue) {
    final value = int.tryParse(rawValue.trim()) ?? 0;
    return value < 0 ? 0 : value;
  }

  String _formatWholeNumber(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  Future<void> _captureUnitImage(String label) async {
    try {
      final captured = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 82,
      );

      if (captured == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _capturedUnitImages[label] = captured;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not capture image for $label: $error')),
      );
    }
  }

  Future<Map<String, String>> _uploadUnitImages({
    required String propertyId,
    required String ownerId,
  }) async {
    final storage = FirebaseStorage.instance;
    final uploaded = <String, String>{};

    for (final entry in _capturedUnitImages.entries) {
      final bytes = await entry.value.readAsBytes();
      final safeLabel = entry.key.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final ref = storage.ref().child(
        'images/$ownerId/$propertyId/$safeLabel-${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      uploaded[entry.key] = await ref.getDownloadURL();
    }

    return uploaded;
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _addOrange),
      ),
    );
  }

  bool _isNonNegativeInteger(String value) {
    final parsed = int.tryParse(value.trim());
    return parsed != null && parsed >= 0;
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateStep(int step) {
    if (step == 0) {
      final priceValue = _priceController.text.trim();
      if (priceValue.isEmpty) {
        return 'Please enter a price.';
      }

      final parsedPrice = double.tryParse(priceValue.replaceAll(',', ''));
      if (parsedPrice == null || parsedPrice <= 0) {
        return 'Please enter a valid price greater than 0.';
      }

      if (!_isNonNegativeInteger(_unitsController.text)) {
        return 'Total units must be a non-negative whole number.';
      }
      if (!_isNonNegativeInteger(_bedroomsController.text)) {
        return 'Total bedrooms must be a non-negative whole number.';
      }
      if (!_isNonNegativeInteger(_bathroomsController.text)) {
        return 'Total bathrooms must be a non-negative whole number.';
      }
      if (!_isNonNegativeInteger(_kitchensController.text)) {
        return 'Total kitchens must be a non-negative whole number.';
      }
      if (!_isNonNegativeInteger(_garagesController.text)) {
        return 'Total garages must be a non-negative whole number.';
      }

      if (_parseCount(_unitsController.text) <= 0) {
        return 'Total units must be at least 1.';
      }

      return null;
    }

    if (step == 1) {
      final location = _locationController.text.trim();
      if (location.isEmpty) {
        return 'Please enter a location before continuing.';
      }
      return null;
    }

    if (step == 2) {
      final requiredLabels = _requiredUnitLabels();
      final missingLabels = requiredLabels
          .where((label) => !_capturedUnitImages.containsKey(label))
          .toList();

      if (missingLabels.isNotEmpty) {
        return 'Capture required camera images for: ${missingLabels.join(', ')}';
      }
      return null;
    }

    return null;
  }

  void _onBackPressed() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _onNext() async {
    final validationError = _validateStep(_currentStep);
    if (validationError != null) {
      _showValidationMessage(validationError);
      return;
    }

    if (_currentStep < 3) {
      setState(() => _currentStep += 1);
      return;
    }

    final priceValue = _priceController.text.trim();
    final location = _locationController.text.trim();
    final bedrooms = _parseCount(_bedroomsController.text);

    final parsedPrice = double.tryParse(priceValue.replaceAll(',', ''));
    final formattedPrice = parsedPrice == null
        ? priceValue.toUpperCase().startsWith('UGX')
              ? priceValue
              : 'UGX $priceValue'
        : 'UGX ${_formatWholeNumber(parsedPrice.round())}';

    final tags = <String>[
      bedrooms == 1 ? '1 bedroom' : '$bedrooms bedrooms',
      if (_wifi) 'WiFi',
      if (_parking) 'Parking',
      ..._amenitiesController.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty),
    ];

    setState(() => _isSaving = true);

    final ownerId = PropertyStore.instance.currentUser?.uid;
    if (ownerId == null || ownerId.isEmpty) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session has expired. Please log in again.'),
        ),
      );
      return;
    }

    final propertyId = 'p_${DateTime.now().millisecondsSinceEpoch}';
    try {
      final uploadedUnitImages = await _uploadUnitImages(
        propertyId: propertyId,
        ownerId: ownerId,
      );
      final orderedLabels = _requiredUnitLabels();
      final unitImages = orderedLabels
          .where(uploadedUnitImages.containsKey)
          .map(
            (label) => PropertyUnitImage(
              label: label,
              imageUrl: uploadedUnitImages[label]!,
            ),
          )
          .toList();

      final imageUrls = unitImages.map((item) => item.imageUrl).toList();

      final saved = await PropertyStore.instance.addProperty(
        PropertyListing(
          id: propertyId,
          price: formattedPrice,
          location: location,
          tags: tags,
          imageUrls: imageUrls,
          unitImages: unitImages,
          propertyType: _selectedPropertyType,
          bedrooms: bedrooms,
          ownerId: ownerId,
        ),
      );

      if (!mounted) {
        return;
      }

      if (!saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save to Firebase. Please try again.'),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property saved successfully.')),
      );
      Navigator.of(context).pop();
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }
      final errorMessage = error.code == 'unauthorized'
          ? 'Upload not authorized. Check Firebase Storage rules for authenticated user uploads.'
          : 'Failed to upload camera images: ${error.message ?? error.code}';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload camera images: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.currentStep});

  final int currentStep;

  static const _labels = ['Basic Info', 'Location', 'Property', 'Amenities'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length, (index) {
        final active = index <= currentStep;
        final circleColor = active
          ? _addOrangeStrong
            : const Color(0xFFFFEDD7);
        final textColor = active
          ? _addOrangeStrong
            : const Color(0xFF8B8B8B);

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: index == 0
                        ? const SizedBox.shrink()
                        : Container(
                            height: 2,
                            color: index <= currentStep
                            ? _addOrangeStrong
                                : const Color(0xFFE3E3E3),
                          ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: active ? Colors.white : const Color(0xFFBF9A72),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: index == _labels.length - 1
                        ? const SizedBox.shrink()
                        : Container(
                            height: 2,
                            color: index < currentStep
                            ? _addOrangeStrong
                                : const Color(0xFFE3E3E3),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _labels[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StepSection extends StatelessWidget {
  const _StepSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              color: _addOrangeStrong,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 18),
        ...children,
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF2A2A2A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
