import 'package:artist_management_system/core/error/exceptions.dart';
import 'package:artist_management_system/features/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String gender,
    required String address,
    DateTime? dob,
  });
  Future<UserModel> signInWithGoogle();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  static const _usersCollection = 'users';

  const AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;
      final doc = await firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get current user.');
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final doc = await firestore
          .collection(_usersCollection)
          .doc(credential.user!.uid)
          .get();
      if (!doc.exists) throw const AuthException('User record not found.');
      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Login failed.');
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String gender,
    required String address,
    DateTime? dob,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final role = await _assignRole();
      final now = DateTime.now();
      final model = UserModel(
        id: credential.user!.uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        gender: gender,
        address: address,
        role: role,
        dob: dob,
        createdAt: now,
        updatedAt: now,
      );
      await firestore
          .collection(_usersCollection)
          .doc(credential.user!.uid)
          .set(model.toMap());
      await firebaseAuth.signOut();
      return model;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Registration failed.');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;
      await signIn.initialize(
        serverClientId:
            '1028995432995-99mepubddvdpl46tk67mgkqeieogneq6.apps.googleusercontent.com',
      );

      await signIn.signOut();

      final GoogleSignInAccount googleUser = await signIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const AuthException('Failed to get authentication token');
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );
      final uid = userCredential.user!.uid;

      final doc = await firestore.collection(_usersCollection).doc(uid).get();
      if (doc.exists) return UserModel.fromFirestore(doc);

      final role = await _assignRole();
      final now = DateTime.now();
      final nameParts = (googleUser.displayName ?? '').split(' ');
      final model = UserModel(
        id: uid,
        firstName: nameParts.isNotEmpty ? nameParts.first : '',
        lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
        email: googleUser.email,
        phone: '',
        gender: 'm',
        address: '',
        role: role,
        createdAt: now,
        updatedAt: now,
      );
      await firestore.collection(_usersCollection).doc(uid).set(model.toMap());

      return model;
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Google sign-in failed.');
    } catch (e, stack) {
      throw AuthException('Google sign-in failed: ${e.toString()}\n$stack');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        GoogleSignIn.instance.signOut(),
      ]);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Logout failed.');
    }
  }

  Future<String> _assignRole() async {
    final countSnap = await firestore
        .collection(_usersCollection)
        .count()
        .get();
    return (countSnap.count ?? 0) == 0 ? 'superadmin' : 'admin';
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'email-already-in-use':
        return 'Email already registered. Please login.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
