class PropertyListing {
  const PropertyListing({
    required this.id,
    required this.price,
    required this.location,
    required this.tags,
    required this.imageUrls,
    required this.propertyType,
    this.bedrooms = 0,
    this.unitImages = const [],
    this.ownerId = '',
  });

  static const List<String> propertyTypeOptions = [
    'Appartment',
    'Standalone',
    'Single',
    'Double',
    'Air Bnb',
  ];

  final String id;
  final String price;
  final String location;
  final List<String> tags;
  final List<String> imageUrls;
  final String propertyType;
  final int bedrooms;
  final List<PropertyUnitImage> unitImages;
  final String ownerId;

  String get displayPrice => _normalizePrice(price);
  int? get numericPrice => _parsePriceValue(price);
  String get bedroomsLabel =>
      bedrooms == 1 ? '1 bedroom' : '$bedrooms bedrooms';

  PropertyListing copyWith({
    String? id,
    String? price,
    String? location,
    List<String>? tags,
    List<String>? imageUrls,
    String? propertyType,
    int? bedrooms,
    List<PropertyUnitImage>? unitImages,
    String? ownerId,
  }) {
    return PropertyListing(
      id: id ?? this.id,
      price: price ?? this.price,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      imageUrls: imageUrls ?? this.imageUrls,
      propertyType: propertyType ?? this.propertyType,
      bedrooms: bedrooms ?? this.bedrooms,
      unitImages: unitImages ?? this.unitImages,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  factory PropertyListing.fromMap(String id, Map<String, dynamic> map) {
    return PropertyListing(
      id: id,
      price: _normalizePrice((map['price'] ?? '').toString()),
      location: (map['location'] ?? '').toString(),
      tags: (map['tags'] as List<dynamic>? ?? <dynamic>[])
          .map((item) => item.toString())
          .toList(),
      imageUrls: (map['imageUrls'] as List<dynamic>? ?? <dynamic>[])
          .map((item) => item.toString())
          .toList(),
      propertyType: (map['propertyType'] ?? 'Appartment').toString(),
      bedrooms: _readBedrooms(map),
      unitImages: (map['unitImages'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map>()
          .map(
            (item) => item.map((key, value) => MapEntry(key.toString(), value)),
          )
          .map(PropertyUnitImage.fromMap)
          .toList(),
      ownerId: (map['ownerId'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'price': price,
      'location': location,
      'tags': tags,
      'imageUrls': imageUrls,
      'propertyType': propertyType,
      'bedrooms': bedrooms,
      'unitImages': unitImages.map((item) => item.toMap()).toList(),
      'ownerId': ownerId,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  static int _readBedrooms(Map<String, dynamic> map) {
    final directValue = int.tryParse((map['bedrooms'] ?? '').toString());
    if (directValue != null && directValue >= 0) {
      return directValue;
    }

    final tags = (map['tags'] as List<dynamic>? ?? <dynamic>[]).map(
      (item) => item.toString(),
    );
    for (final tag in tags) {
      final match = RegExp(
        r'(\d+)\s+bedrooms?',
        caseSensitive: false,
      ).firstMatch(tag);
      final parsed = match == null ? null : int.tryParse(match.group(1)!);
      if (parsed != null && parsed >= 0) {
        return parsed;
      }
    }

    return 0;
  }

  static String _normalizePrice(String rawPrice) {
    final trimmed = rawPrice.trim();
    final parsed = _parsePriceValue(trimmed);

    if (parsed == null) {
      if (trimmed.isEmpty) {
        return 'UGX';
      }
      return trimmed.toUpperCase().startsWith('UGX') ? trimmed : 'UGX $trimmed';
    }

    return 'UGX ${_formatWholeNumber(parsed.round())}';
  }

  static int? _parsePriceValue(String rawPrice) {
    final digitsOnly = rawPrice
        .trim()
        .replaceAll(',', '')
        .replaceAll(RegExp(r'[^0-9.]'), '');
    final parsed = double.tryParse(digitsOnly);
    return parsed?.round();
  }

  static String _formatWholeNumber(int value) {
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
}

class PropertyUnitImage {
  const PropertyUnitImage({required this.label, required this.imageUrl});

  final String label;
  final String imageUrl;

  factory PropertyUnitImage.fromMap(Map<String, dynamic> map) {
    return PropertyUnitImage(
      label: (map['label'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'label': label, 'imageUrl': imageUrl};
  }
}
