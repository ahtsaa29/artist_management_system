import 'package:artist_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:artist_management_system/features/user/presentation/bloc/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '../widgets/user_tile.dart';
part '../widgets/user_edit_sheet.dart';
part '../widgets/user_delete_dialog.dart';

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
              return UserTile(
                user: user,
                isCurrentUser: user.id == currentUserId,
                onEdit: () => _showEditSheet(context, user),
                onDelete: () => _showDeleteDialog(context, user),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showEditSheet(BuildContext context, UserEntity user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<UserBloc>(),
        child: UserEditSheet(user: user),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, UserEntity user) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<UserBloc>(),
        child: UserDeleteDialog(user: user),
      ),
    );
  }
}
