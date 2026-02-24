import 'package:artist_management_system/features/artist/domain/entities/artist.dart';
import 'package:artist_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_fixtures.dart';

void main() {
  group('UserEntity', () {
    test('fullName returns firstName + lastName', () {
      final user = tUser(firstName: 'Aastha', lastName: 'Bhatt');
      expect(user.fullName, 'Aastha Bhatt');
    });

    test('isSuperAdmin returns true only for superadmin role', () {
      expect(tSuperAdmin().isSuperAdmin, isTrue);
      expect(tUser().isSuperAdmin, isFalse);
    });

    test('isAdmin returns true only for admin role', () {
      expect(tUser(role: 'admin').isAdmin, isTrue);
      expect(tSuperAdmin().isAdmin, isFalse);
    });

    test('copyWith overrides only specified fields', () {
      final original = tUser();
      final updated = original.copyWith(
        firstName: 'NewName',
        role: 'superadmin',
      );
      expect(updated.firstName, 'NewName');
      expect(updated.role, 'superadmin');
      expect(updated.email, original.email);
      expect(updated.id, original.id);
    });

    test('copyWith with no args returns equivalent entity', () {
      final user = tUser();
      final copy = user.copyWith();
      expect(copy, equals(user));
    });

    test('Equatable: same values are equal', () {
      expect(tUser(), equals(tUser()));
    });

    test('Equatable: different ids are not equal', () {
      expect(tUser(id: 'a'), isNot(equals(tUser(id: 'b'))));
    });

    test('Equatable: different emails are not equal', () {
      expect(
        tUser(email: 'a@test.com'),
        isNot(equals(tUser(email: 'b@test.com'))),
      );
    });

    test('props does not include createdAt/updatedAt', () {
      final u1 = UserEntity(
        id: 'x',
        firstName: 'A',
        lastName: 'B',
        email: 'e@e.com',
        phone: '1',
        gender: 'm',
        address: 'addr',
        role: 'admin',
        createdAt: DateTime(2020),
        updatedAt: DateTime(2020),
      );
      final u2 = UserEntity(
        id: 'x',
        firstName: 'A',
        lastName: 'B',
        email: 'e@e.com',
        phone: '1',
        gender: 'm',
        address: 'addr',
        role: 'admin',
        createdAt: DateTime(2099),
        updatedAt: DateTime(2099),
      );
      expect(u1, equals(u2));
    });
  });

  group('ArtistEntity', () {
    test('copyWith overrides only specified fields', () {
      final artist = tArtist();
      final updated = artist.copyWith(name: 'New Name', noOfAlbumsReleased: 10);
      expect(updated.name, 'New Name');
      expect(updated.noOfAlbumsReleased, 10);
      expect(updated.id, artist.id);
      expect(updated.gender, artist.gender);
    });

    test('copyWith with no args returns equivalent entity', () {
      final artist = tArtist();
      expect(artist.copyWith(), equals(artist));
    });

    test('Equatable: same values are equal', () {
      expect(tArtist(), equals(tArtist()));
    });

    test('Equatable: different ids are not equal', () {
      expect(tArtist(id: 'a'), isNot(equals(tArtist(id: 'b'))));
    });

    test('Equatable: different names are not equal', () {
      expect(tArtist(name: 'X'), isNot(equals(tArtist(name: 'Y'))));
    });

    test('noOfAlbumsReleased defaults work', () {
      final artist = ArtistEntity(
        id: 'a',
        name: 'n',
        gender: 'm',
        address: 'addr',
        noOfAlbumsReleased: 0,
        createdAt: tNow,
        updatedAt: tNow,
      );
      expect(artist.noOfAlbumsReleased, 0);
      expect(artist.firstReleaseYear, isNull);
      expect(artist.dob, isNull);
    });
  });
}
