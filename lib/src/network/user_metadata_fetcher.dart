import 'dart:async';
import 'dart:developer';

import 'package:laundrivr/src/model/user/unloaded_user_metadata.dart';
import 'package:laundrivr/src/model/user/user_metadata.dart';
import 'package:laundrivr/src/model/user/user_metadata_repository.dart';
import 'package:laundrivr/src/network/generic_fetcher.dart';

import '../constants.dart';
import '../model/user/unloaded_user_metadata_repository.dart';
import '../model/user/user_metadata_constructor.dart';

class UserMetadataFetcher extends GenericFetcher<UserMetadataRepository> {
  static final UserMetadataFetcher _singleton = UserMetadataFetcher._internal();

  factory UserMetadataFetcher() {
    return _singleton;
  }

  UserMetadataFetcher._internal()
      : super(const Duration(seconds: 1), UnloadedUserMetadataRepository());

  @override
  Future<UserMetadataRepository> fetchFromDatabase() async {
    log('UserMetadataFetcher: Fetching user metadata...');
    UserMetadataRepository repository =
        UserMetadataRepository(object: UnloadedUserMetadata());

    final data = (await supabase
        .from(Constants.supabaseUserMetadataTableName)
        .select('loads_available')
        .limit(1)
        .single());

    log('UserMetadataFetcher: ${data.data}');

    // create a new metadata constructor
    UserMetadata constructed = const UserMetadataConstructor().construct(data);
    repository = UserMetadataRepository(object: constructed);

    return Future.value(repository);
  }

  @override
  UserMetadataRepository provideUnloadedRepository() {
    return UserMetadataRepository(object: UnloadedUserMetadata());
  }
}
