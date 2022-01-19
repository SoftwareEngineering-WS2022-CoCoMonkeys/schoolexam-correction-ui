class ApiHelper {
  static T _getConversion<T>(var data, T value) {
    if (data is T) return data;

    if (value is num && data is num) {
      if (value is double) return data.toDouble() as T;

      if (value is int) return data.toInt() as T;
    }

    return value;
  }

  static T getValue<T>(
      {required map, required List<String> keys, required T value}) {
    var tMap = map;
    for (var i = 0; i < keys.length && tMap is Map; i++) {
      if (!tMap.containsKey(keys[i]) || tMap[keys[i]] == null) return value;

      tMap = tMap[keys[i]];
    }

    return _getConversion(tMap, value);
  }

  static T getValueChain<T>(
      {required map, required List<List<String>> keyChain, required T value}) {
    var callbacks = [];
    while (keyChain.isNotEmpty) {
      var tail = keyChain.removeLast();

      if (callbacks.isEmpty) {
        callbacks.add(() => getValue<T>(map: map, keys: tail, value: value));
      } else {
        var prevKey = callbacks.last;
        callbacks
            .add(() => getValue<T>(map: map, keys: tail, value: prevKey()));
      }
    }

    return callbacks.last();
  }
}
