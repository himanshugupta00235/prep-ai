import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user in the PrepAI application.
///
/// Stored in the `users` Firestore collection, keyed by Firebase Auth UID.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String targetCompany;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.targetCompany = '',
    required this.createdAt,
  });

  /// Creates a [UserModel] from a Firestore document snapshot.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      targetCompany: data['targetCompany'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts this model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'targetCompany': targetCompany,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Creates a copy of this model with the given fields replaced.
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? targetCompany,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      targetCompany: targetCompany ?? this.targetCompany,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
