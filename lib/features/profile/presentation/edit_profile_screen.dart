import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/property_store.dart';
import '../../../models/owner_profile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, this.initialProfile});

  final OwnerProfile? initialProfile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imagePicker = ImagePicker();

  String _selectedRole = OwnerProfile.roleOptions.first;
  XFile? _selectedPhoto;
  String _existingPhotoUrl = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.initialProfile;
    _nameController.text = profile?.nameOrBusiness ?? '';
    _phoneController.text = profile?.phone ?? '';
    _selectedRole = OwnerProfile.roleOptions.contains(profile?.roleTag)
        ? profile!.roleTag
        : OwnerProfile.roleOptions.first;
    _existingPhotoUrl = profile?.photoUrl ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF111111),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111111)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Build trust with renters by completing your professional profile.',
                style: TextStyle(
                  color: Color(0xFF5D5D5D),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _isSaving ? null : _pickProfilePhoto,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: const Color(0xFFEAE2D7),
                        backgroundImage: _selectedPhoto != null
                            ? null
                            : (_existingPhotoUrl.isEmpty
                                  ? null
                                  : NetworkImage(_existingPhotoUrl)),
                        child: _selectedPhoto == null
                            ? (_existingPhotoUrl.isEmpty
                                  ? const Icon(
                                      Icons.person_rounded,
                                      size: 44,
                                      color: Color(0xFF7C6D59),
                                    )
                                  : null)
                            : FutureBuilder<Uint8List>(
                                future: _selectedPhoto!.readAsBytes(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const CircularProgressIndicator();
                                  }
                                  return ClipOval(
                                    child: Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                      width: 96,
                                      height: 96,
                                    ),
                                  );
                                },
                              ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF4967),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Profile photo (clear, professional)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF777777),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _LabeledInput(
                label: 'Full name / business name',
                child: TextField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration('e.g. Sarah Nansubuga Properties'),
                ),
              ),
              _LabeledInput(
                label: 'Phone',
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: _inputDecoration('+256 700 123456'),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Role tag',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202020),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: OwnerProfile.roleOptions
                    .map(
                      (role) => ChoiceChip(
                        label: Text(role),
                        selected: _selectedRole == role,
                        selectedColor: const Color(0xFFFF4967),
                        labelStyle: TextStyle(
                          color: _selectedRole == role
                              ? Colors.white
                              : const Color(0xFF4D4D4D),
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: _isSaving
                            ? null
                            : (_) {
                                setState(() => _selectedRole = role);
                              },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4967),
                foregroundColor: Colors.white,
              ),
              child: Text(
                _isSaving ? 'Saving...' : 'Save Profile',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD8D1C8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD8D1C8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF4967)),
      ),
      fillColor: Colors.white,
      filled: true,
    );
  }

  Future<void> _pickProfilePhoto() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null || !mounted) {
        return;
      }
      setState(() => _selectedPhoto = picked);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick profile photo: $error')),
      );
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your full name or business name.')),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your phone number.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    String photoUrl = _existingPhotoUrl;
    try {
      final uid = PropertyStore.instance.currentUser?.uid;
      if (uid == null || uid.isEmpty) {
        if (!mounted) {
          return;
        }
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please log in again.')),
        );
        return;
      }

      if (_selectedPhoto != null) {
        final bytes = await _selectedPhoto!.readAsBytes();
        final ref = FirebaseStorage.instance.ref().child(
          'profile_photos/$uid/profile-${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        photoUrl = await ref.getDownloadURL();
      }

      final saved = await PropertyStore.instance.upsertActiveUserProfile(
        nameOrBusiness: name,
        phone: phone,
        roleTag: _selectedRole,
        photoUrl: photoUrl,
      );

      if (!mounted) {
        return;
      }

      if (!saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save profile. Please try again.')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
      Navigator.of(context).pop();
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }
      final message = error.code == 'unauthorized'
          ? 'Upload not authorized. Check Firebase Storage profile photo rules.'
          : 'Failed to save profile photo: ${error.message ?? error.code}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({required this.label, required this.child});

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
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF202020),
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
