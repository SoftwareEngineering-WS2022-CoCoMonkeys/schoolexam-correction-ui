import 'package:equatable/equatable.dart';

import 'correction_overlay_input.dart';
import 'correction_overlay_page.dart';

class CorrectionOverlayDocument extends Equatable {
  /// The identification of the correction.
  /// This is a 1:1 mapping to the submission.
  final String submissionId;
  final String path;

  /// The amount of overlay pages is equivalent to the submission pages.
  /// This has to be ensured by the corresponding blocs.
  final List<CorrectionOverlayPage> pages;
  final int pageNumber;

  const CorrectionOverlayDocument(
      {required this.submissionId,
      required this.path,
      required this.pages,
      this.pageNumber = 0});

  @override
  List<Object?> get props => [submissionId, path, pages, pageNumber];

  CorrectionOverlayDocument addInputs(
      {required int pageNumber, required List<CorrectionOverlayInput> inputs}) {
    final updated = List<CorrectionOverlayPage>.from(pages);
    updated[pageNumber] = pages[pageNumber].addInputs(inputs: inputs);

    return copyWith(pages: updated);
  }

  CorrectionOverlayDocument updateInput(
      {required int pageNumber,
      required int index,
      required CorrectionOverlayInput input}) {
    final updated = List<CorrectionOverlayPage>.from(pages);
    updated[pageNumber] =
        pages[pageNumber].updateInput(index: index, input: input);

    return copyWith(pages: updated);
  }

  static const empty =
      CorrectionOverlayDocument(submissionId: "", path: "", pages: []);

  bool get isEmpty => this == CorrectionOverlayDocument.empty;
  bool get isNotEmpty => this != CorrectionOverlayDocument.empty;

  CorrectionOverlayDocument copyWith(
          {int? pageNumber, List<CorrectionOverlayPage>? pages}) =>
      CorrectionOverlayDocument(
          submissionId: submissionId,
          pageNumber: pageNumber ?? this.pageNumber,
          path: path,
          pages: pages ?? this.pages);
}
