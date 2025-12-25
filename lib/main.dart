import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'pages/admin_dashboard.dart';
import 'screens/user_dashboard.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yacht App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const AuthGate(),
      routes: {
        '/user-dashboard': (_) => const UserDashboard(),
      },
    );
  }
}

/// Decides the initial screen based on authentication and user role.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Not logged in -> show login screen
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        final uid = snapshot.data!.uid;

        // Logged in -> fetch role and navigate accordingly
        return FutureBuilder<String>(
          future: AuthService().getUserRole(uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final role = roleSnapshot.data ?? 'user';

            if (role == 'admin') {
              return const AdminDashboard();
            }

            return const HomeScreen();
          },
        );
      },
    );
  }
}
