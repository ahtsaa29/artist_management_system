import 'package:artist_management_system/features/artist/domain/entities/artist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArtistModel extends ArtistEntity {
  const ArtistModel({
    required super.id,
    required super.name,
    required super.gender,
    required super.address,
    super.firstReleaseYear,
    required super.noOfAlbumsReleased,
    super.dob,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ArtistModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArtistModel(
      id: doc.id,
      name: data['name'] ?? '',
      gender: data['gender'] ?? 'm',
      address: data['address'] ?? '',
      firstReleaseYear: data['first_release_year'],
      noOfAlbumsReleased: data['no_of_albums_released'] ?? 0,
      dob: data['dob'] != null ? (data['dob'] as Timestamp).toDate() : null,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  factory ArtistModel.fromEntity(ArtistEntity entity) {
    return ArtistModel(
      id: entity.id,
      name: entity.name,
      gender: entity.gender,
      address: entity.address,
      firstReleaseYear: entity.firstReleaseYear,
      noOfAlbumsReleased: entity.noOfAlbumsReleased,
      dob: entity.dob,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'gender': gender,
      'address': address,
      'first_release_year': firstReleaseYear,
      'no_of_albums_released': noOfAlbumsReleased,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }
}
