import 'package:artist_management_system/features/artist/domain/entities/artist.dart';
import 'package:artist_management_system/features/auth/domain/entities/user_entity.dart';

final tNow = DateTime(2024, 1, 1);

UserEntity tUser({
  String id = 'user-1',
  String firstName = 'Aastha',
  String lastName = 'B',
  String email = 'aastha@test.com',
  String phone = '9800000000',
  String gender = 'f',
  String address = 'Kathmandu',
  String role = 'admin',
}) =>
    UserEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      gender: gender,
      address: address,
      role: role,
      createdAt: tNow,
      updatedAt: tNow,
    );

UserEntity tSuperAdmin() => tUser(id: 'super-1', role: 'superadmin');

ArtistEntity tArtist({
  String id = 'artist-1',
  String name = 'Test Artist',
  String gender = 'm',
  String address = 'Pokhara',
  int noOfAlbumsReleased = 3,
  int? firstReleaseYear = 2010,
}) =>
    ArtistEntity(
      id: id,
      name: name,
      gender: gender,
      address: address,
      noOfAlbumsReleased: noOfAlbumsReleased,
      firstReleaseYear: firstReleaseYear,
      createdAt: tNow,
      updatedAt: tNow,
    );
