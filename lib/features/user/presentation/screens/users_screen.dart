import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../bloc/user_bloc.dart';

class UsersScreen extends StatelessWidget {
  final String currentUserId;
  const UsersScreen({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is UserError) {
          return Center(child: Text(state.message));
        }
        if (state is UserLoaded) {
          if (state.users.isEmpty) {
            return const Center(child: Text('No users yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.users.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final user = state.users[i];
              return _UserTile(
                user: user,
                isCurrentUser: user.id == currentUserId,
                onEdit: () => _showEditSheet(context, user),
                onDelete: () => _confirmDelete(context, user),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showEditSheet(BuildContext context, UserEntity user) {
    final firstCtrl = TextEditingController(text: user.firstName);
    final lastCtrl = TextEditingController(text: user.lastName);
    final phoneCtrl = TextEditingController(text: user.phone);
    final addressCtrl = TextEditingController(text: user.address);
    String gender = user.gender;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => BlocProvider.value(
        value: context.read<UserBloc>(),
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
                    'Edit User',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: firstCtrl,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                          ),
                          validator: (v) =>
                              v?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: lastCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                          ),
                          validator: (v) =>
                              v?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: gender,
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
                          context.read<UserBloc>().add(
                            UserUpdateRequested(
                              user.copyWith(
                                firstName: firstCtrl.text.trim(),
                                lastName: lastCtrl.text.trim(),
                                phone: phoneCtrl.text.trim(),
                                address: addressCtrl.text.trim(),
                                gender: gender,
                              ),
                            ),
                          );
                          Navigator.pop(sheetCtx);
                        }
                      },
                      child: const Text('Save'),
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

  void _confirmDelete(BuildContext context, UserEntity user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Delete ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<UserBloc>().add(UserDeleteRequested(user.id));
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

class _UserTile extends StatelessWidget {
  final UserEntity user;
  final bool isCurrentUser;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserTile({
    required this.user,
    required this.isCurrentUser,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6C63FF),
          child: Text(
            user.firstName[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${user.email} · ${user.role}${isCurrentUser ? ' (you)' : ''}',
        ),
        trailing: isCurrentUser
            ? null
            : Row(
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
                ],
              ),
      ),
    );
  }
}
