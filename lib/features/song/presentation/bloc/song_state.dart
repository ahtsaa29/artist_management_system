part of 'song_bloc.dart';

sealed class SongState extends Equatable {
  const SongState();
  
  @override
  List<Object> get props => [];
}

final class SongInitial extends SongState {}
