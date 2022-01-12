import 'dart:ui';

import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/persistence/correction_overlay_page_data.dart';

class CorrectionOverlayInputData {
  /// This is the unique key for this collection of input points.
  final int? id;

  final int pageId;

  final int color;

  const CorrectionOverlayInputData(
      {this.id, required this.pageId, required this.color});

  /// Used by SQFlite to automatically generate insert, update... queries.
  Map<String, dynamic> toMap() {
    return {'pageId': pageId, 'color': color};
  }

  static CorrectionOverlayInputData fromMap(Map<String, dynamic> data) =>
      CorrectionOverlayInputData(
          id: data['id'], pageId: data['pageId'], color: data['color']);

  static CorrectionOverlayInputData fromModel(
          {required CorrectionOverlayPageData page,
          required CorrectionOverlayInput input}) =>
      CorrectionOverlayInputData(pageId: page.id!, color: input.color.value);

  CorrectionOverlayInput toModel(
          {required List<CorrectionOverlayPoint> points}) =>
      CorrectionOverlayInput(color: Color(color), points: points);

  CorrectionOverlayInputData copyWith({int? id}) => CorrectionOverlayInputData(
      id: id ?? this.id, pageId: pageId, color: color);
}
