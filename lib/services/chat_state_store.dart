import 'package:shared_preferences/shared_preferences.dart';

class ChatStateStore {
  static String _lastReadKey(String uid, String tripId) {
    return 'chat_last_read_${uid}_$tripId';
  }

  static String _lastNotifiedKey(String uid, String tripId) {
    return 'chat_last_notified_${uid}_$tripId';
  }

  static Future<DateTime?> getLastRead(String uid, String tripId) async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_lastReadKey(uid, tripId));
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  static Future<void> setLastRead(
      String uid, String tripId, DateTime value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastReadKey(uid, tripId), value.millisecondsSinceEpoch);
  }

  static Future<DateTime?> getLastNotified(String uid, String tripId) async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_lastNotifiedKey(uid, tripId));
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  static Future<void> setLastNotified(
      String uid, String tripId, DateTime value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        _lastNotifiedKey(uid, tripId), value.millisecondsSinceEpoch);
  }
}
