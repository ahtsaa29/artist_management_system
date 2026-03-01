part of '../screens/songs_screen.dart';

class SongFormSheet extends StatefulWidget {
  final String artistId;
  final SongEntity? song;

  const SongFormSheet({super.key, required this.artistId, this.song});

  @override
  State<SongFormSheet> createState() => _SongFormSheetState();
}

class _SongFormSheetState extends State<SongFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _albumCtrl;
  late String _genre;

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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context);

    final bloc = context.read<SongBloc>();

    if (_isEditing) {
      bloc.add(
        SongUpdateRequested(
          song: widget.song!.copyWith(
            title: _titleCtrl.text.trim(),
            albumName: _albumCtrl.text.trim(),
            genre: _genre,
            mp4Url: widget.song!.mp4Url,
          ),
        ),
      );
    } else {
      bloc.add(
        SongCreateRequested(
          artistId: widget.artistId,
          title: _titleCtrl.text.trim(),
          albumName: _albumCtrl.text.trim(),
          genre: _genre,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPad),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.music_note_outlined),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _albumCtrl,
              decoration: const InputDecoration(
                labelText: 'Album Name',
                prefixIcon: Icon(Icons.album_outlined),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 20),
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
