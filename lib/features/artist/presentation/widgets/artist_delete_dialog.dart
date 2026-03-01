part of '../screens/artist_screen.dart';

class ArtistDeleteDialog extends StatelessWidget {
  final ArtistEntity artist;

  const ArtistDeleteDialog({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
    );
  }
}
