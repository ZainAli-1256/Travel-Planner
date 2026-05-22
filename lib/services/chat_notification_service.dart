import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../services/local_notification_service.dart';
import '../services/chat_state_store.dart';

class ChatNotificationService {
  ChatNotificationService._();

  static final ChatNotificationService instance =
      ChatNotificationService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _tripsSub;
  final Map<String, StreamSubscription> _messageSubs = {};
  final Map<String, String> _tripTitles = {};
  DateTime? _startedAt;
  String? _currentUid;

  final ValueNotifier<String?> activeTripId = ValueNotifier<String?>(null);

  Future<void> startForUser(String uid) async {
    if (_currentUid == uid && _tripsSub != null) return;
    await stop();

    _currentUid = uid;
    _startedAt = DateTime.now();
    await LocalNotificationService.instance.initialize();

    _tripsSub = _db
        .collection('trips')
        .where('members', arrayContains: uid)
        .snapshots()
        .listen(_handleTripsUpdate);
  }

  Future<void> stop() async {
    await _tripsSub?.cancel();
    _tripsSub = null;
    for (final sub in _messageSubs.values) {
      await sub.cancel();
    }
    _messageSubs.clear();
    _tripTitles.clear();
    _currentUid = null;
    _startedAt = null;
  }

  void _handleTripsUpdate(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final tripIds = <String>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final tripId = data['tripId'] as String?;
      final title = data['title'] as String?;
      if (tripId == null) continue;
      tripIds.add(tripId);
      _tripTitles[tripId] = title ?? 'Trip Chat';
      if (!_messageSubs.containsKey(tripId)) {
        _messageSubs[tripId] = _db
            .collection('trips')
            .doc(tripId)
            .collection('messages')
            .orderBy('sentAt', descending: true)
            .limit(1)
            .snapshots()
            .listen((snap) => _handleLatestMessage(tripId, snap));
      }
    }

    final staleIds = _messageSubs.keys
        .where((id) => !tripIds.contains(id))
        .toList();
    for (final id in staleIds) {
      _messageSubs[id]?.cancel();
      _messageSubs.remove(id);
      _tripTitles.remove(id);
    }
  }

  Future<void> _handleLatestMessage(
    String tripId,
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    if (_currentUid == null || snapshot.docs.isEmpty) return;

    final data = snapshot.docs.first.data();
    final msg = ChatMessageModel.fromMap(data);
    if (msg.senderId == _currentUid) return;

    if (activeTripId.value == tripId) return;

    final startedAt = _startedAt;
    if (startedAt != null && !msg.sentAt.isAfter(startedAt)) return;

    final lastRead = await ChatStateStore.getLastRead(_currentUid!, tripId);
    if (lastRead != null && !msg.sentAt.isAfter(lastRead)) return;

    final lastNotified =
        await ChatStateStore.getLastNotified(_currentUid!, tripId);
    if (lastNotified != null && !msg.sentAt.isAfter(lastNotified)) return;

    await LocalNotificationService.instance.showChatNotification(
      tripTitle: _tripTitles[tripId] ?? 'Trip Chat',
      senderName: msg.senderName,
      message: msg.text,
      id: msg.sentAt.millisecondsSinceEpoch.remainder(100000),
    );

    await ChatStateStore.setLastNotified(_currentUid!, tripId, msg.sentAt);
  }
}
