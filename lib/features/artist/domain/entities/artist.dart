import 'package:equatable/equatable.dart';

class ArtistEntity extends Equatable {
  final String id;
  final String name;
  final String gender;
  final String address;
  final int? firstReleaseYear;
  final int noOfAlbumsReleased;
  final DateTime? dob;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ArtistEntity({
    required this.id,
    required this.name,
    required this.gender,
    required this.address,
    this.firstReleaseYear,
    required this.noOfAlbumsReleased,
    this.dob,
    required this.createdAt,
    required this.updatedAt,
  });

  ArtistEntity copyWith({
    String? id,
    String? name,
    String? gender,
    String? address,
    int? firstReleaseYear,
    int? noOfAlbumsReleased,
    DateTime? dob,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ArtistEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      firstReleaseYear: firstReleaseYear ?? this.firstReleaseYear,
      noOfAlbumsReleased: noOfAlbumsReleased ?? this.noOfAlbumsReleased,
      dob: dob ?? this.dob,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, gender, address, noOfAlbumsReleased];
}
