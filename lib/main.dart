import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/reagent_input_screen.dart';
import 'screens/reagent_result_screen.dart';
import 'screens/waste_qr_screen.dart';
import 'screens/verdict_screen.dart';

void main() {
  runApp(const LabGuardianApp());
}

class LabGuardianApp extends StatelessWidget {
  const LabGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hanyang Lab-Guardian',
      theme: base.copyWith(
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        chipTheme: base.chipTheme.copyWith(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      initialRoute: HomeScreen.route,
      routes: {
        HomeScreen.route: (_) => const HomeScreen(),
        ReagentInputScreen.route: (_) => const ReagentInputScreen(),
        ReagentResultScreen.route: (_) => const ReagentResultScreen(),
        WasteQrScreen.route: (_) => const WasteQrScreen(),
        VerdictScreen.route: (_) => const VerdictScreen(),
      },
    );
  }
}
