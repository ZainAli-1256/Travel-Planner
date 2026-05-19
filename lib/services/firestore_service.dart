// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/trip_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // ── Collection references ────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _trips =>
      _db.collection('trips');

  // ══ USER OPERATIONS ══════════════════════════════════════════════

  /// Create or overwrite the user document after sign-up.
  Future<void> createUser(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap());
  }

  /// Fetch a single user document (used in dashboard header).
  Future<UserModel?> getUser(String uid) async {
    try {
      final snap = await _users.doc(uid).get();
      if (!snap.exists || snap.data() == null) return null;
      return UserModel.fromMap(snap.data()!);
    } catch (_) {
      return null;
    }
  }

  /// Real-time stream of a user document.
  Stream<UserModel?> streamUser(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserModel.fromMap(snap.data()!);
    });
  }

  // ══ TRIP OPERATIONS ══════════════════════════════════════════════

  /// Create a new trip document; returns the generated tripId.
  Future<String> createTrip({
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required String createdBy,
    String? notes,
    String? coverImageUrl,
  }) async {
    final tripId = _uuid.v4();
    final trip = TripModel(
      tripId: tripId,
      title: title,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      createdBy: createdBy,
      members: [createdBy],
      notes: notes,
      coverImageUrl: coverImageUrl,
      createdAt: DateTime.now(),
    );
    await _trips.doc(tripId).set(trip.toMap());
    return tripId;
  }

  /// Real-time stream of all trips created by a specific user.
  Stream<List<TripModel>> streamUserTrips(String uid) {
    return _trips
        .where('createdBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TripModel.fromMap(d.data())).toList());
  }

  /// Fetch a single trip (used on detail/edit screen).
  Future<TripModel?> getTrip(String tripId) async {
    try {
      final snap = await _trips.doc(tripId).get();
      if (!snap.exists || snap.data() == null) return null;
      return TripModel.fromMap(snap.data()!);
    } catch (_) {
      return null;
    }
  }

  /// Update selected fields of a trip.
  Future<void> updateTrip(String tripId, Map<String, dynamic> data) async {
    await _trips.doc(tripId).update(data);
  }

  /// Delete a trip document.
  Future<void> deleteTrip(String tripId) async {
    await _trips.doc(tripId).delete();
  }

  /// Add a member uid to a trip's members array.
  Future<void> addMember(String tripId, String uid) async {
    await _trips.doc(tripId).update({
      'members': FieldValue.arrayUnion([uid]),
    });
  }
}
