import 'dart:ffi';

abstract class Delegator<C> {
  final C context;

  const Delegator(this.context);
  const Delegator.empty() : context = Void as C;

  void delegate();

  C get() => context;
}
