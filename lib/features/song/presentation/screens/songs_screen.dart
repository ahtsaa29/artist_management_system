import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/song.dart';
import '../bloc/song_bloc.dart';

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
          if (state is SongUploading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Uploading video...'),
                ],
              ),
            );
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
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final song = state.songs[i];
                return _SongTile(
                  song: song,
                  onEdit: () => _showSongForm(context, song: song),
                  onDelete: () => _confirmDelete(context, song),
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
        child: _SongForm(artistId: artistId, song: song),
      ),
    );
  }

  void _confirmDelete(BuildContext context, SongEntity song) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Song'),
        content: Text('Delete "${song.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SongBloc>().add(
                SongDeleteRequested(songId: song.id, mp4Url: song.mp4Url),
              );
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

// ─── Song Tile ────────────────────────────────────────────────────────────────

class _SongTile extends StatelessWidget {
  final SongEntity song;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SongTile({
    required this.song,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6C63FF).withOpacity(0.2),
          child: const Icon(Icons.music_note, color: Color(0xFF6C63FF)),
        ),
        title: Text(
          song.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${song.albumName} · ${song.genre}',
          style: const TextStyle(color: Colors.white54),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Video badge
            if (song.hasVideo)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'MP4',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.redAccent,
              ),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Song Form ────────────────────────────────────────────────────────────────

class _SongForm extends StatefulWidget {
  final String artistId;
  final SongEntity? song;

  const _SongForm({required this.artistId, this.song});

  @override
  State<_SongForm> createState() => _SongFormState();
}

class _SongFormState extends State<_SongForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _albumCtrl;
  String _genre = 'rnb';
  File? _pickedVideo;
  bool _removeVideo = false;

  static const _genres = [
    'rnb',
    'country',
    'classic',
    'rock',
    'jazz',
    'pop',
    'hip-hop',
    'other',
  ];

  bool get _isEditing => widget.song != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.song?.title ?? '');
    _albumCtrl = TextEditingController(text: widget.song?.albumName ?? '');
    _genre = widget.song?.genre ?? 'rnb';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _albumCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final xfile = await picker.pickVideo(source: ImageSource.gallery);
    if (xfile != null) {
      setState(() {
        _pickedVideo = File(xfile.path);
        _removeVideo = false;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context);

    if (_isEditing) {
      final updated = widget.song!.copyWith(
        title: _titleCtrl.text.trim(),
        albumName: _albumCtrl.text.trim(),
        genre: _genre,
        mp4Url: _removeVideo ? '' : null,
      );
      context.read<SongBloc>().add(
        SongUpdateRequested(song: updated, videoFile: _pickedVideo),
      );
    } else {
      context.read<SongBloc>().add(
        SongCreateRequested(
          artistId: widget.artistId,
          title: _titleCtrl.text.trim(),
          albumName: _albumCtrl.text.trim(),
          genre: _genre,
          videoFile: _pickedVideo,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    final hasExistingVideo = widget.song?.hasVideo == true && !_removeVideo;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPad),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Text(
                  _isEditing ? 'Edit Song' : 'Add Song',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.music_note_outlined),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // Album
            TextFormField(
              controller: _albumCtrl,
              decoration: const InputDecoration(
                labelText: 'Album Name',
                prefixIcon: Icon(Icons.album_outlined),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // Genre
            DropdownButtonFormField<String>(
              value: _genre,
              decoration: const InputDecoration(
                labelText: 'Genre',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _genres
                  .map(
                    (g) => DropdownMenuItem(
                      value: g,
                      child: Text(g[0].toUpperCase() + g.substring(1)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _genre = v!),
            ),
            const SizedBox(height: 16),

            // Video section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Video (optional)',
                    style: TextStyle(fontSize: 13, color: Colors.white54),
                  ),
                  const SizedBox(height: 8),

                  if (_pickedVideo != null)
                    // New video picked
                    Row(
                      children: [
                        const Icon(
                          Icons.video_file,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _pickedVideo!.path.split('/').last,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => setState(() => _pickedVideo = null),
                        ),
                      ],
                    )
                  else if (hasExistingVideo)
                    // Existing video
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Video attached',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _removeVideo = true),
                          child: const Text(
                            'Remove',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    )
                  else
                    const Text(
                      'No video attached',
                      style: TextStyle(fontSize: 13, color: Colors.white38),
                    ),

                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.video_library_outlined, size: 18),
                    label: Text(
                      _pickedVideo != null || hasExistingVideo
                          ? 'Replace Video'
                          : 'Pick MP4',
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Submit
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isEditing ? 'Save Changes' : 'Add Song',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
