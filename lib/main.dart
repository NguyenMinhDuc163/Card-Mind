import 'package:card_mind/core/app_bloc_observer.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/providers/provider_setup.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_service.dart';
import 'modules/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Bloc.observer = AppBlocObserver();
  await EasyLocalization.ensureInitialized();
  await ThemeService.init();
  await Hive.initFlutter();
  await LocalStorageHelper.initLocalStorageHelper();
  Locale defaultLocale = const Locale('en', 'US');

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('vi', 'VN')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      startLocale: defaultLocale,
      child: MultiProvider(
        providers: ProviderSetup.getProviders(),

        child: const App(),
      ),
    ),
  );
}
