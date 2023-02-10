import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laundrivr/src/features/home/home_screen.dart';
import 'package:laundrivr/src/features/more/more_screen.dart';
import 'package:laundrivr/src/features/theme/laundrivr_theme.dart';
import 'package:laundrivr/src/update/appcast_configuration_provider.dart';
import 'package:laundrivr/src/update/upgrader_dialog_style_provider.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:upgrader/upgrader.dart';

import '../../constants.dart';
import '../../network/user_metadata_fetcher.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    MoreScreen(),
  ];

  /// The auth state subscription
  late final StreamSubscription<AuthState> _authStateSubscription;

  /// If we are currently redirecting
  bool _redirecting = false;

  /// The current selected tab
  int _selectedIndex = 0;

  /// Page controller
  final PageController _pageController = PageController();

  @override
  void initState() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (_redirecting) return;

      // clear the user metadata
      UserMetadataFetcher().clear();
      // update user metadata
      UserMetadataFetcher().fetch(force: true);

      final session = data.session;
      if (session == null) {
        _redirecting = true;
        Navigator.of(context).pushReplacementNamed('/');
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 600), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    final LaundrivrTheme laundrivrTheme =
        Theme.of(context).extension<LaundrivrTheme>()!;
    return UpgradeAlert(
      upgrader: Upgrader(
          durationUntilAlertAgain: const Duration(seconds: 0),
          showReleaseNotes: false,
          showIgnore: false,
          showLater: false,
          appcastConfig: AppcastConfigurationProvider().provide(),
          dialogStyle: UpgraderDialogStyleProvider().defaultDialogStyle),
      child: LoaderOverlay(
        child: Scaffold(
          backgroundColor: laundrivrTheme.opaqueBackgroundColor,
          body: SafeArea(
            child: SizedBox.expand(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _selectedIndex = index);
                },
                children: _pages,
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              child: BottomNavigationBar(
                backgroundColor: laundrivrTheme.secondaryOpaqueBackgroundColor,
                selectedItemColor: laundrivrTheme.selectedIconColor,
                unselectedItemColor: laundrivrTheme.unselectedIconColor,
                onTap: _onItemTapped,
                currentIndex: _selectedIndex,
                items: const [
                  BottomNavigationBarItem(
                    label: 'Home',
                    icon: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Icon(Icons.home, size: 40),
                    ),
                  ),
                  BottomNavigationBarItem(
                    label: 'More',
                    icon: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Icon(Icons.more_horiz, size: 40),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
