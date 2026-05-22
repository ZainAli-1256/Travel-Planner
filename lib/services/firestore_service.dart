// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/trip_model.dart';
import '../models/itinerary_item_model.dart';
import '../models/chat_message_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // ── Collection references ────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _trips =>
      _db.collection('trips');

  // ══ USER OPERATIONS ══════════════════════════════════════════════

  Future<void> createUser(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final snap = await _users.doc(uid).get();
      if (!snap.exists || snap.data() == null) return null;
      return UserModel.fromMap(snap.data()!);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }

  Stream<UserModel?> streamUser(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserModel.fromMap(snap.data()!);
    });
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final snap = await _users.where('email', isEqualTo: email).limit(1).get();
      if (snap.docs.isEmpty) return null;
      return UserModel.fromMap(snap.docs.first.data());
    } catch (_) {
      return null;
    }
  }

  // ══ TRIP OPERATIONS ══════════════════════════════════════════════

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

  Stream<List<TripModel>> streamUserTrips(String uid) {
    return _trips
        .where('createdBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TripModel.fromMap(d.data())).toList());
  }

  Stream<List<TripModel>> streamMemberTrips(String uid) {
    return _trips
        .where('members', arrayContains: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TripModel.fromMap(d.data())).toList());
  }

  Future<TripModel?> getTrip(String tripId) async {
    try {
      final snap = await _trips.doc(tripId).get();
      if (!snap.exists || snap.data() == null) return null;
      return TripModel.fromMap(snap.data()!);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateTrip(String tripId, Map<String, dynamic> data) async {
    await _trips.doc(tripId).update(data);
  }

  Future<void> deleteTrip(String tripId) async {
    // Also delete sub-collections
    final batch = _db.batch();

    // Delete itinerary items
    final items = await _trips.doc(tripId).collection('itinerary').get();
    for (final doc in items.docs) {
      batch.delete(doc.reference);
    }

    // Delete chat messages
    final msgs = await _trips.doc(tripId).collection('messages').get();
    for (final doc in msgs.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(_trips.doc(tripId));
    await batch.commit();
  }

  Future<void> addMember(String tripId, String uid) async {
    await _trips.doc(tripId).update({
      'members': FieldValue.arrayUnion([uid]),
    });
  }

  Future<String> duplicateTrip({
    required TripModel sourceTrip,
    required DateTime newStartDate,
    required DateTime newEndDate,
    required String createdBy,
    String? titleOverride,
  }) async {
    final newTripId = await createTrip(
      title: titleOverride ?? '${sourceTrip.title} (Copy)',
      destination: sourceTrip.destination,
      startDate: newStartDate,
      endDate: newEndDate,
      createdBy: createdBy,
      notes: sourceTrip.notes,
      coverImageUrl: sourceTrip.coverImageUrl,
    );

    final sourceItems = await _itinerary(sourceTrip.tripId).get();
    final batch = _db.batch();
    final dateShift = newStartDate.difference(sourceTrip.startDate).inDays;

    for (final doc in sourceItems.docs) {
      final item = ItineraryItemModel.fromMap(doc.data());
      final shiftedDate = item.date.add(Duration(days: dateShift));
      final newItemId = _uuid.v4();
      final newItem = item.copyWith(
        itemId: newItemId,
        tripId: newTripId,
        date: shiftedDate,
        dayLabel: DateFormat('MMM d').format(shiftedDate),
      );
      batch.set(_itinerary(newTripId).doc(newItemId), newItem.toMap());
    }

    await batch.commit();
    return newTripId;
  }

  // ══ ITINERARY OPERATIONS ═════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> _itinerary(String tripId) =>
      _trips.doc(tripId).collection('itinerary');

  Future<String> addItineraryItem({
    required String tripId,
    required String dayLabel,
    required DateTime date,
    required String title,
    String? description,
    String? place,
    String category = 'activity',
    String? startTime,
    String? endTime,
    int sortOrder = 0,
  }) async {
    final itemId = _uuid.v4();
    final item = ItineraryItemModel(
      itemId: itemId,
      tripId: tripId,
      dayLabel: dayLabel,
      date: date,
      title: title,
      description: description,
      place: place,
      category: category,
      startTime: startTime,
      endTime: endTime,
      sortOrder: sortOrder,
      createdAt: DateTime.now(),
    );
    await _itinerary(tripId).doc(itemId).set(item.toMap());
    return itemId;
  }

  Stream<List<ItineraryItemModel>> streamItinerary(String tripId) {
    return _itinerary(tripId).orderBy('date').snapshots().map((snap) =>
        snap.docs.map((d) => ItineraryItemModel.fromMap(d.data())).toList());
  }

  Future<void> updateItineraryItem(
      String tripId, String itemId, Map<String, dynamic> data) async {
    await _itinerary(tripId).doc(itemId).update(data);
  }

  Future<void> deleteItineraryItem(String tripId, String itemId) async {
    await _itinerary(tripId).doc(itemId).delete();
  }

  // ══ CHAT OPERATIONS ══════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> _messages(String tripId) =>
      _trips.doc(tripId).collection('messages');

  Future<void> sendMessage({
    required String tripId,
    required String senderId,
    required String senderName,
    required String text,
    String? senderAvatarUrl,
  }) async {
    final messageId = _uuid.v4();
    final msg = ChatMessageModel(
      messageId: messageId,
      tripId: tripId,
      senderId: senderId,
      senderName: senderName,
      senderAvatarUrl: senderAvatarUrl,
      text: text,
      sentAt: DateTime.now(),
    );
    await _messages(tripId).doc(messageId).set(msg.toMap());
  }

  Stream<List<ChatMessageModel>> streamMessages(String tripId) {
    return _messages(tripId)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatMessageModel.fromMap(d.data())).toList());
  }
}
