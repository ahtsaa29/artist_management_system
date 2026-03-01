part of '../screens/songs_screen.dart';

class SongDeleteDialog extends StatelessWidget {
  final SongEntity song;

  const SongDeleteDialog({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
            context.read<SongBloc>().add(SongDeleteRequested(songId: song.id));
          },
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}
