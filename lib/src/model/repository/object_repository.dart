class ObjectRepository<T> {
  T object;

  ObjectRepository({required this.object});

  T get() => object;

  void set(T object) => this.object = object;
}
