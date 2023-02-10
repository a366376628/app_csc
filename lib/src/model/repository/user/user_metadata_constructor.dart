import 'package:laundrivr/src/model/repository/user/user_metadata.dart';

import '../object_constructor.dart';

class UserMetadataConstructor
    implements ObjectConstructor<UserMetadata, Map<String, dynamic>> {
  const UserMetadataConstructor();

  @override
  UserMetadata construct(Map<String, dynamic> data) {
    return UserMetadata(
      loadsAvailable: data['loads_available'],
    );
  }
}
