import 'package:laundrivr/src/constants.dart';
import 'package:laundrivr/src/model/repository/user/user_metadata.dart';
import 'package:laundrivr/src/model/repository/user/user_metadata_repository.dart';
import 'package:laundrivr/src/network/user_metadata_fetcher.dart';

class UserMetadataUpdater {
  static final UserMetadataUpdater _singleton = UserMetadataUpdater._internal();

  factory UserMetadataUpdater() {
    // return the singleton
    return _singleton;
  }

  UserMetadataUpdater._internal();

  bool _isUpdating = false;

  Future<void> subtractOneLoad() async {
    if (_isUpdating) {
      return;
    }

    // set the fetching state
    _isUpdating = true;

    UserMetadata metadata = (await UserMetadataFetcher().fetch()).get();
    if (metadata.loadsAvailable <= 0) {
      return;
    }

    metadata.loadsAvailable -= 1;
    UserMetadataFetcher().update(UserMetadataRepository(object: metadata));

    final user = supabase.auth.currentUser!;

    await supabase.functions.invoke("use-load", body: {
      "user_id": user.id,
    });

    _isUpdating = false;
  }
}
