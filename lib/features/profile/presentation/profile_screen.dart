import 'package:flutter/material.dart';

import '../../../core/property_store.dart';
import '../../../models/owner_profile.dart';
import '../../../models/property_listing.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

const _profileOrange = Color(0xFFF57C00);
const _profileOrangeStrong = Color(0xFFE06300);
const _profileOrangeSoft = Color(0xFFFFF1DF);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Set<String> _deletingPropertyIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final store = PropertyStore.instance;
    final user = store.currentUser;

    return ColoredBox(
      color: const Color(0xFFFFFBF6),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: ValueListenableBuilder<List<PropertyListing>>(
            valueListenable: store.propertiesListenable,
            builder: (context, _, __) {
              final ownedProperties = store.propertiesForActiveUser();

              return ValueListenableBuilder<OwnerProfile?>(
                valueListenable: store.ownerProfileListenable,
                builder: (context, ownerProfile, __) {
                  final isProfileComplete = ownerProfile?.isComplete == true;
                  final missingFields =
                      ownerProfile?.missingRequiredFields ??
                      const ['Name or business name', 'Phone number', 'Role'];

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                            color: _profileOrangeStrong,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFD8B0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _ProfileAvatar(
                                    photoUrl: ownerProfile?.photoUrl ?? '',
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ownerProfile
                                                      ?.nameOrBusiness
                                                      .isNotEmpty ==
                                                  true
                                              ? ownerProfile!.nameOrBusiness
                                              : (user?.email ??
                                                    'Anonymous user'),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Color(0xFF111111),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isProfileComplete
                                                ? const Color(0xFFE5F5EA)
                                                : const Color(0xFFFFE7CC),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            isProfileComplete
                                                ? 'Profile complete'
                                                : 'Profile incomplete',
                                            style: TextStyle(
                                              color: isProfileComplete
                                                  ? const Color(0xFF1F7A3D)
                                                  : const Color(0xFFB25B00),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        if (ownerProfile?.roleTag.isNotEmpty ==
                                            true) ...[
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _profileOrangeSoft,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              ownerProfile!.roleTag,
                                              style: const TextStyle(
                                                color: _profileOrange,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Signed in as',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8A8A8A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                user?.email ?? 'Anonymous user',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF3D3D3D),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (ownerProfile?.phone.isNotEmpty == true) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone_outlined,
                                      size: 16,
                                      color: Color(0xFF6E6E6E),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      ownerProfile!.phone,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF5E5E5E),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 12),
                              _ProfileCompletionCard(
                                isComplete: isProfileComplete,
                                missingFields: missingFields,
                                onEdit: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => EditProfileScreen(
                                        initialProfile: ownerProfile,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 14),
                              _ProfileActionTile(
                                icon: Icons.edit_rounded,
                                title: 'Edit Profile',
                                subtitle:
                                    'Photo, name/business, phone and role',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => EditProfileScreen(
                                        initialProfile: ownerProfile,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              _ProfileActionTile(
                                icon: Icons.settings_rounded,
                                title: 'Settings',
                                subtitle: 'Account preferences and privacy',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const SettingsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        if (ownedProperties.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'My Properties',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                              color: _profileOrangeStrong,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...ownedProperties.map(
                            (property) => _MyPropertyTile(
                              property: property,
                              isDeleting: _deletingPropertyIds.contains(
                                property.id,
                              ),
                              onDelete: () => _deleteProperty(property),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await store.signOut();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Logged out successfully.'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.logout_rounded),
                            label: const Text(
                              'Log Out',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
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
          ),
        ),
      ),
    );
  }

  Future<void> _deleteProperty(PropertyListing property) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Property'),
          content: Text(
            'Delete the listing at ${property.location}? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() => _deletingPropertyIds.add(property.id));
    final deleted = await PropertyStore.instance.deleteProperty(property.id);
    if (!mounted) {
      return;
    }
    setState(() => _deletingPropertyIds.remove(property.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted
              ? 'Property deleted successfully.'
              : 'Could not delete property. Please try again.',
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.photoUrl});

  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: const Color(0xFFFFE8CC),
      backgroundImage: photoUrl.isEmpty ? null : NetworkImage(photoUrl),
      child: photoUrl.isEmpty
          ? const Icon(Icons.person_rounded, color: _profileOrange, size: 26)
          : null,
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: _profileOrange.withValues(alpha: 0.14),
        highlightColor: _profileOrange.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD8B0)),
          ),
          child: Row(
            children: [
              Icon(icon, color: _profileOrange),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6A6A6A),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF808080)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCompletionCard extends StatelessWidget {
  const _ProfileCompletionCard({
    required this.isComplete,
    required this.missingFields,
    required this.onEdit,
  });

  final bool isComplete;
  final List<String> missingFields;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final accentColor = isComplete ? const Color(0xFF2E7D32) : _profileOrange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isComplete ? const Color(0xFFF4FBF6) : _profileOrangeSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isComplete ? const Color(0xFFCFE8D6) : const Color(0xFFFFD8B0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isComplete
                    ? Icons.verified_user_rounded
                    : Icons.assignment_late_rounded,
                color: accentColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isComplete
                      ? 'Your profile is ready for property uploads.'
                      : 'Complete your profile before uploading properties.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isComplete)
            const Text(
              'Name or business, phone number, and role are all saved.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF4F5F54),
                fontWeight: FontWeight.w500,
              ),
            )
          else ...[
            const Text(
              'Missing required details:',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B5A40),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...missingFields.map(
              (field) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.radio_button_unchecked_rounded,
                      size: 14,
                      color: _profileOrange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        field,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B5A40),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: Text(isComplete ? 'Review Profile' : 'Complete Profile'),
              style: TextButton.styleFrom(
                foregroundColor: accentColor,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyPropertyTile extends StatelessWidget {
  const _MyPropertyTile({
    required this.property,
    required this.isDeleting,
    required this.onDelete,
  });

  final PropertyListing property;
  final bool isDeleting;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD8B0)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: Image.network(
                property.imageUrls.isEmpty ? '' : property.imageUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFFFE8CC),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.home_rounded,
                      color: _profileOrange,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${property.displayPrice}  ${property.propertyType}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6D6D6D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: isDeleting ? null : onDelete,
            icon: isDeleting
                ? const SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline_rounded, size: 18),
            label: Text(isDeleting ? 'Deleting' : 'Delete'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1F1F1F),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
