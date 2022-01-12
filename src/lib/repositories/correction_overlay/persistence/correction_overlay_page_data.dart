import 'dart:ui';

import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/models/correction_overlay_document.dart';

class CorrectionOverlayPageData {
  /// We introduce a separate primary key to avoid constructing a composite one including a TEXT attribute (submissionId).
  final int? id;

  /// Matches this input to a submission. This is equivalent to being matched to an overlay document,
  /// as only at most one may exist at all time for a submission.
  final String submissionId;

  /// Determines to which page within the document this page belongs.
  /// This is used for constructing ordered [CorrectionOverlayPage]s that are then mapped to a document.
  final int pageNumber;

  final double width;
  final double height;

  const CorrectionOverlayPageData(
      {required this.submissionId,
      required this.pageNumber,
      this.id,
      required this.width,
      required this.height});

  /// Used by SQFlite to automatically generate insert, update... queries.
  Map<String, dynamic> toMap() {
    return {
      'submissionId': submissionId,
      'pageNumber': pageNumber,
      'width': width,
      'height': height
    };
  }

  static CorrectionOverlayPageData fromMap(Map<String, dynamic> data) {
    final page = CorrectionOverlayPageData(
        id: data['id'],
        submissionId: data['submissionId'],
        pageNumber: data['pageNumber'],
        width: data['width'],
        height: data['height']);
    return page;
  }

  static CorrectionOverlayPageData fromModel(
          {required CorrectionOverlayDocument document,
          required int pageNumber}) =>
      CorrectionOverlayPageData(
          submissionId: document.submissionId,
          pageNumber: pageNumber,
          width: document.pages[pageNumber].pageSize.width,
          height: document.pages[pageNumber].pageSize.height);

  CorrectionOverlayPage toModel(
          {required List<CorrectionOverlayInput> inputs}) =>
      CorrectionOverlayPage(inputs: inputs, pageSize: Size(width, height));

  CorrectionOverlayPageData copyWith({int? id}) => CorrectionOverlayPageData(
      id: id ?? this.id,
      submissionId: submissionId,
      pageNumber: pageNumber,
      width: width,
      height: height);
}
