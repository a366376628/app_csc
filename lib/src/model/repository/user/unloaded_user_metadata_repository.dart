import 'package:laundrivr/src/model/repository/unloaded_object_repository.dart';
import 'package:laundrivr/src/model/repository/user/unloaded_user_metadata.dart';
import 'package:laundrivr/src/model/repository/user/user_metadata_repository.dart';

class UnloadedUserMetadataRepository extends UserMetadataRepository
    with UnloadedObjectRepository {
  UnloadedUserMetadataRepository() : super(object: UnloadedUserMetadata());
}
