// lib/models/user_model.dart

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? phone;
  final String? city;
  final String? stateRegion;
  final String? country;
  final String? postalCode;
  final String? dateOfBirth;
  final String? gender;
  final String? nationality;
  final String? passportNumber;
  final String? passportExpiry;
  final String? travelStyle;
  final String? budgetRange;
  final String? accommodationType;
  final String? dietaryPreferences;
  final String? preferredLanguage;
  final String? emergencyContactName;
  final String? emergencyContactRelation;
  final String? emergencyContactPhone;
  final String? bio;
  final bool profileComplete;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.phone,
    this.city,
    this.stateRegion,
    this.country,
    this.postalCode,
    this.dateOfBirth,
    this.gender,
    this.nationality,
    this.passportNumber,
    this.passportExpiry,
    this.travelStyle,
    this.budgetRange,
    this.accommodationType,
    this.dietaryPreferences,
    this.preferredLanguage,
    this.emergencyContactName,
    this.emergencyContactRelation,
    this.emergencyContactPhone,
    this.bio,
    this.profileComplete = false,
    required this.createdAt,
  });

  // ── Firestore serialisation ───────────────────────────────────────
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] as String?,
      phone: map['phone'] as String?,
      city: map['city'] as String?,
      stateRegion: map['stateRegion'] as String?,
      country: map['country'] as String?,
      postalCode: map['postalCode'] as String?,
      dateOfBirth: map['dateOfBirth'] as String?,
      gender: map['gender'] as String?,
      nationality: map['nationality'] as String?,
      passportNumber: map['passportNumber'] as String?,
      passportExpiry: map['passportExpiry'] as String?,
      travelStyle: map['travelStyle'] as String?,
      budgetRange: map['budgetRange'] as String?,
      accommodationType: map['accommodationType'] as String?,
      dietaryPreferences: map['dietaryPreferences'] as String?,
      preferredLanguage: map['preferredLanguage'] as String?,
      emergencyContactName: map['emergencyContactName'] as String?,
      emergencyContactRelation: map['emergencyContactRelation'] as String?,
      emergencyContactPhone: map['emergencyContactPhone'] as String?,
      bio: map['bio'] as String?,
      profileComplete: (map['profileComplete'] as bool?) ?? false,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch((map['createdAt'] as int?) ?? 0),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'phone': phone,
        'city': city,
        'stateRegion': stateRegion,
        'country': country,
        'postalCode': postalCode,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'nationality': nationality,
        'passportNumber': passportNumber,
        'passportExpiry': passportExpiry,
        'travelStyle': travelStyle,
        'budgetRange': budgetRange,
        'accommodationType': accommodationType,
        'dietaryPreferences': dietaryPreferences,
        'preferredLanguage': preferredLanguage,
        'emergencyContactName': emergencyContactName,
        'emergencyContactRelation': emergencyContactRelation,
        'emergencyContactPhone': emergencyContactPhone,
        'bio': bio,
        'profileComplete': profileComplete,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    String? phone,
    String? city,
    String? stateRegion,
    String? country,
    String? postalCode,
    String? dateOfBirth,
    String? gender,
    String? nationality,
    String? passportNumber,
    String? passportExpiry,
    String? travelStyle,
    String? budgetRange,
    String? accommodationType,
    String? dietaryPreferences,
    String? preferredLanguage,
    String? emergencyContactName,
    String? emergencyContactRelation,
    String? emergencyContactPhone,
    String? bio,
    bool? profileComplete,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      stateRegion: stateRegion ?? this.stateRegion,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      passportNumber: passportNumber ?? this.passportNumber,
      passportExpiry: passportExpiry ?? this.passportExpiry,
      travelStyle: travelStyle ?? this.travelStyle,
      budgetRange: budgetRange ?? this.budgetRange,
      accommodationType: accommodationType ?? this.accommodationType,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactRelation:
          emergencyContactRelation ?? this.emergencyContactRelation,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      bio: bio ?? this.bio,
      profileComplete: profileComplete ?? this.profileComplete,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'UserModel(uid: $uid, name: $name, email: $email)';
}
