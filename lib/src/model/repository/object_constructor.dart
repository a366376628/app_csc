abstract class ObjectConstructor<T, C> {
  /// Creates a new instance of [T] with the given [args].
  const ObjectConstructor();

  /// Creates a new instance of [T] with the given [args].
  T construct(C context);
}
