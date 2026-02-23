import 'package:artist_management_system/features/artist/domain/entities/artist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/artist_bloc.dart';

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
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final artist = state.artists[i];
                return _ArtistTile(
                  artist: artist,
                  onTap: () => _openSongs(context, artist),
                  onEdit: () => _showArtistForm(context, artist: artist),
                  onDelete: () => _confirmDelete(context, artist),
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

  void _openSongs(BuildContext context, ArtistEntity artist) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => BlocProvider(
    //       create: (_) =>
    //           sl<SongBloc>()..add(SongWatchStarted(artist.id)),
    //       child: SongsScreen(artist: artist),
    //     ),
    //   ),
    // );
  }

  void _showArtistForm(BuildContext context, {ArtistEntity? artist}) {
    final nameCtrl = TextEditingController(text: artist?.name);
    final addressCtrl = TextEditingController(text: artist?.address);
    final albumsCtrl = TextEditingController(
      text: artist?.noOfAlbumsReleased.toString() ?? '0',
    );
    final yearCtrl = TextEditingController(
      text: artist?.firstReleaseYear?.toString() ?? '',
    );
    String gender = artist?.gender ?? 'm';
    final formKey = GlobalKey<FormState>();
    final isEdit = artist != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => BlocProvider.value(
        value: context.read<ArtistBloc>(),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (ctx, setState) => Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEdit ? 'Edit Artist' : 'Add Artist',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Name required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: albumsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Albums',
                          ),
                          validator: (v) {
                            if (v == null || int.tryParse(v) == null) {
                              return 'Enter a number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: yearCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'First Release Year',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: const [
                      DropdownMenuItem(value: 'm', child: Text('Male')),
                      DropdownMenuItem(value: 'f', child: Text('Female')),
                      DropdownMenuItem(value: 'o', child: Text('Other')),
                    ],
                    onChanged: (v) => setState(() => gender = v!),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (isEdit) {
                            context.read<ArtistBloc>().add(
                              ArtistUpdateRequested(
                                artist.copyWith(
                                  name: nameCtrl.text.trim(),
                                  address: addressCtrl.text.trim(),
                                  noOfAlbumsReleased: int.parse(
                                    albumsCtrl.text,
                                  ),
                                  firstReleaseYear: int.tryParse(yearCtrl.text),
                                  gender: gender,
                                ),
                              ),
                            );
                          } else {
                            context.read<ArtistBloc>().add(
                              ArtistCreateRequested(
                                name: nameCtrl.text.trim(),
                                gender: gender,
                                address: addressCtrl.text.trim(),
                                noOfAlbumsReleased: int.parse(albumsCtrl.text),
                                firstReleaseYear: int.tryParse(yearCtrl.text),
                              ),
                            );
                          }
                          Navigator.pop(sheetCtx);
                        }
                      },
                      child: Text(isEdit ? 'Update' : 'Create'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ArtistEntity artist) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Artist'),
        content: Text(
          'Delete ${artist.name}? All their songs will also be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ArtistBloc>().add(ArtistDeleteRequested(artist.id));
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtistTile extends StatelessWidget {
  final ArtistEntity artist;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ArtistTile({
    required this.artist,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF4A47A3),
          child: Text(
            artist.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          artist.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${artist.noOfAlbumsReleased} albums · ${artist.address}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 20),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.redAccent,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
