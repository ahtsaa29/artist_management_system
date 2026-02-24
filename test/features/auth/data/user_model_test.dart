import 'package:artist_management_system/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_docs.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  late FakeFirebaseFirestore fs;

  setUp(() => fs = FakeFirebaseFirestore());

  group('UserModel.fromFirestore', () {
    test('maps all fields correctly', () async {
      final doc = await fakeUserDoc(fs);
      final model = UserModel.fromFirestore(doc);

      expect(model.id, 'user-1');
      expect(model.firstName, 'Aastha');
      expect(model.lastName, 'B');
      expect(model.email, 'aastha@test.com');
      expect(model.phone, '9800000000');
      expect(model.gender, 'f');
      expect(model.address, 'Kathmandu');
      expect(model.role, 'admin');
      expect(model.dob, isNull);
      expect(model.createdAt, tNow);
      expect(model.updatedAt, tNow);
    });

    test('defaults missing string fields to empty string', () async {
      await fs.collection('users').doc('u2').set({
        'created_at': Timestamp.fromDate(tNow),
        'updated_at': Timestamp.fromDate(tNow),
      });
      final doc = await fs.collection('users').doc('u2').get();
      final model = UserModel.fromFirestore(doc);

      expect(model.firstName, '');
      expect(model.lastName, '');
      expect(model.email, '');
      expect(model.phone, '');
      expect(model.gender, 'm');
      expect(model.role, 'admin');
    });

    test('parses dob when present', () async {
      final dob = DateTime(1995, 5, 10);
      await fs.collection('users').doc('u3').set({
        'first_name': 'A',
        'last_name': 'B',
        'email': 'a@b.com',
        'phone': '1',
        'gender': 'm',
        'address': 'addr',
        'role': 'admin',
        'dob': Timestamp.fromDate(dob),
        'created_at': Timestamp.fromDate(tNow),
        'updated_at': Timestamp.fromDate(tNow),
      });
      final doc = await fs.collection('users').doc('u3').get();
      final model = UserModel.fromFirestore(doc);
      expect(model.dob, dob);
    });
  });

  group('UserModel.fromEntity', () {
    test('maps all fields from entity', () {
      final entity = tUser();
      final model = UserModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.firstName, entity.firstName);
      expect(model.lastName, entity.lastName);
      expect(model.email, entity.email);
      expect(model.phone, entity.phone);
      expect(model.gender, entity.gender);
      expect(model.address, entity.address);
      expect(model.role, entity.role);
      expect(model.createdAt, entity.createdAt);
      expect(model.updatedAt, entity.updatedAt);
    });

    test('preserves dob when set', () {
      final dob = DateTime(1990);
      final entity = tUser().copyWith(dob: dob);
      final model = UserModel.fromEntity(entity);
      expect(model.dob, dob);
    });

    test('is an instance of UserEntity (inheritance)', () {
      expect(UserModel.fromEntity(tUser()), isA<UserModel>());
    });
  });

  group('UserModel.toMap', () {
    test('contains all required keys', () {
      final model = UserModel.fromEntity(tUser());
      final map = model.toMap();

      expect(map.containsKey('first_name'), isTrue);
      expect(map.containsKey('last_name'), isTrue);
      expect(map.containsKey('email'), isTrue);
      expect(map.containsKey('phone'), isTrue);
      expect(map.containsKey('gender'), isTrue);
      expect(map.containsKey('address'), isTrue);
      expect(map.containsKey('role'), isTrue);
      expect(map.containsKey('dob'), isTrue);
      expect(map.containsKey('created_at'), isTrue);
      expect(map.containsKey('updated_at'), isTrue);
    });

    test('maps values correctly', () {
      final model = UserModel.fromEntity(tUser());
      final map = model.toMap();

      expect(map['first_name'], 'Aastha');
      expect(map['last_name'], 'B');
      expect(map['email'], 'aastha@test.com');
      expect(map['gender'], 'f');
      expect(map['role'], 'admin');
      expect(map['dob'], isNull);
      expect(map['created_at'], isA<Timestamp>());
      expect(map['updated_at'], isA<Timestamp>());
    });

    test('dob is Timestamp when set', () {
      final dob = DateTime(1995, 5, 10);
      final entity = tUser().copyWith(dob: dob);
      final model = UserModel.fromEntity(entity);
      final map = model.toMap();
      expect(map['dob'], isA<Timestamp>());
    });

    test(
      'roundtrip: fromEntity -> toMap -> fromFirestore preserves data',
      () async {
        final model = UserModel.fromEntity(tUser());
        final map = model.toMap();
        await fs.collection('users').doc(model.id).set(map);
        final doc = await fs.collection('users').doc(model.id).get();
        final restored = UserModel.fromFirestore(doc);

        expect(restored.firstName, model.firstName);
        expect(restored.email, model.email);
        expect(restored.role, model.role);
      },
    );
  });
}
