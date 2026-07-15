import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rentals_app/features/auth/presentation/auth_screen.dart';
import 'package:rentals_app/features/main/main_screen.dart' as app_screens;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF57C00);
    const strongOrange = Color(0xFFE06300);
    const softOrange = Color(0xFFFFF1DF);
    const appBlack = Color(0xFF111111);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rentals App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: strongOrange,
          onPrimary: Colors.white,
          secondary: appBlack,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: appBlack,
          error: Color(0xFFB3261E),
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: appBlack,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFFFDFBD)),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primaryOrange,
          unselectedItemColor: Color(0xFF707070),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: const WidgetStatePropertyAll(strongOrange),
            foregroundColor: const WidgetStatePropertyAll(Colors.white),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.black.withValues(alpha: 0.14);
              }
              if (states.contains(WidgetState.hovered)) {
                return Colors.black.withValues(alpha: 0.08);
              }
              return null;
            }),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            elevation: const WidgetStatePropertyAll(0),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: const WidgetStatePropertyAll(strongOrange),
            foregroundColor: const WidgetStatePropertyAll(Colors.white),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.black.withValues(alpha: 0.14);
              }
              if (states.contains(WidgetState.hovered)) {
                return Colors.black.withValues(alpha: 0.08);
              }
              return null;
            }),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: const WidgetStatePropertyAll(strongOrange),
            side: const WidgetStatePropertyAll(
              BorderSide(color: Color(0xFFFFCB91)),
            ),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return strongOrange.withValues(alpha: 0.12);
              }
              if (states.contains(WidgetState.hovered)) {
                return strongOrange.withValues(alpha: 0.06);
              }
              return null;
            }),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: const WidgetStatePropertyAll(strongOrange),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.pressed)) {
                return strongOrange.withValues(alpha: 0.12);
              }
              if (states.contains(WidgetState.hovered)) {
                return strongOrange.withValues(alpha: 0.06);
              }
              return null;
            }),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: strongOrange,
          textColor: appBlack,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFFD8B0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFFD8B0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryOrange, width: 1.4),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: appBlack,
          contentTextStyle: TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: softOrange,
          selectedColor: strongOrange,
          secondarySelectedColor: strongOrange,
          labelStyle: const TextStyle(color: appBlack),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data == null) {
            return const AuthScreen();
          }

          return const app_screens.MainScreen();
        },
      ),
    );
  }
}
