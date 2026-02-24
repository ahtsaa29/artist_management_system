import 'package:artist_management_system/features/artist/data/models/artist_model.dart';
import 'package:artist_management_system/features/artist/domain/entities/artist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_docs.dart';
import '../../../helpers/test_fixtures.dart';

void main() {
  late FakeFirebaseFirestore fs;

  setUp(() => fs = FakeFirebaseFirestore());

  group('ArtistModel.fromFirestore', () {
    test('maps all fields correctly', () async {
      final doc = await fakeArtistDoc(fs);
      final model = ArtistModel.fromFirestore(doc);

      expect(model.id, 'artist-1');
      expect(model.name, 'Test Artist');
      expect(model.gender, 'm');
      expect(model.address, 'Pokhara');
      expect(model.firstReleaseYear, 2010);
      expect(model.noOfAlbumsReleased, 3);
      expect(model.dob, isNull);
      expect(model.createdAt, tNow);
      expect(model.updatedAt, tNow);
    });

    test('defaults missing fields correctly', () async {
      await fs.collection('artists').doc('a2').set({
        'created_at': Timestamp.fromDate(tNow),
        'updated_at': Timestamp.fromDate(tNow),
      });
      final doc = await fs.collection('artists').doc('a2').get();
      final model = ArtistModel.fromFirestore(doc);

      expect(model.name, '');
      expect(model.gender, 'm');
      expect(model.address, '');
      expect(model.firstReleaseYear, isNull);
      expect(model.noOfAlbumsReleased, 0);
    });

    test('parses dob when present', () async {
      final dob = DateTime(1985, 3, 15);
      await fs.collection('artists').doc('a3').set({
        'name': 'X',
        'gender': 'f',
        'address': 'addr',
        'no_of_albums_released': 1,
        'dob': Timestamp.fromDate(dob),
        'created_at': Timestamp.fromDate(tNow),
        'updated_at': Timestamp.fromDate(tNow),
      });
      final doc = await fs.collection('artists').doc('a3').get();
      final model = ArtistModel.fromFirestore(doc);
      expect(model.dob, dob);
    });
  });

  group('ArtistModel.fromEntity', () {
    test('maps all fields from entity', () {
      final entity = tArtist();
      final model = ArtistModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.name, entity.name);
      expect(model.gender, entity.gender);
      expect(model.address, entity.address);
      expect(model.firstReleaseYear, entity.firstReleaseYear);
      expect(model.noOfAlbumsReleased, entity.noOfAlbumsReleased);
      expect(model.createdAt, entity.createdAt);
      expect(model.updatedAt, entity.updatedAt);
    });

    test('is an instance of ArtistEntity (inheritance)', () {
      expect(ArtistModel.fromEntity(tArtist()), isA<ArtistEntity>());
    });
  });

  group('ArtistModel.toMap', () {
    test('contains all required keys', () {
      final model = ArtistModel.fromEntity(tArtist());
      final map = model.toMap();

      expect(map.containsKey('name'), isTrue);
      expect(map.containsKey('gender'), isTrue);
      expect(map.containsKey('address'), isTrue);
      expect(map.containsKey('first_release_year'), isTrue);
      expect(map.containsKey('no_of_albums_released'), isTrue);
      expect(map.containsKey('dob'), isTrue);
      expect(map.containsKey('created_at'), isTrue);
      expect(map.containsKey('updated_at'), isTrue);
    });

    test('maps values correctly', () {
      final model = ArtistModel.fromEntity(tArtist());
      final map = model.toMap();

      expect(map['name'], 'Test Artist');
      expect(map['gender'], 'm');
      expect(map['address'], 'Pokhara');
      expect(map['first_release_year'], 2010);
      expect(map['no_of_albums_released'], 3);
      expect(map['dob'], isNull);
      expect(map['created_at'], isA<Timestamp>());
      expect(map['updated_at'], isA<Timestamp>());
    });

    test('dob is Timestamp when set', () {
      final dob = DateTime(1990, 1, 1);
      final entity = tArtist().copyWith(dob: dob);
      final model = ArtistModel.fromEntity(entity);
      expect(model.toMap()['dob'], isA<Timestamp>());
    });

    test('firstReleaseYear is null when not set', () {
      final entity = ArtistEntity(
        id: 'a',
        name: 'n',
        gender: 'm',
        address: 'addr',
        noOfAlbumsReleased: 0,
        createdAt: tNow,
        updatedAt: tNow,
      );
      final model = ArtistModel.fromEntity(entity);
      expect(model.toMap()['first_release_year'], isNull);
    });

    test(
      'roundtrip: fromEntity -> toMap -> fromFirestore preserves data',
      () async {
        final model = ArtistModel.fromEntity(tArtist());
        await fs.collection('artists').doc(model.id).set(model.toMap());
        final doc = await fs.collection('artists').doc(model.id).get();
        final restored = ArtistModel.fromFirestore(doc);

        expect(restored.name, model.name);
        expect(restored.noOfAlbumsReleased, model.noOfAlbumsReleased);
        expect(restored.firstReleaseYear, model.firstReleaseYear);
      },
    );
  });
}
