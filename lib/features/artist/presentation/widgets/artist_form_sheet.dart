part of '../screens/artist_screen.dart';

class ArtistFormSheet extends StatefulWidget {
  final ArtistEntity? artist;

  const ArtistFormSheet({super.key, this.artist});

  @override
  State<ArtistFormSheet> createState() => _ArtistFormSheetState();
}

class _ArtistFormSheetState extends State<ArtistFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _albumsCtrl;
  late final TextEditingController _yearCtrl;
  late String _gender;

  bool get _isEdit => widget.artist != null;

  @override
  void initState() {
    super.initState();
    final a = widget.artist;
    _nameCtrl = TextEditingController(text: a?.name ?? '');
    _addressCtrl = TextEditingController(text: a?.address ?? '');
    _albumsCtrl = TextEditingController(
      text: a?.noOfAlbumsReleased.toString() ?? '0',
    );
    _yearCtrl = TextEditingController(
      text: a?.firstReleaseYear?.toString() ?? '',
    );
    _gender = a?.gender ?? 'm';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _albumsCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<ArtistBloc>();

    if (_isEdit) {
      bloc.add(
        ArtistUpdateRequested(
          widget.artist!.copyWith(
            name: _nameCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
            noOfAlbumsReleased: int.parse(_albumsCtrl.text),
            firstReleaseYear: int.tryParse(_yearCtrl.text),
            gender: _gender,
          ),
        ),
      );
    } else {
      bloc.add(
        ArtistCreateRequested(
          name: _nameCtrl.text.trim(),
          gender: _gender,
          address: _addressCtrl.text.trim(),
          noOfAlbumsReleased: int.parse(_albumsCtrl.text),
          firstReleaseYear: int.tryParse(_yearCtrl.text),
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isEdit ? 'Edit Artist' : 'Add Artist',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Name required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressCtrl,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _albumsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Albums'),
                    validator: (v) => (v == null || int.tryParse(v) == null)
                        ? 'Enter a number'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _yearCtrl,
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
              initialValue: _gender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: const [
                DropdownMenuItem(value: 'm', child: Text('Male')),
                DropdownMenuItem(value: 'f', child: Text('Female')),
                DropdownMenuItem(value: 'o', child: Text('Other')),
              ],
              onChanged: (v) => setState(() => _gender = v!),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: Text(_isEdit ? 'Update' : 'Create'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
