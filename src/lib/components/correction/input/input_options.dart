class InputOptions {
  final int size;

  const InputOptions({required this.size});

  InputOptions copyWith({
    int? size,
  }) {
    return InputOptions(
      size: size ?? this.size,
    );
  }
}
