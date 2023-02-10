import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laundrivr/permission/permissions_delegator.dart';
import 'package:laundrivr/skeleton_theme_provider.dart';
import 'package:laundrivr/src/ble/ble_reactive_instance.dart';
import 'package:laundrivr/src/features/root/root_screen.dart';
import 'package:laundrivr/src/features/scan_qr/scan_qr_screen.dart';
import 'package:laundrivr/src/features/sign_in/sign_in_screen.dart';
import 'package:laundrivr/src/features/splash/splash_screen.dart';
import 'package:laundrivr/src/network/user_metadata_fetcher.dart';
import 'package:laundrivr/theme_data_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'env/env.dart';
import 'src/constants.dart';
import 'src/features/number_entry/number_entry_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  if (supabase.auth.currentUser != null) {
    UserMetadataFetcher().fetch(force: true);
  }

  runApp(const LaundrivrApp());
}

class LaundrivrApp extends StatelessWidget {
  const LaundrivrApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    WidgetsFlutterBinding.ensureInitialized();

    PermissionsDelegator(context).delegate();

    BleReactiveInstance().ble.initialize();

    return SkeletonThemeProvider(
        materialApp: MaterialApp(
      title: 'Laundrivr',
      theme: ThemeDataProvider().provide(),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => const SplashScreen(),
        '/signin': (_) => const SignInScreen(),
        '/home': (_) => const RootScreen(),
        '/number_entry': (_) => const NumberEntryScreen(),
        '/scan_qr': (_) => const ScanQrScreen(),
      },
    )).provide();
  }
}
