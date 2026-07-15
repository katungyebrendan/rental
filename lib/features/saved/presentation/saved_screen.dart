import 'package:flutter/material.dart';

import '../../../core/property_store.dart';
import '../../property/presentation/property_details_screen.dart';

const _savedOrange = Color(0xFFF57C00);
const _savedOrangeStrong = Color(0xFFE06300);
const _savedOrangeSoft = Color(0xFFFFF1DF);

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PropertyStore.instance;

    return ColoredBox(
      color: const Color(0xFFFFFBF6),
      child: SafeArea(
        child: ValueListenableBuilder<Map<String, Set<String>>>(
          valueListenable: store.savedByUser,
          builder: (context, _, __) {
            final saved = store.savedPropertiesForActiveUser();

            if (saved.isEmpty) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _savedOrangeSoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD8B0)),
                  ),
                  child: const Text(
                    'No saved properties yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              itemCount: saved.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: Text(
                      'Saved',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                        color: _savedOrangeStrong,
                      ),
                    ),
                  );
                }

                final property = saved[index - 1];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD8B0)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      splashColor: _savedOrange.withValues(alpha: 0.14),
                      highlightColor: _savedOrange.withValues(alpha: 0.08),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                PropertyDetailsScreen(property: property),
                          ),
                        );
                      },
                      child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          child: Image.network(
                            property.imageUrls.first,
                            width: 108,
                            height: 96,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 108,
                                height: 96,
                                color: const Color(0xFFFFE4C7),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  property.displayPrice,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  property.location,
                                  style: const TextStyle(
                                    color: Color(0xFF777777),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  property.tags.join(' • '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}
