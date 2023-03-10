import 'dart:io';

import 'package:upgrader/upgrader.dart';

class UpgraderDialogStyleProvider {
  static final UpgraderDialogStyleProvider _instance =
      UpgraderDialogStyleProvider._internal();

  factory UpgraderDialogStyleProvider() {
    return _instance;
  }

  UpgraderDialogStyleProvider._internal();

  /// The default dialog style for the [Upgrader] widget (based on the platform).
  UpgradeDialogStyle get defaultDialogStyle {
    if (Platform.isIOS || Platform.isMacOS) {
      return UpgradeDialogStyle.cupertino;
    } else {
      return UpgradeDialogStyle.material;
    }
  }
}
