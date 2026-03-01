import 'package:artist_management_system/features/song/domain/entities/song.dart';
import 'package:artist_management_system/features/song/presentation/bloc/song_bloc.dart';
import 'package:artist_management_system/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '../widgets/song_tile.dart';
part '../widgets/song_form_sheet.dart';
part '../widgets/song_delete_dialog.dart';

class SongsScreen extends StatelessWidget {
  final String artistId;
  final String artistName;

  const SongsScreen({
    super.key,
    required this.artistId,
    required this.artistName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SongBloc>()..add(SongWatchStarted(artistId)),
      child: _SongsView(artistId: artistId, artistName: artistName),
    );
  }
}

class _SongsView extends StatelessWidget {
  final String artistId;
  final String artistName;

  const _SongsView({required this.artistId, required this.artistName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Songs',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              artistName,
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSongForm(context),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<SongBloc, SongState>(
        listener: (context, state) {
          if (state is SongError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SongLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SongError) {
            return Center(child: Text(state.message));
          }
          if (state is SongLoaded) {
            if (state.songs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.music_off,
                      size: 64,
                      color: Colors.white24,
                    ),
                    const SizedBox(height: 16),
                    const Text('No songs yet'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _showSongForm(context),
                      child: const Text('Add First Song'),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.songs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final song = state.songs[i];
                return SongTile(
                  song: song,
                  onEdit: () => _showSongForm(context, song: song),
                  onDelete: () => _showDeleteDialog(context, song),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showSongForm(BuildContext context, {SongEntity? song}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<SongBloc>(),
        child: SongFormSheet(artistId: artistId, song: song),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, SongEntity song) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<SongBloc>(),
        child: SongDeleteDialog(song: song),
      ),
    );
  }
}
