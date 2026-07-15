import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/owner_profile.dart';
import '../models/owner_rating_summary.dart';
import '../models/property_listing.dart';

class PropertyStore {
  PropertyStore._();

  static final PropertyStore instance = PropertyStore._();

  static const String _fallbackUserId = 'local_user';
  static const String _savedKeyPrefix = 'saved_properties_';
  static const String _ownerRatingsKeyPrefix = 'owner_ratings_';

  static const List<PropertyListing> _seedProperties = [
    PropertyListing(
      id: 'p1',
      price: 'UGX 440,000',
      location: 'Ntinda, Kampala',
      tags: ['2 bedrooms', 'WiFi', 'Parking'],
      bedrooms: 2,
      imageUrls: [
        'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=1400&q=80',
        'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?auto=format&fit=crop&w=1400&q=80',
        'https://images.unsplash.com/photo-1576941089067-2de3c901e126?auto=format&fit=crop&w=1400&q=80',
      ],
      propertyType: 'Appartment',
    ),
    PropertyListing(
      id: 'p2',
      price: 'UGX 420,000',
      location: 'Kololo, Kampala',
      tags: ['3 bedrooms', 'WiFi', 'Gym'],
      bedrooms: 3,
      imageUrls: [
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1400&q=80',
        'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1400&q=80',
        'https://images.unsplash.com/photo-1605146768851-eda79da39897?auto=format&fit=crop&w=1400&q=80',
      ],
      propertyType: 'Standalone',
    ),
    PropertyListing(
      id: 'p3',
      price: 'UGX 380,000',
      location: 'Muyenga, Kampala',
      tags: ['2 bedrooms', 'Balcony', 'Parking'],
      bedrooms: 2,
      imageUrls: [
        'https://images.unsplash.com/photo-1570129477492-45c003edd2be?auto=format&fit=crop&w=1400&q=80',
        'https://images.unsplash.com/photo-1600210492486-724fe5c67fb3?auto=format&fit=crop&w=1400&q=80',
        'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=1400&q=80',
      ],
      propertyType: 'Single',
    ),
    PropertyListing(
      id: 'p4',
      price: 'UGX 510,000',
      location: 'Bugolobi, Kampala',
      tags: ['4 bedrooms', 'WiFi', 'Garden'],
      bedrooms: 4,
      imageUrls: [
        'https://images.unsplash.com/photo-1568605114967-8130f3a36994?auto=format&fit=crop&w=1400&q=80',
        'https://images.unsplash.com/photo-1600607688969-a5bfcd646154?auto=format&fit=crop&w=1400&q=80',
        'https://images.unsplash.com/photo-1600607687644-c7171b42498f?auto=format&fit=crop&w=1400&q=80',
      ],
      propertyType: 'Double',
    ),
  ];

  SharedPreferences? _preferences;
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  String _activeUserId = _fallbackUserId;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _propertiesSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _savedSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _profileSubscription;
  StreamSubscription<User?>? _authSubscription;
  bool _initialized = false;

  final ValueNotifier<List<PropertyListing>> _properties =
      ValueNotifier<List<PropertyListing>>(
        List<PropertyListing>.from(_seedProperties),
      );

  final ValueNotifier<Map<String, Set<String>>> _savedByUser =
      ValueNotifier<Map<String, Set<String>>>({_fallbackUserId: <String>{}});
  final ValueNotifier<OwnerProfile?> _ownerProfile =
      ValueNotifier<OwnerProfile?>(null);
  final ValueNotifier<Map<String, OwnerProfile>> _ownerProfilesByUserId =
      ValueNotifier<Map<String, OwnerProfile>>(<String, OwnerProfile>{});

  ValueListenable<List<PropertyListing>> get propertiesListenable =>
      _properties;
  ValueListenable<Map<String, Set<String>>> get savedByUser => _savedByUser;
  ValueListenable<OwnerProfile?> get ownerProfileListenable => _ownerProfile;
  ValueListenable<Map<String, OwnerProfile>> get ownerProfilesListenable =>
      _ownerProfilesByUserId;
  String get activeUserId => _activeUserId;
  User? get currentUser => _auth?.currentUser;
  OwnerProfile? get activeOwnerProfile => _ownerProfile.value;

  List<PropertyListing> get allProperties => _properties.value;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _preferences = await SharedPreferences.getInstance();
    await _activateUser(_activeUserId);

    try {
      _firestore = FirebaseFirestore.instance;
      _startRemotePropertiesSync();
    } catch (error) {
      debugPrint('Firestore sync not available: $error');
    }

    await _initializeAuth();

    _initialized = true;
  }

  Future<void> _initializeAuth() async {
    try {
      _auth = FirebaseAuth.instance;

      final user = _auth?.currentUser;
      await _activateUser(user?.uid ?? _fallbackUserId);

      _authSubscription = _auth?.authStateChanges().listen((user) {
        final nextUserId = user?.uid ?? _fallbackUserId;
        if (nextUserId == _activeUserId) {
          return;
        }
        unawaited(_activateUser(nextUserId));
      });
    } catch (error) {
      debugPrint('Firebase Auth unavailable. Using fallback user: $error');
    }
  }

  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      return 'Authentication is currently unavailable.';
    }

    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (error) {
      return error.message ?? 'Could not sign in. Please try again.';
    } catch (_) {
      return 'Could not sign in. Please try again.';
    }
  }

  Future<String?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) {
      return 'Authentication is currently unavailable.';
    }

    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (error) {
      return error.message ?? 'Could not create account. Please try again.';
    } catch (_) {
      return 'Could not create account. Please try again.';
    }
  }

  Future<void> signOut() async {
    final auth = _auth;
    if (auth == null) {
      await _activateUser(_fallbackUserId);
      return;
    }

    try {
      await auth.signOut();
    } catch (error) {
      debugPrint('Failed to sign out: $error');
    } finally {
      await _activateUser(_fallbackUserId);
    }
  }

  Future<void> _activateUser(String userId) async {
    _activeUserId = userId;

    final savedIds =
        _preferences?.getStringList(_savedKeyForUser(_activeUserId)) ??
        <String>[];
    _savedByUser.value = <String, Set<String>>{_activeUserId: savedIds.toSet()};

    _startRemoteSavedSyncForActiveUser();
    _startRemoteProfileSyncForActiveUser();
  }

  void _startRemotePropertiesSync() {
    final firestore = _firestore;
    if (firestore == null) {
      return;
    }

    _propertiesSubscription = firestore
        .collection('properties')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final remote = snapshot.docs
                .map((doc) => PropertyListing.fromMap(doc.id, doc.data()))
                .toList();
            _properties.value = remote;
          },
          onError: (error) {
            debugPrint('Firestore stream error: $error');
          },
        );
  }

  bool isSaved(String propertyId) {
    return _savedByUser.value[_activeUserId]?.contains(propertyId) ?? false;
  }

  Future<bool> toggleSaved(String propertyId) async {
    final next = Map<String, Set<String>>.from(_savedByUser.value);
    final userSaved = Set<String>.from(next[_activeUserId] ?? <String>{});
    final wasSaved = userSaved.contains(propertyId);

    if (wasSaved) {
      userSaved.remove(propertyId);
    } else {
      userSaved.add(propertyId);
    }

    next[_activeUserId] = userSaved;
    _savedByUser.value = next;
    _persistSavedForActiveUser(userSaved);

    final remoteSaved = await _persistSavedToggleRemote(
      propertyId,
      userSaved.contains(propertyId),
    );

    if (!remoteSaved && _firestore != null) {
      final rollback = Map<String, Set<String>>.from(_savedByUser.value);
      final rollbackSet = Set<String>.from(
        rollback[_activeUserId] ?? <String>{},
      );
      if (wasSaved) {
        rollbackSet.add(propertyId);
      } else {
        rollbackSet.remove(propertyId);
      }
      rollback[_activeUserId] = rollbackSet;
      _savedByUser.value = rollback;
      _persistSavedForActiveUser(rollbackSet);
    }

    return remoteSaved || _firestore == null;
  }

  Future<bool> _persistSavedToggleRemote(
    String propertyId,
    bool shouldSave,
  ) async {
    final firestore = _firestore;
    if (firestore == null) {
      return false;
    }

    final savedDoc = firestore
        .collection('users')
        .doc(_activeUserId)
        .collection('saved_properties')
        .doc(propertyId);

    try {
      if (shouldSave) {
        await savedDoc.set({
          'propertyId': propertyId,
          'savedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await savedDoc.delete();
      }
      return true;
    } catch (error) {
      debugPrint('Failed to persist saved toggle: $error');
      return false;
    }
  }

  void _startRemoteSavedSyncForActiveUser() {
    final firestore = _firestore;
    if (firestore == null) {
      return;
    }

    _savedSubscription?.cancel();
    _savedSubscription = firestore
        .collection('users')
        .doc(_activeUserId)
        .collection('saved_properties')
        .snapshots()
        .listen(
          (snapshot) {
            final ids = snapshot.docs.map((doc) => doc.id).toSet();
            _savedByUser.value = <String, Set<String>>{_activeUserId: ids};
            _persistSavedForActiveUser(ids);
          },
          onError: (error) {
            debugPrint('Saved properties stream error: $error');
          },
        );
  }

  void _startRemoteProfileSyncForActiveUser() {
    final firestore = _firestore;
    if (firestore == null || _activeUserId == _fallbackUserId) {
      _ownerProfile.value = null;
      return;
    }

    _profileSubscription?.cancel();
    _profileSubscription = firestore
        .collection('users')
        .doc(_activeUserId)
        .snapshots()
        .listen(
          (snapshot) {
            final data = snapshot.data();
            if (data == null || data['nameOrBusiness'] == null) {
              _ownerProfile.value = null;
              return;
            }
            final profile = OwnerProfile.fromMap(data);
            _ownerProfile.value = profile;
            final next = Map<String, OwnerProfile>.from(
              _ownerProfilesByUserId.value,
            );
            next[_activeUserId] = profile;
            _ownerProfilesByUserId.value = next;
          },
          onError: (error) {
            debugPrint('Owner profile stream error: $error');
          },
        );
  }

  Future<OwnerProfile?> profileForOwner(String ownerId) async {
    if (ownerId.isEmpty) {
      return null;
    }

    if (ownerId == _activeUserId && _ownerProfile.value != null) {
      return _ownerProfile.value;
    }

    final cached = _ownerProfilesByUserId.value[ownerId];
    if (cached != null) {
      return Future<OwnerProfile?>.value(cached);
    }

    final firestore = _firestore;
    if (firestore == null) {
      return null;
    }

    try {
      final snapshot = await firestore.collection('users').doc(ownerId).get();
      final data = snapshot.data();
      if (data == null || data['nameOrBusiness'] == null) {
        return null;
      }

      final profile = OwnerProfile.fromMap(data);
      final next = Map<String, OwnerProfile>.from(_ownerProfilesByUserId.value);
      next[ownerId] = profile;
      _ownerProfilesByUserId.value = next;
      return profile;
    } catch (error) {
      debugPrint('Failed to load owner profile for $ownerId: $error');
      return null;
    }
  }

  Future<OwnerRatingSummary> ownerRatingSummary(String ownerId) async {
    if (ownerId.isEmpty) {
      return const OwnerRatingSummary();
    }

    final firestore = _firestore;
    if (firestore == null) {
      return _ownerRatingSummaryFromMap(_readLocalOwnerRatings(ownerId));
    }

    try {
      final snapshot = await firestore
          .collection('users')
          .doc(ownerId)
          .collection('ratings')
          .get();

      final ratings = <String, int>{
        for (final doc in snapshot.docs)
          doc.id: _coerceRatingValue(doc.data()['rating']),
      }..removeWhere((_, value) => value == 0);

      _persistLocalOwnerRatings(ownerId, ratings);
      return _ownerRatingSummaryFromMap(ratings);
    } catch (error) {
      debugPrint('Failed to load owner ratings for $ownerId: $error');
      return _ownerRatingSummaryFromMap(_readLocalOwnerRatings(ownerId));
    }
  }

  Future<String?> rateOwner({
    required String ownerId,
    required int rating,
  }) async {
    if (ownerId.isEmpty) {
      return 'Property owner is unavailable.';
    }
    if (rating < 1 || rating > 5) {
      return 'Please choose a rating between 1 and 5 stars.';
    }

    final currentUserId = _auth?.currentUser?.uid ?? _activeUserId;
    if (currentUserId.isEmpty || currentUserId == _fallbackUserId) {
      return 'Please sign in to rate this property owner.';
    }
    if (currentUserId == ownerId) {
      return 'You cannot rate your own profile.';
    }

    final localRatings = _readLocalOwnerRatings(ownerId);
    localRatings[currentUserId] = rating;
    _persistLocalOwnerRatings(ownerId, localRatings);

    final firestore = _firestore;
    if (firestore == null) {
      return null;
    }

    try {
      await firestore
          .collection('users')
          .doc(ownerId)
          .collection('ratings')
          .doc(currentUserId)
          .set({
            'ownerId': ownerId,
            'rating': rating,
            'ratedByUserId': currentUserId,
            'ratedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      return null;
    } catch (error) {
      debugPrint('Failed to save owner rating for $ownerId: $error');
      return 'Could not save your rating. Please try again.';
    }
  }

  String _savedKeyForUser(String userId) => '$_savedKeyPrefix$userId';

  String _ownerRatingsKeyForOwner(String ownerId) =>
      '$_ownerRatingsKeyPrefix$ownerId';

  void _persistSavedForActiveUser(Set<String> savedIds) {
    final preferences = _preferences;
    if (preferences == null) {
      return;
    }

    unawaited(
      preferences.setStringList(
        _savedKeyForUser(_activeUserId),
        savedIds.toList(growable: false),
      ),
    );
  }

  Map<String, int> _readLocalOwnerRatings(String ownerId) {
    final preferences = _preferences;
    if (preferences == null) {
      return <String, int>{};
    }

    final rawValue = preferences.getString(_ownerRatingsKeyForOwner(ownerId));
    if (rawValue == null || rawValue.isEmpty) {
      return <String, int>{};
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map) {
        return <String, int>{};
      }

      return <String, int>{
        for (final entry in decoded.entries)
          entry.key.toString(): _coerceRatingValue(entry.value),
      }..removeWhere((_, value) => value == 0);
    } catch (_) {
      return <String, int>{};
    }
  }

  void _persistLocalOwnerRatings(String ownerId, Map<String, int> ratings) {
    final preferences = _preferences;
    if (preferences == null) {
      return;
    }

    final sanitized = <String, int>{
      for (final entry in ratings.entries)
        entry.key: _coerceRatingValue(entry.value),
    }..removeWhere((_, value) => value == 0);

    unawaited(
      preferences.setString(
        _ownerRatingsKeyForOwner(ownerId),
        jsonEncode(sanitized),
      ),
    );
  }

  OwnerRatingSummary _ownerRatingSummaryFromMap(Map<String, int> ratings) {
    final values = ratings.values.where((value) => value >= 1 && value <= 5);
    final validRatings = values.toList(growable: false);
    if (validRatings.isEmpty) {
      return const OwnerRatingSummary();
    }

    final total = validRatings.fold<int>(
      0,
      (totalSoFar, value) => totalSoFar + value,
    );
    return OwnerRatingSummary(
      averageRating: total / validRatings.length,
      ratingsCount: validRatings.length,
      currentUserRating: ratings[_activeUserId],
    );
  }

  int _coerceRatingValue(Object? value) {
    final parsed = int.tryParse((value ?? '').toString());
    if (parsed == null || parsed < 1 || parsed > 5) {
      return 0;
    }
    return parsed;
  }

  List<PropertyListing> savedPropertiesForActiveUser() {
    final savedIds = _savedByUser.value[_activeUserId] ?? <String>{};
    return allProperties
        .where((property) => savedIds.contains(property.id))
        .toList();
  }

  List<PropertyListing> propertiesForActiveUser() {
    final authenticatedUserId = _auth?.currentUser?.uid;
    final effectiveOwnerId =
        authenticatedUserId == null || authenticatedUserId.isEmpty
        ? _activeUserId
        : authenticatedUserId;

    return allProperties
        .where((property) => property.ownerId == effectiveOwnerId)
        .toList();
  }

  List<PropertyListing> searchByLocation(String query, {String? propertyType}) {
    final trimmed = query.trim().toLowerCase();
    final normalizedType = propertyType == null || propertyType == 'All'
        ? null
        : propertyType.toLowerCase();

    return allProperties.where((property) {
      final locationMatches =
          trimmed.isEmpty || property.location.toLowerCase().contains(trimmed);
      final typeMatches =
          normalizedType == null ||
          property.propertyType.toLowerCase() == normalizedType;
      return locationMatches && typeMatches;
    }).toList();
  }

  Future<bool> addProperty(PropertyListing property) async {
    final authenticatedUserId = _auth?.currentUser?.uid;
    final effectiveOwnerId =
        authenticatedUserId == null || authenticatedUserId.isEmpty
        ? _activeUserId
        : authenticatedUserId;
    final userOwnedProperty = property.ownerId.isEmpty
        ? property.copyWith(ownerId: effectiveOwnerId)
        : property;
    final next = <PropertyListing>[userOwnedProperty, ..._properties.value];
    _properties.value = next;

    final firestore = _firestore;
    if (firestore == null) {
      return true;
    }

    try {
      await firestore.collection('properties').doc(userOwnedProperty.id).set({
        ...userOwnedProperty.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (error) {
      debugPrint('Failed to persist property to Firestore: $error');
      _properties.value = _properties.value
          .where((item) => item.id != userOwnedProperty.id)
          .toList();
      return false;
    }
  }

  Future<bool> deleteProperty(String propertyId) async {
    final existing = _properties.value.where((item) => item.id == propertyId);
    if (existing.isEmpty) {
      return false;
    }

    final property = existing.first;
    final authenticatedUserId = _auth?.currentUser?.uid;
    final effectiveOwnerId =
        authenticatedUserId == null || authenticatedUserId.isEmpty
        ? _activeUserId
        : authenticatedUserId;

    if (property.ownerId != effectiveOwnerId) {
      return false;
    }

    final previousProperties = List<PropertyListing>.from(_properties.value);
    _properties.value = previousProperties
        .where((item) => item.id != propertyId)
        .toList();

    final previousSavedByUser = <String, Set<String>>{
      for (final entry in _savedByUser.value.entries)
        entry.key: Set<String>.from(entry.value),
    };

    final nextSavedByUser = <String, Set<String>>{
      for (final entry in previousSavedByUser.entries)
        entry.key: {...entry.value}..remove(propertyId),
    };
    _savedByUser.value = nextSavedByUser;

    for (final entry in nextSavedByUser.entries) {
      if (entry.key == _activeUserId) {
        _persistSavedForActiveUser(entry.value);
      }
    }

    final firestore = _firestore;
    if (firestore == null) {
      return true;
    }

    try {
      await firestore.collection('properties').doc(propertyId).delete();
      return true;
    } catch (error) {
      debugPrint('Failed to delete property from Firestore: $error');
      _properties.value = previousProperties;
      _savedByUser.value = previousSavedByUser;
      _persistSavedForActiveUser(
        previousSavedByUser[_activeUserId] ?? <String>{},
      );
      return false;
    }
  }

  Future<bool> upsertActiveUserProfile({
    required String nameOrBusiness,
    required String phone,
    required String roleTag,
    String photoUrl = '',
  }) async {
    final authenticatedUserId = _auth?.currentUser?.uid;
    final effectiveOwnerId =
        authenticatedUserId == null || authenticatedUserId.isEmpty
        ? _activeUserId
        : authenticatedUserId;

    if (effectiveOwnerId == _fallbackUserId) {
      return false;
    }

    final profile = OwnerProfile(
      nameOrBusiness: nameOrBusiness,
      phone: phone,
      roleTag: roleTag,
      photoUrl: photoUrl,
    );
    _ownerProfile.value = profile;
    final nextProfiles = Map<String, OwnerProfile>.from(
      _ownerProfilesByUserId.value,
    );
    nextProfiles[effectiveOwnerId] = profile;
    _ownerProfilesByUserId.value = nextProfiles;

    final firestore = _firestore;
    if (firestore == null) {
      return true;
    }

    try {
      await firestore.collection('users').doc(effectiveOwnerId).set({
        ...profile.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (error) {
      debugPrint('Failed to save owner profile: $error');
      return false;
    }
  }

  Future<void> dispose() async {
    await _propertiesSubscription?.cancel();
    await _savedSubscription?.cancel();
    await _profileSubscription?.cancel();
    await _authSubscription?.cancel();
  }
}
