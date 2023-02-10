import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:laundrivr/src/model/delegator/delegator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../src/dialog_utils.dart';

class PermissionsDelegator extends Delegator<BuildContext> {
  PermissionsDelegator(BuildContext context) : super(context);

  @override
  void delegate() {
    _delegatePermissionsRequest(context);
  }

  List<Permission> _getRequiredPermissions() {
    if (Platform.isIOS) {
      return <Permission>[
        Permission.bluetooth,
      ];
    } else {
      return <Permission>[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ];
    }
  }

  Future<void> _delegatePermissionsRequest(BuildContext context) async {
    final List<Permission> requiredPermissions = _getRequiredPermissions();

    bool shouldAskForPermissionsAgain = true;

    while (shouldAskForPermissionsAgain) {
      final Map<Permission, PermissionStatus> statusesOfPermissions =
          await requiredPermissions.request();

      if (statusesOfPermissions.values
          .every((PermissionStatus status) => status.isGranted)) {
        shouldAskForPermissionsAgain = false;
        continue;
      }

      if (!statusesOfPermissions.values
          .any((PermissionStatus status) => status.isPermanentlyDenied)) {
        continue;
      }

      final AlertButton result = await DialogUtils().showDialog(
          'Permissions Required',
          'Please grant all required permissions to use the app. '
              'You can do this by going to the app settings.');
      if (result == AlertButton.okButton) {
        // open app settings
        await openAppSettings();
      }
    }
  }
}
