import 'package:artist_management_system/features/auth/data/models/user_model.dart';
import 'package:artist_management_system/features/artist/data/models/artist_model.dart';

import 'test_fixtures.dart';

UserModel tUserModel() => UserModel(
      id: 'user-1',
      firstName: 'Aastha',
      lastName: 'B',
      email: 'aastha@test.com',
      phone: '9800000000',
      gender: 'f',
      address: 'Kathmandu',
      role: 'admin',
      createdAt: tNow,
      updatedAt: tNow,
    );

UserModel tSuperAdminModel() => UserModel(
      id: 'super-1',
      firstName: 'Super',
      lastName: 'Admin',
      email: 'super@test.com',
      phone: '9800000001',
      gender: 'm',
      address: 'Kathmandu',
      role: 'superadmin',
      createdAt: tNow,
      updatedAt: tNow,
    );

ArtistModel tArtistModel() => ArtistModel(
      id: 'artist-1',
      name: 'Test Artist',
      gender: 'm',
      address: 'Pokhara',
      noOfAlbumsReleased: 3,
      firstReleaseYear: 2010,
      createdAt: tNow,
      updatedAt: tNow,
    );
