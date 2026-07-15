class OwnerProfile {
  const OwnerProfile({
    required this.nameOrBusiness,
    required this.phone,
    required this.roleTag,
    this.photoUrl = '',
  });

  static const List<String> roleOptions = [
    'Landlord',
    'Agent',
    'Property Manager',
  ];

  final String nameOrBusiness;
  final String phone;
  final String roleTag;
  final String photoUrl;

  bool get isComplete =>
      nameOrBusiness.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      roleTag.trim().isNotEmpty;

  List<String> get missingRequiredFields {
    final missing = <String>[];
    if (nameOrBusiness.trim().isEmpty) {
      missing.add('Name or business name');
    }
    if (phone.trim().isEmpty) {
      missing.add('Phone number');
    }
    if (roleTag.trim().isEmpty) {
      missing.add('Role');
    }
    return missing;
  }

  OwnerProfile copyWith({
    String? nameOrBusiness,
    String? phone,
    String? roleTag,
    String? photoUrl,
  }) {
    return OwnerProfile(
      nameOrBusiness: nameOrBusiness ?? this.nameOrBusiness,
      phone: phone ?? this.phone,
      roleTag: roleTag ?? this.roleTag,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  factory OwnerProfile.fromMap(Map<String, dynamic> map) {
    return OwnerProfile(
      nameOrBusiness: (map['nameOrBusiness'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      roleTag: (map['roleTag'] ?? 'Landlord').toString(),
      photoUrl: (map['photoUrl'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameOrBusiness': nameOrBusiness,
      'phone': phone,
      'roleTag': roleTag,
      'photoUrl': photoUrl,
    };
  }
}
