import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'test_fixtures.dart';

Future<DocumentSnapshot> fakeUserDoc(FakeFirebaseFirestore fs) async {
  final now = tNow;
  final data = {
    'first_name': 'Aastha',
    'last_name': 'B',
    'email': 'aastha@test.com',
    'phone': '9800000000',
    'gender': 'f',
    'address': 'Kathmandu',
    'role': 'admin',
    'dob': null,
    'created_at': Timestamp.fromDate(now),
    'updated_at': Timestamp.fromDate(now),
  };
  await fs.collection('users').doc('user-1').set(data);
  return fs.collection('users').doc('user-1').get();
}

Future<DocumentSnapshot> fakeArtistDoc(FakeFirebaseFirestore fs) async {
  final now = tNow;
  final data = {
    'name': 'Test Artist',
    'gender': 'm',
    'address': 'Pokhara',
    'first_release_year': 2010,
    'no_of_albums_released': 3,
    'dob': null,
    'created_at': Timestamp.fromDate(now),
    'updated_at': Timestamp.fromDate(now),
  };
  await fs.collection('artists').doc('artist-1').set(data);
  return fs.collection('artists').doc('artist-1').get();
}
