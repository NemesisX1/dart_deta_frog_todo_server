import 'package:dart_deta_frog_todo_server/models/base.model.dart';
import 'package:json_annotation/json_annotation.dart';
part 'todo.model.g.dart';

///
@JsonSerializable()
class Todo extends BaseModel {
  ///
  Todo({
    this.title,
    this.description,
    this.userKey,
    this.startAt,
    this.endAt,
  }) : super();

  ///
  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  ///
  final String? title;

  ///
  final String? description;

  ///
  final String? userKey;

  ///
  final DateTime? startAt;

  ///
  final DateTime? endAt;

  @override
  Todo fromJson(Map<String, dynamic> json) {
    return _$TodoFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return _$TodoToJson(this);
  }
}
