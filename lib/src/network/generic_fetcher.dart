import 'dart:async';
import 'dart:developer';

import 'package:laundrivr/src/model/repository/object_repository.dart';

abstract class GenericFetcher<T extends ObjectRepository> {
  final Duration _cooldown;

  late T _repository;

  DateTime _lastFetch = DateTime.now().subtract(const Duration(minutes: 1));

  bool _isCurrentlyFetching = false;

  final StreamController<T> _objectRepositoryStreamController =
      StreamController.broadcast();

  final bool shouldRetryInfinitely;

  GenericFetcher(this._cooldown, this._repository,
      {this.shouldRetryInfinitely = false});

  Future<T> fetch({bool force = false}) async {
    if (DateTime.now().difference(_lastFetch) < _cooldown && !force) {
      return Future.value(_repository);
    }

    if (_isCurrentlyFetching && !force) {
      return Future.value(_repository);
    }

    _lastFetch = DateTime.now();

    _isCurrentlyFetching = true;

    bool shouldRetry = true;
    while (shouldRetry) {
      try {
        _repository = await fetchFromDatabase();
        shouldRetry = false;
        log('Fetched successfully!');
      } catch (e) {
        log('Error while fetching: $e');
        if (!shouldRetryInfinitely) {
          shouldRetry = false;
        }
        await Future.delayed(_cooldown);
      }
    }

    _isCurrentlyFetching = false;

    _objectRepositoryStreamController.add(_repository);

    return Future.value(_repository);
  }

  void dispose() {
    _objectRepositoryStreamController.close();
  }

  void clear() {
    _repository = provideUnloadedRepository();
  }

  void update(T repository) {
    _repository = repository;
    _objectRepositoryStreamController.add(_repository);
  }

  Stream<T> get stream => _objectRepositoryStreamController.stream;

  Future<T> fetchFromDatabase();

  T provideUnloadedRepository();
}
