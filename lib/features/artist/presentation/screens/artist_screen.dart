import 'package:artist_management_system/features/artist/domain/entities/artist.dart';
import 'package:artist_management_system/features/artist/presentation/bloc/artist_bloc.dart';
import 'package:artist_management_system/features/song/presentation/screens/songs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '../widgets/artist_tile.dart';
part '../widgets/artist_form_sheet.dart';
part '../widgets/artist_delete_dialog.dart';

class ArtistsScreen extends StatelessWidget {
  const ArtistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ArtistBloc, ArtistState>(
        builder: (context, state) {
          if (state is ArtistLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ArtistError) {
            return Center(child: Text(state.message));
          }
          if (state is ArtistLoaded) {
            if (state.artists.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mic_none, size: 64, color: Colors.white24),
                    const SizedBox(height: 16),
                    const Text('No artists yet'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _showArtistForm(context),
                      child: const Text('Add First Artist'),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.artists.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final artist = state.artists[i];
                return ArtistTile(
                  artist: artist,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SongsScreen(
                        artistId: artist.id,
                        artistName: artist.name,
                      ),
                    ),
                  ),
                  onEdit: () => _showArtistForm(context, artist: artist),
                  onDelete: () => _showDeleteDialog(context, artist),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showArtistForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showArtistForm(BuildContext context, {ArtistEntity? artist}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<ArtistBloc>(),
        child: ArtistFormSheet(artist: artist),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ArtistEntity artist) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ArtistBloc>(),
        child: ArtistDeleteDialog(artist: artist),
      ),
    );
  }
}
