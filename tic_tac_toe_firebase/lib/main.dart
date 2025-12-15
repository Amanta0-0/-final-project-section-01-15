import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tic_tac_toe_firebase/providers/game_provider.dart';
import 'package:tic_tac_toe_firebase/providers/auth_provider.dart';
import 'package:tic_tac_toe_firebase/screens/home_screen.dart';
import 'package:tic_tac_toe_firebase/screens/auth_screen.dart'; // add this screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyABC123",
      authDomain: "tic-tac-toe-abc123.firebaseapp.com",
      projectId: "tic-tac-toe-abc123",
      storageBucket: "tic-tac-toe-abc123.appspot.com",
      messagingSenderId: "1234567890",
      appId: "1:1234567890:web:abc123def456",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      // Consumer reads AuthProvider and chooses the initial screen
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Tic Tac Toe',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: auth.isAuthenticated
                ? const HomeScreen()
                : const AuthScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

