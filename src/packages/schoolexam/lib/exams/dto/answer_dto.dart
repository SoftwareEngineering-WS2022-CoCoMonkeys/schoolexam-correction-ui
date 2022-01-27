import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/dto/task_dto.dart';
import 'package:schoolexam/exams/exams.dart';
import 'package:schoolexam/utils/api_helper.dart';

class AnswerDTO extends Equatable {
  final String updatedAt;
  final String status;
  final double achievedPoints;

  final TaskDTO task;
  final List<AnswerSegmentDTO> segments;

  const AnswerDTO(
      {required this.updatedAt,
      required this.status,
      required this.achievedPoints,
      required this.task,
      required this.segments});

  Map<String, dynamic> toJson() {
    return {
      'updatedAt': updatedAt,
      'status': status,
      'achievedPoints': achievedPoints,
      'task': task.toJson(),
      'segments': segments.map((e) => e.toJson()).toList(),
    };
  }

  factory AnswerDTO.fromJson(Map<String, dynamic> map) {
    return AnswerDTO(
      updatedAt: ApiHelper.getValue(map: map, keys: ['updatedAt'], value: ""),
      status: ApiHelper.getValue(map: map, keys: ["status"], value: ""),
      achievedPoints:
          ApiHelper.getValue(map: map, keys: ["achievedPoints"], value: 0.0),
      task: TaskDTO.fromJson(
          ApiHelper.getValue(map: map, keys: ["task"], value: {})),
      segments: List<Map<String, dynamic>>.from(
              ApiHelper.getValue(map: map, keys: ["segments"], value: []))
          .map((e) => AnswerSegmentDTO.fromJson(e))
          .toList(),
    );
  }

  Answer toModel() => Answer(
      task: task.toModel(),
      segments: segments.map((e) => e.toModel()).toList(),
      updatedAt: (DateTime.tryParse(updatedAt) ?? DateTime.utc(0)).toUtc(),
      achievedPoints: achievedPoints,
      status: CorrectableStatus.values.firstWhere(
          (element) => element.name.toLowerCase() == status.toLowerCase(),
          orElse: () => CorrectableStatus.unknown));

  @override
  List<Object> get props => [status, achievedPoints, task, segments];
}

class AnswerSegmentDTO extends Equatable {
  final SegmentPositionDTO start;
  final SegmentPositionDTO end;

  const AnswerSegmentDTO({required this.start, required this.end});

  Map<String, dynamic> toJson() {
    return {
      'start': start.toJson(),
      'end': end.toJson(),
    };
  }

  factory AnswerSegmentDTO.fromJson(Map<String, dynamic> map) {
    return AnswerSegmentDTO(
      start: SegmentPositionDTO.fromJson(
          ApiHelper.getValue(map: map, keys: ["start"], value: {})),
      end: SegmentPositionDTO.fromJson(
          ApiHelper.getValue(map: map, keys: ["end"], value: {})),
    );
  }

  AnswerSegment toModel() =>
      AnswerSegment(start: start.toModel(), end: end.toModel());

  @override
  List<Object?> get props => [start, end];
}

class SegmentPositionDTO extends Equatable {
  final int page;
  final double y;

  const SegmentPositionDTO({required this.page, required this.y});

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'y': y,
    };
  }

  factory SegmentPositionDTO.fromJson(Map<String, dynamic> map) {
    return SegmentPositionDTO(
      page: ApiHelper.getValue(map: map, keys: ["page"], value: 0),
      y: ApiHelper.getValue(map: map, keys: ["y"], value: 0.0),
    );
  }

  /// Converts this instance to its model [SegmentPosition] representation.
  /// Importantly, the internal model starts counting pages from 0 while the DTO starts from 1.
  SegmentPosition toModel() => SegmentPosition(page: page - 1, y: y);

  @override
  List<Object?> get props => [page, y];
}
