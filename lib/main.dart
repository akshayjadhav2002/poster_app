import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:posterapp/providers/auth_provider.dart';
import 'package:posterapp/ui/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ 
        ChangeNotifierProvider(
          create:(context) {
            return AuthenticationProvider();
          },
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SplashScreen(),
        ),
      ),
    );
  }
}

