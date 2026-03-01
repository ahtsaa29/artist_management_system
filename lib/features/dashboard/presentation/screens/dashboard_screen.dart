import 'package:artist_management_system/features/artist/presentation/bloc/artist_bloc.dart';
import 'package:artist_management_system/features/artist/presentation/screens/artist_screen.dart';
import 'package:artist_management_system/features/auth/domain/entities/user_entity.dart';
import 'package:artist_management_system/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:artist_management_system/features/user/presentation/bloc/user_bloc.dart';
import 'package:artist_management_system/features/user/presentation/screens/users_screen.dart';
import 'package:artist_management_system/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatefulWidget {
  final UserEntity user;
  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<UserBloc>()..add(UserWatchStarted())),
        BlocProvider(
          create: (_) => sl<ArtistBloc>()..add(ArtistWatchStarted()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Artist Management',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${widget.user.fullName} · ${widget.user.role}',
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
              tooltip: 'Logout',
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            UsersScreen(currentUserId: widget.user.id),
            const ArtistsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Users',
            ),
            NavigationDestination(
              icon: Icon(Icons.mic_none_outlined),
              selectedIcon: Icon(Icons.mic),
              label: 'Artists',
            ),
          ],
        ),
      ),
    );
  }
}
