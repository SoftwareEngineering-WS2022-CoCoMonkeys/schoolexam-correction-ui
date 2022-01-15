import 'package:equatable/equatable.dart';

import 'correction_overlay_input.dart';
import 'correction_overlay_page.dart';

class CorrectionOverlayDocument extends Equatable {
  /// The identification of the correction.
  /// This is a 1:1 mapping to the submission.
  final String submissionId;

  /// The amount of overlay pages is equivalent to the submission pages.
  /// This has to be ensured by the corresponding blocs.
  final List<CorrectionOverlayPage> pages;
  final int pageNumber;

  const CorrectionOverlayDocument(
      {required this.submissionId,
      required this.pages,
      this.pageNumber = 0,
      String? instanceId});

  @override
  List<Object?> get props => [submissionId, pages, pageNumber];

  /// Adds [inputs] to the page [pageNumber].
  CorrectionOverlayDocument addInputs(
      {required int pageNumber, required List<CorrectionOverlayInput> inputs}) {
    final updated = List<CorrectionOverlayPage>.from(pages);
    updated[pageNumber] = pages[pageNumber].addInputs(inputs: inputs);

    return copyWith(pages: updated);
  }

  /// Replaces current inputs with [inputs] provided in the page [pageNumber].
  CorrectionOverlayDocument replaceInputs(
      {required int pageNumber, required List<CorrectionOverlayInput> inputs}) {
    final updated = List<CorrectionOverlayPage>.from(pages);
    updated[pageNumber] = pages[pageNumber].replaceInputs(inputs: inputs);

    return copyWith(pages: updated);
  }

  static const empty = CorrectionOverlayDocument(submissionId: "", pages: []);

  bool get isEmpty => this == CorrectionOverlayDocument.empty;

  bool get isNotEmpty => this != CorrectionOverlayDocument.empty;

  CorrectionOverlayDocument copyWith({
    List<CorrectionOverlayPage>? pages,
    int? pageNumber,
  }) {
    return CorrectionOverlayDocument(
      submissionId: submissionId,
      pages: pages ?? this.pages,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}
