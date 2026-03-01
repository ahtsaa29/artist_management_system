import 'package:artist_management_system/core/error/failures.dart';
import 'package:artist_management_system/features/song/data/datasources/song_remote_datasource.dart';
import 'package:artist_management_system/features/song/data/models/song_model.dart';
import 'package:artist_management_system/features/song/domain/entities/song.dart';
import 'package:artist_management_system/features/song/domain/repository/song_repository.dart';
import 'package:dartz/dartz.dart';

final tNow = DateTime(2024, 1, 1);
const tArtistId = 'artist-1';
const tSongId = 'song-1';
const tVideoUrl = 'https://storage.googleapis.com/bucket/songs/song-1.mp4';

SongEntity tSong({
  String id = tSongId,
  String artistId = tArtistId,
  String title = 'Test Song',
  String albumName = 'Test Album',
  String genre = 'rock',
  String? mp4Url,
}) => SongEntity(
  id: id,
  artistId: artistId,
  title: title,
  albumName: albumName,
  genre: genre,
  mp4Url: mp4Url,
  createdAt: tNow,
  updatedAt: tNow,
);

SongEntity tSongWithVideo() => tSong(mp4Url: tVideoUrl);

SongModel tSongModel({String? mp4Url}) => SongModel(
  id: tSongId,
  artistId: tArtistId,
  title: 'Test Song',
  albumName: 'Test Album',
  genre: 'rock',
  mp4Url: mp4Url,
  createdAt: tNow,
  updatedAt: tNow,
);

SongModel tSongModelWithVideo() => tSongModel(mp4Url: tVideoUrl);

class MockSongRepository implements SongRepository {
  Stream<Either<Failure, List<SongEntity>>>? _watchStream;
  Either<Failure, void> _createResult = const Right(null);
  Either<Failure, void> _updateResult = const Right(null);
  Either<Failure, void> _deleteResult = const Right(null);

  void stubWatch(Stream<Either<Failure, List<SongEntity>>> s) =>
      _watchStream = s;
  void stubCreate(Either<Failure, void> r) => _createResult = r;
  void stubUpdate(Either<Failure, void> r) => _updateResult = r;
  void stubDelete(Either<Failure, void> r) => _deleteResult = r;

  @override
  Stream<Either<Failure, List<SongEntity>>> watchSongsForArtist(
    String artistId,
  ) => _watchStream ?? const Stream.empty();

  @override
  Future<Either<Failure, void>> createSong(SongEntity song) async =>
      _createResult;

  @override
  Future<Either<Failure, void>> updateSong(SongEntity song) async =>
      _updateResult;

  @override
  Future<Either<Failure, void>> deleteSong(String songId) async =>
      _deleteResult;
}

class MockSongRemoteDataSource implements SongRemoteDataSource {
  Stream<List<SongModel>>? _watchStream;
  Exception? _createError;
  Exception? _updateError;
  Exception? _deleteError;

  void stubWatch(Stream<List<SongModel>> s) => _watchStream = s;
  void stubCreateError(Exception e) => _createError = e;
  void stubUpdateError(Exception e) => _updateError = e;
  void stubDeleteError(Exception e) => _deleteError = e;

  @override
  Stream<List<SongModel>> watchSongsForArtist(String artistId) =>
      _watchStream ?? const Stream.empty();

  @override
  Future<void> createSong(SongModel song) async {
    if (_createError != null) throw _createError!;
  }

  @override
  Future<void> updateSong(SongModel song) async {
    if (_updateError != null) throw _updateError!;
  }

  @override
  Future<void> deleteSong(String songId) async {
    if (_deleteError != null) throw _deleteError!;
  }
}
