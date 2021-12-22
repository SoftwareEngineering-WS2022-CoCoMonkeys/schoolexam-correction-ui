import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;

  const User({required this.id});

  @override
  List<Object?> get props => [id];
}
