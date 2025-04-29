import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Certifique-se de importar o Provider
import 'login_screen.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'theme_provider.dart'; // Certifique-se de importar o seu ThemeProvider

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(), // Fornece o ThemeProvider para todo o aplicativo
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Pegando o estado do tema do ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Meu App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
        brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light, // Muda o tema conforme a configuração
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
      home: const OnboardingScreen(), // Tela inicial
    );
  }
}
