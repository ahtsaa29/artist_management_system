import 'package:artist_management_system/core/themes/app_theme.dart';
import 'package:artist_management_system/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDependencies();
  runApp(const ArtistManagementApp());
}

class ArtistManagementApp extends StatelessWidget {
  const ArtistManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(AuthCheckRequested()),
      child: MaterialApp(
        title: 'Artist Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading || state is AuthInitial) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_note_rounded,
                        size: 64,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(height: 24),
                      CircularProgressIndicator(color: AppTheme.primaryColor),
                    ],
                  ),
                ),
              );
            }
            if (state is AuthAuthenticated) {
              return DashboardScreen(user: state.user);
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
