abstract class Controller<T> {
  final List<void Function(T)> _listeners;

  Controller() : _listeners = <void Function(T)>[];
  Controller.withListeners(T value) : _listeners = <void Function(T)>[];

  void addListener(void Function(T) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(T) listener) {
    _listeners.remove(listener);
  }

  void notifyListeners(T value) {
    for (var listener in _listeners) {
      listener(value);
    }
  }

  void dispose() {
    _listeners.clear();
  }
}
