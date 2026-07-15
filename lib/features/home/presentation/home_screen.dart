import 'package:flutter/material.dart';

import '../../../core/property_store.dart';
import '../../../models/property_listing.dart';
import '../../property/presentation/property_details_screen.dart';

const _homeOrange = Color(0xFFF57C00);
const _homeOrangeStrong = Color(0xFFE06300);
const _homeOrangeSoft = Color(0xFFFFF1DF);

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.onAddPropertyTap,
    required this.needsProfileCompletion,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onAddPropertyTap;
  final bool needsProfileCompletion;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _locationController = TextEditingController();
  String _locationQuery = '';
  String _selectedPropertyType = 'All';
  _PriceCategory? _selectedPriceCategory;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = PropertyStore.instance;

    return ColoredBox(
      color: const Color(0xFFFFFBF6),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _BrandHeader(),
                    const SizedBox(height: 18),
                    ValueListenableBuilder<List<PropertyListing>>(
                      valueListenable: store.propertiesListenable,
                      builder: (context, properties, __) {
                        final typeProperties = _propertiesForSelectedType(
                          properties,
                        );
                        final priceCategories = _buildPriceCategories(
                          typeProperties,
                        );
                        final filteredProperties = _filterVisibleProperties(
                          store,
                          typeProperties,
                        );

                        if (_selectedPriceCategory != null &&
                            !priceCategories.contains(_selectedPriceCategory)) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() => _selectedPriceCategory = null);
                            }
                          });
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SearchBar(
                              priceCategories: priceCategories,
                              selectedCategory: _selectedPriceCategory,
                              controller: _locationController,
                              onChanged: (value) =>
                                  setState(() => _locationQuery = value),
                              onCategorySelected: (category) => setState(
                                () => _selectedPriceCategory = category,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _CategoryChips(
                              selectedType: _selectedPropertyType,
                              onSelected: (type) => setState(() {
                                _selectedPropertyType = type;
                                _selectedPriceCategory = null;
                              }),
                            ),
                            const SizedBox(height: 16),
                            if (filteredProperties.isEmpty)
                              const _EmptyState()
                            else
                              _PropertyListSection(
                                properties: filteredProperties,
                                onTap: (property) =>
                                    _openDetails(context, property),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            _HomeBottomNavigationBar(
              currentIndex: widget.currentIndex,
              needsProfileCompletion: widget.needsProfileCompletion,
              onTabChanged: (index) {
                if (index == 1) {
                  widget.onAddPropertyTap();
                  return;
                }
                widget.onTabChanged(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openDetails(BuildContext context, PropertyListing property) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PropertyDetailsScreen(property: property),
      ),
    );
  }

  List<PropertyListing> _propertiesForSelectedType(
    List<PropertyListing> properties,
  ) {
    if (_selectedPropertyType == 'All') {
      return properties;
    }

    final normalizedType = _selectedPropertyType.toLowerCase();
    return properties
        .where(
          (property) => property.propertyType.toLowerCase() == normalizedType,
        )
        .toList();
  }

  List<PropertyListing> _filterVisibleProperties(
    PropertyStore store,
    List<PropertyListing> typeProperties,
  ) {
    final locationFiltered = store.searchByLocation(
      _locationQuery,
      propertyType: _selectedPropertyType,
    );
    final selectedRange = _selectedPriceCategory;
    if (selectedRange == null) {
      return locationFiltered;
    }

    final allowedIds = typeProperties
        .where((property) => selectedRange.includes(property.numericPrice))
        .map((property) => property.id)
        .toSet();

    return locationFiltered
        .where((property) => allowedIds.contains(property.id))
        .toList();
  }

  List<_PriceCategory> _buildPriceCategories(List<PropertyListing> properties) {
    final numericPrices =
        properties
            .map((property) => property.numericPrice)
            .whereType<int>()
            .toList()
          ..sort();

    if (numericPrices.isEmpty) {
      return const <_PriceCategory>[];
    }

    final minPrice = numericPrices.first;
    final maxPrice = numericPrices.last;
    final categories = <_PriceCategory>[];
    var start = minPrice;

    while (start <= maxPrice) {
      final end = start + 150000;
      categories.add(_PriceCategory(minPrice: start, maxPrice: end));
      start += 150000;
    }

    return categories;
  }
}

class _HomeBottomNavigationBar extends StatelessWidget {
  const _HomeBottomNavigationBar({
    required this.currentIndex,
    required this.onTabChanged,
    required this.needsProfileCompletion,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final bool needsProfileCompletion;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFFFDFBD), width: 1)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        onTap: onTabChanged,
        selectedItemColor: _homeOrange,
        unselectedItemColor: const Color(0xFF7E7E7E),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _AddEntryIcon(
              active: false,
              needsProfileCompletion: needsProfileCompletion,
            ),
            activeIcon: _AddEntryIcon(
              active: true,
              needsProfileCompletion: needsProfileCompletion,
            ),
            label: 'Add',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Saved',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _AddEntryIcon extends StatelessWidget {
  const _AddEntryIcon({
    required this.active,
    required this.needsProfileCompletion,
  });

  final bool active;
  final bool needsProfileCompletion;

  @override
  Widget build(BuildContext context) {
    final icon = active
        ? Icons.add_circle_rounded
        : Icons.add_circle_outline_rounded;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (needsProfileCompletion)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              height: 16,
              width: 16,
              decoration: BoxDecoration(
                color: _homeOrange,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              alignment: Alignment.center,
              child: const Text(
                '!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: const BoxDecoration(
            color: _homeOrange,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: const Icon(Icons.home_rounded, color: Colors.black, size: 18),
        ),
        const SizedBox(width: 10),
        const Text(
          'Nhome',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: _homeOrangeStrong,
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.priceCategories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final List<_PriceCategory> priceCategories;
  final _PriceCategory? selectedCategory;
  final ValueChanged<_PriceCategory?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PopupMenuButton<_PriceCategory?>(
          tooltip: 'Filter by price range',
          onSelected: onCategorySelected,
          itemBuilder: (context) {
            if (priceCategories.isEmpty) {
              return const [
                PopupMenuItem<_PriceCategory?>(
                  enabled: false,
                  child: Text('No price ranges available'),
                ),
              ];
            }

            return [
              CheckedPopupMenuItem<_PriceCategory?>(
                value: null,
                checked: selectedCategory == null,
                child: const Text('All prices'),
              ),
              ...priceCategories.map(
                (category) => CheckedPopupMenuItem<_PriceCategory?>(
                  value: category,
                  checked: selectedCategory == category,
                  child: Text(category.label),
                ),
              ),
            ];
          },
          child: Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: selectedCategory == null
                  ? Colors.white
                  : _homeOrange,
              borderRadius: BorderRadius.circular(27),
              border: Border.all(color: const Color(0xFFFFD8B0)),
            ),
            child: Icon(
              Icons.menu_rounded,
              color: selectedCategory == null
                  ? const Color(0xFF111111)
                  : Colors.black,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFFFD8B0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.place_outlined,
                  color: _homeOrange,
                  size: 21,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.search,
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      hintText: 'Search by location',
                      hintStyle: TextStyle(
                        color: Color(0xFF9C9C9C),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selectedType, required this.onSelected});

  final String selectedType;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final type in <String>[
            'All',
            ...PropertyListing.propertyTypeOptions,
          ])
            _Chip(
              label: type,
              selected: selectedType == type,
              onTap: () => onSelected(type),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: selected ? _homeOrange : Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFFFD8B0)),
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(19),
          splashColor: _homeOrange.withValues(alpha: 0.14),
          highlightColor: _homeOrange.withValues(alpha: 0.08),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : const Color(0xFF6F6F6F),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _homeOrangeSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD8B0)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No properties for this location yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111111),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try nearby areas in Kampala to discover more listings.',
            style: TextStyle(fontSize: 13, color: Color(0xFF7D7D7D)),
          ),
        ],
      ),
    );
  }
}

class _FeaturedPropertyCard extends StatelessWidget {
  const _FeaturedPropertyCard({required this.property, required this.onTap});

  final PropertyListing property;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 1.04,
              child: Image.network(
                property.imageUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF57C00), Color(0xFFFFD29B)],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            property.displayPrice,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            property.location,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF8F8F8F),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.bed_outlined,
                size: 16,
                color: Color(0xFF8F8F8F),
              ),
              const SizedBox(width: 6),
              Text(
                property.bedroomsLabel,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PropertyListSection extends StatelessWidget {
  const _PropertyListSection({required this.properties, required this.onTap});

  final List<PropertyListing> properties;
  final ValueChanged<PropertyListing> onTap;

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        for (var i = 0; i < properties.length; i++) ...[
          _FeaturedPropertyCard(
            property: properties[i],
            onTap: () => onTap(properties[i]),
          ),
          if (i != properties.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _PriceCategory {
  const _PriceCategory({required this.minPrice, required this.maxPrice});

  final int minPrice;
  final int maxPrice;

  String get label =>
      'UGX ${_formatWholeNumber(minPrice)} - ${_formatWholeNumber(maxPrice)}';

  bool includes(int? value) {
    if (value == null) {
      return false;
    }
    return value >= minPrice && value <= maxPrice;
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

  @override
  bool operator ==(Object other) {
    return other is _PriceCategory &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice;
  }

  @override
  int get hashCode => Object.hash(minPrice, maxPrice);
}
