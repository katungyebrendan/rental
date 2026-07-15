import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/property_store.dart';
import '../../../models/owner_profile.dart';
import '../../../models/owner_rating_summary.dart';
import '../../../models/property_listing.dart';

class PropertyDetailsScreen extends StatelessWidget {
  const PropertyDetailsScreen({super.key, required this.property});

  final PropertyListing property;

  String? _normalizedPhoneForWhatsApp(String rawPhone) {
    final trimmed = rawPhone.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    var normalized = trimmed.replaceAll(RegExp(r'[^0-9+]'), '');
    if (normalized.startsWith('+')) {
      normalized = normalized.substring(1);
    }

    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  Future<void> _openWhatsApp(BuildContext context, String rawPhone) async {
    final phone = _normalizedPhoneForWhatsApp(rawPhone);
    if (phone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Owner phone number is not available.')),
      );
      return;
    }

    final url = Uri.parse('https://wa.me/$phone');
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = PropertyStore.instance;
    final labeledImages = property.unitImages.isNotEmpty
        ? property.unitImages
        : List<PropertyUnitImage>.generate(
            property.imageUrls.length,
            (index) => PropertyUnitImage(
              label: 'image${index + 1}',
              imageUrl: property.imageUrls[index],
            ),
          );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F4F0),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Property Details',
          style: TextStyle(
            color: Color.fromARGB(255, 245, 189, 5),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: [
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: labeledImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final unitImage = labeledImages[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.2,
                        child: Image.network(
                          unitImage.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(color: const Color(0xFFD8D2C8));
                          },
                        ),
                      ),
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.62),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unitImage.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.displayPrice,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      property.location,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ValueListenableBuilder<Map<String, Set<String>>>(
                valueListenable: store.savedByUser,
                builder: (context, _, __) {
                  final saved = store.isSaved(property.id);
                  return Semantics(
                    button: true,
                    label: saved ? 'Saved property' : 'Save property',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        final ok = await store.toggleSaved(property.id);
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Could not sync save with Firebase. Try again.',
                              ),
                            ),
                          );
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: saved
                                  ? const Color(0xFFFFE8EC)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              saved ? Icons.favorite : Icons.favorite_border,
                              color: saved
                                  ? const Color(0xFFE64566)
                                  : const Color(0xFF222222),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            saved ? 'Saved' : 'Save',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: saved
                                  ? const Color(0xFFE64566)
                                  : const Color(0xFF444444),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: property.tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5DFD5)),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Color(0xFF444444),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          FutureBuilder<OwnerProfile?>(
            future: store.profileForOwner(property.ownerId),
            builder: (context, snapshot) {
              final profile = snapshot.data;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5DFD5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFECE5DA),
                      backgroundImage: profile?.photoUrl.isNotEmpty == true
                          ? NetworkImage(profile!.photoUrl)
                          : null,
                      child: profile?.photoUrl.isNotEmpty == true
                          ? null
                          : const Icon(
                              Icons.person_rounded,
                              color: Color(0xFF8B7A61),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.nameOrBusiness.isNotEmpty == true
                                ? profile!.nameOrBusiness
                                : 'Property Owner',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF1D1D1D),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            profile?.phone.isNotEmpty == true
                                ? profile!.phone
                                : 'Contact details available on request',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (profile?.roleTag.isNotEmpty == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE9ED),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          profile!.roleTag,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFE64566),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (profile?.phone.isNotEmpty == true) ...[
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () => _openWhatsApp(context, profile!.phone),
                        icon: const Icon(Icons.chat_rounded, size: 18),
                        label: const Text('WhatsApp'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _OwnerRatingCard(ownerId: property.ownerId),
        ],
      ),
    );
  }
}

class _OwnerRatingCard extends StatefulWidget {
  const _OwnerRatingCard({required this.ownerId});

  final String ownerId;

  @override
  State<_OwnerRatingCard> createState() => _OwnerRatingCardState();
}

class _OwnerRatingCardState extends State<_OwnerRatingCard> {
  late Future<OwnerRatingSummary> _summaryFuture;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _loadSummary();
  }

  @override
  void didUpdateWidget(covariant _OwnerRatingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownerId != widget.ownerId) {
      _summaryFuture = _loadSummary();
    }
  }

  Future<OwnerRatingSummary> _loadSummary() {
    return PropertyStore.instance.ownerRatingSummary(widget.ownerId);
  }

  Future<void> _submitRating(int rating) async {
    setState(() => _isSubmitting = true);
    final error = await PropertyStore.instance.rateOwner(
      ownerId: widget.ownerId,
      rating: rating,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
      _summaryFuture = _loadSummary();
    });

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Owner rating saved.')));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ownerId.isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<OwnerRatingSummary>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        final summary = snapshot.data ?? const OwnerRatingSummary();
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5DFD5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Owner Rating',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  ...List<Widget>.generate(5, (index) {
                    final starIndex = index + 1;
                    final icon = _iconForRating(
                      summary.averageRating,
                      starIndex,
                    );

                    return Icon(icon, size: 20, color: const Color(0xFFF2B124));
                  }),
                  const SizedBox(width: 8),
                  Text(
                    summary.hasRatings
                        ? '${summary.averageRating.toStringAsFixed(1)} (${summary.ratingsCount} ${summary.ratingsCount == 1 ? 'rating' : 'ratings'})'
                        : 'No ratings yet',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF555555),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Tap to rate this property owner',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: List<Widget>.generate(5, (index) {
                  final starIndex = index + 1;
                  final selected =
                      (summary.currentUserRating ?? 0) >= starIndex;
                  return IconButton(
                    onPressed: _isSubmitting || isLoading
                        ? null
                        : () => _submitRating(starIndex),
                    tooltip: 'Rate $starIndex star${starIndex == 1 ? '' : 's'}',
                    style: IconButton.styleFrom(
                      backgroundColor: selected
                          ? const Color(0xFFFFF0C7)
                          : const Color(0xFFF7F3EC),
                    ),
                    icon: Icon(
                      selected ? Icons.star_rounded : Icons.star_border_rounded,
                      color: const Color(0xFFF2B124),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                summary.currentUserRating == null
                    ? 'You have not rated this owner yet.'
                    : 'Your rating: ${summary.currentUserRating}/5',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF555555),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

IconData _iconForRating(double rating, int starIndex) {
  if (rating >= starIndex) {
    return Icons.star_rounded;
  }
  if (rating >= starIndex - 0.5) {
    return Icons.star_half_rounded;
  }
  return Icons.star_border_rounded;
}
