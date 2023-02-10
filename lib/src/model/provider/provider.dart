abstract class Provider<T> {
  T provide();

  void initialize();

  Provider() {
    initialize();
  }
}
