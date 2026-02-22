import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'artist_event.dart';
part 'artist_state.dart';

class ArtistBloc extends Bloc<ArtistEvent, ArtistState> {
  ArtistBloc() : super(ArtistInitial()) {
    on<ArtistEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
