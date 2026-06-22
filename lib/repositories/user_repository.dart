import 'package:prep_ai/models/user_model.dart';
import 'package:prep_ai/services/firestore_service.dart';

/// Manages user profile data in Firestore.
///
/// Provides operations to fetch and update user information.
class UserRepository {
  final FirestoreService _firestoreService;

  UserRepository({
    required FirestoreService firestoreService,
  }) : _firestoreService = firestoreService;

  /// Fetches a user's profile by their UID.
  Future<UserModel?> getUser(String uid) async {
    return await _firestoreService.getUser(uid);
  }

  /// Updates the user's target company.
  Future<void> updateTargetCompany(String uid, String company) async {
    await _firestoreService.updateUser(uid, {'targetCompany': company});
  }

  /// Updates arbitrary user fields.
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestoreService.updateUser(uid, data);
  }
}
