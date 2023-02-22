import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

abstract class Constants {
  static const String supabasePurchasablePackagesTableName =
      "purchasable_packages";

  static const String supabaseUserMetadataTableName = "user_metadata";

  static const String email = 'help@laundrivr.com';

  static const String emailLaunchUrl = 'mailto:$email';

  static const String privacyPolicyUrl = 'https://laundrivr.com/privacy';

  static const String termsOfUseUrl = "https://laundrivr.com/terms";

  static const String websiteUrl = "https://laundrivr.com";

  static const String accountManagementUrl = "https://web.laundrivr.com/";

  static const String alertNoLoadsAvailable =
      "You have no loads available. Would you like to refill your account?";

  static const String alertStillLoadingLoads =
      "Please wait while we fetch your loads!";
}

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }
}
