import 'package:artist_management_system/core/error/exceptions.dart';
import 'package:artist_management_system/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class UserRemoteDataSource {
  Stream<List<UserModel>> watchUsers();
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser(String userId);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;
  static const _users = 'users';

  const UserRemoteDataSourceImpl({required this.firestore});

  CollectionReference get _col => firestore.collection(_users);

  @override
  Stream<List<UserModel>> watchUsers() {
    return _col
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => UserModel.fromFirestore(d)).toList(),
        )
        .handleError((e) => throw ServerException(e.toString()));
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await _col.doc(user.id).update({
        'first_name': user.firstName,
        'last_name': user.lastName,
        'phone': user.phone,
        'gender': user.gender,
        'address': user.address,
        'dob': user.dob != null ? Timestamp.fromDate(user.dob!) : null,
        'updated_at': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update user.');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _col.doc(userId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete user.');
    }
  }
}
