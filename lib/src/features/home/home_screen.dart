import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:flutter_svg/svg.dart';
import 'package:laundrivr/src/features/theme/laundrivr_theme.dart';
import 'package:laundrivr/src/model/user/unloaded_user_metadata.dart';
import 'package:laundrivr/src/model/user/unloaded_user_metadata_repository.dart';
import 'package:skeletons/skeletons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../constants.dart';
import '../../model/user/user_metadata_repository.dart';
import '../../network/user_metadata_fetcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Create a subscription for the broadcast stream for the user metadata
  StreamSubscription<UserMetadataRepository>? _userMetadataSubscription;

  UserMetadataRepository _userMetadata = UnloadedUserMetadataRepository();

  @override
  void initState() {
    super.initState();

    // subscribe to the user metadata
    _userMetadataSubscription = UserMetadataFetcher().stream.listen((metadata) {
      // set the state
      setState(() {
        _userMetadata = metadata;
      });
    });

    // initialize the metadata
    _initializeMetadata();
  }

  void _initializeMetadata() async {
    // re-fetch the metadata if it's not loaded (issue #4)
    if (_userMetadata is UnloadedUserMetadata) {
      _refreshUserMetadata();
    }
  }

  Future<void> _refreshUserMetadata() async {
    // refresh the user metadata
    UserMetadataFetcher().clear();
    await UserMetadataFetcher().fetch(force: true);
  }

  @override
  void dispose() {
    // cancel the subscription
    _userMetadataSubscription?.cancel();
    super.dispose();
  }

  Future<void> _signOut() async {
    try {
      supabase.auth.signOut();
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (error) {
      context.showErrorSnackBar(message: 'Unexpected error occurred');
    }
  }

  Future<AlertButton> showDialog(String title, String message) async {
    return FlutterPlatformAlert.showAlert(
        windowTitle: title,
        text: message,
        alertStyle: AlertButtonStyle.ok,
        iconStyle: IconStyle.information,
        windowPosition: AlertWindowPosition.screenCenter);
  }

  bool _canStartALoad() {
    return _userMetadata is! UnloadedUserMetadata &&
        (_userMetadata.get().loadsAvailable > 0 ||
            _userMetadata.get().loadsAvailable == -1);
  }

  @override
  Widget build(BuildContext context) {
    final LaundrivrTheme laundrivrTheme =
        Theme.of(context).extension<LaundrivrTheme>()!;
    // get the user from supabase
    final User? user = supabase.auth.currentUser;

    // if the user is null, redirect to the sign in screen (show blank screen)
    if (user == null) {
      return const Scaffold();
    }

    String name;
    if (user.userMetadata != null && user.userMetadata!.containsKey("name")) {
      name = user.userMetadata!.entries
          .firstWhere((element) => element.key == "name")
          .value;
    } else {
      if (user.email != null) {
        name = user.email!.split("@")[0];
      } else {
        name = "Your Account";
      }
    }

    return LayoutBuilder(builder: (context, constraints) {
      return RefreshIndicator(
        onRefresh: () => _refreshUserMetadata(),
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Column(
                children: [
                  SizedBox(
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25, right: 25),
                        child: GestureDetector(
                          onTap: _signOut,
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_circle,
                                color: laundrivrTheme.primaryBrightTextColor,
                                size: 45,
                              ),
                              const SizedBox(width: 10),
                              AutoSizeText(
                                'Sign Out',
                                style: laundrivrTheme.primaryTextStyle!
                                    .copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width -
                                            200),
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 5, bottom: 5),
                                decoration: BoxDecoration(
                                  color: laundrivrTheme
                                      .bottomNavBarBackgroundColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: AutoSizeText(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  style: laundrivrTheme.primaryTextStyle!
                                      .copyWith(fontWeight: FontWeight.w900),
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 15),
                  Skeleton(
                    duration: const Duration(milliseconds: 1500),
                    isLoading: _userMetadata is UnloadedUserMetadata,
                    skeleton: SkeletonAvatar(
                      style: SkeletonAvatarStyle(
                        shape: BoxShape.rectangle,
                        width: 320,
                        height: constraints.maxHeight < 600 ? 175 : 210,
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: Container(
                      width: 320,
                      height: constraints.maxHeight < 600 ? 175 : 210,
                      // rounded
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: laundrivrTheme.tertiaryOpaqueBackgroundColor,
                        // add box shadow
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 20,
                            offset: const Offset(
                                2, 2), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: AutoSizeText(
                                _userMetadata.get().loadsAvailable == -1
                                    ? '\u{221E}'
                                    : _userMetadata
                                        .get()
                                        .loadsAvailable
                                        .toString(),
                                maxLines: 1,
                                style:
                                    laundrivrTheme.primaryTextStyle!.copyWith(
                                  fontSize:
                                      constraints.maxHeight < 600 ? 100 : 120,
                                  fontWeight: FontWeight.w800,
                                  color: laundrivrTheme.goldenTextColor,
                                ),
                              ),
                            ),
                            Text(
                              'Loads Available',
                              style: laundrivrTheme.primaryTextStyle!.copyWith(
                                fontSize: constraints.maxHeight < 600 ? 25 : 30,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  // const Spacer(),
                  const SizedBox(height: 25),
                  Container(
                    width: 320,
                    height: constraints.maxHeight < 600 ? 115 : 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: laundrivrTheme.secondaryOpaqueBackgroundColor,
                      // add box shadow
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          spreadRadius: 2,
                          blurRadius: 20,
                          offset:
                              const Offset(2, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        // check if the user data is loaded and if the user has loads available
                        if (!_canStartALoad()) {
                          showDialog('Oops!', 'You have no loads available!');
                          return;
                        }
                        Navigator.pushNamed(context, '/scan_qr');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/qr-code-scan-icon.svg',
                              width: constraints.maxHeight < 600 ? 60 : 85,
                              height: constraints.maxHeight < 600 ? 60 : 85,
                            ),
                            const SizedBox(width: 25),
                            Text(
                              'Scan',
                              style: laundrivrTheme.primaryTextStyle!.copyWith(
                                fontSize: constraints.maxHeight < 600 ? 35 : 48,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    width: 320,
                    height: constraints.maxHeight < 600 ? 115 : 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: laundrivrTheme.secondaryOpaqueBackgroundColor,
                      // add box shadow
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          spreadRadius: 2,
                          blurRadius: 20,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        // check if the user data is loaded and if the user has loads available
                        if (!_canStartALoad()) {
                          showDialog('Oops!', 'You have no loads available!');
                          return;
                        }
                        Navigator.pushNamed(context, '/number_entry');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/enter-number-icon.svg',
                              width: constraints.maxHeight < 600 ? 60 : 75,
                              height: constraints.maxHeight < 600 ? 60 : 75,
                            ),
                            const SizedBox(width: 25),
                            Text(
                              'Enter',
                              style: laundrivrTheme.primaryTextStyle!.copyWith(
                                fontSize: constraints.maxHeight < 600 ? 35 : 48,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
