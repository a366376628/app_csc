import 'dart:io';

import 'package:laundrivr/src/dialog_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../constants.dart';

enum LoadStartTryResult { noneAvailable, stillLoading, available }

extension LoadStartTryResultActionExtension on LoadStartTryResult {
  void whenNoneAvailable() {
    if (this == LoadStartTryResult.noneAvailable) {
      // create actions
      yes() {
        // if ios, launch
        // if android, launch external browser
        if (Platform.isIOS || Platform.isMacOS) {
          launchUrlString(Constants.accountManagementUrl);
        } else {
          launchUrlString(Constants.accountManagementUrl,
              mode: LaunchMode.externalApplication);
        }
      }

      no() {
        // do nothing
      }

      // ask to open the refill account page with a dialog
      DialogUtils()
          .showDialogYesNo('Oops!', Constants.alertNoLoadsAvailable, yes, no);
    }
  }

  void whenStillLoading() {
    if (this == LoadStartTryResult.stillLoading) {
      // ask to open the refill account page with a dialog
      DialogUtils().showDialog('Oops!', Constants.alertStillLoadingLoads);
    }
  }

  void whenAvailable(
    void Function() whenAvailable,
  ) {
    if (this == LoadStartTryResult.available) {
      whenAvailable();
    }
  }
}
