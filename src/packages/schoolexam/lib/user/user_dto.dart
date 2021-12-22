import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:schoolexam/user/user.dart';
import 'package:schoolexam/utils/api_helper.dart';

@internal
class _UserDTO extends Equatable {
  final String id;

  const _UserDTO(this.id);

  _UserDTO.fromJson(Map<String, dynamic> json)
      : id = ApiHelper.getValue(map: json, keys: ["id"], value: "");

  Map<String, dynamic> toJson() => {"id": id};

  @override
  String toString() {
    return jsonEncode(this);
  }

  @override
  List<Object?> get props => [id];

  User toModel(){
    return User(id : this.id);
  }
}
