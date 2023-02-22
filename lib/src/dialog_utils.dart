import 'package:flutter_platform_alert/flutter_platform_alert.dart';

class DialogUtils {
  static final DialogUtils _instance = DialogUtils.internal();

  DialogUtils.internal();

  factory DialogUtils() => _instance;

  Future<AlertButton> showDialog(String title, String message) async {
    return FlutterPlatformAlert.showAlert(
        windowTitle: title,
        text: message,
        alertStyle: AlertButtonStyle.ok,
        iconStyle: IconStyle.information,
        windowPosition: AlertWindowPosition.screenCenter);
  }

  Future<void> showDialogYesNo(
      String title, String message, Function yes, Function no) async {
    AlertButton response = await FlutterPlatformAlert.showAlert(
        windowTitle: title,
        text: message,
        alertStyle: AlertButtonStyle.yesNo,
        iconStyle: IconStyle.information,
        windowPosition: AlertWindowPosition.screenCenter);

    if (response == AlertButton.yesButton) {
      yes();
    } else if (response == AlertButton.noButton) {
      no();
    }
  }
}
