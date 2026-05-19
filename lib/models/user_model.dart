// lib/models/user_model.dart

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
  });

  // ── Firestore serialisation ───────────────────────────────────────
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] as String?,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch((map['createdAt'] as int?) ?? 0),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'UserModel(uid: $uid, name: $name, email: $email)';
}
