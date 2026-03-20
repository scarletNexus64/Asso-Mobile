import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/routes/app_pages.dart';
import 'app/core/utils/app_theme_system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialiser les données de formatage de dates pour les locales
  await initializeDateFormatting('fr_FR', null);

  runApp(
    GetMaterialApp(
      title: "Asso",
      debugShowCheckedModeBanner: false,
      theme: AppThemeSystem.getLightTheme(),
      darkTheme: AppThemeSystem.getDarkTheme(),
      themeMode: ThemeMode.system,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      // Support de la localisation française
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('fr', 'FR'),
    ),
  );
}
