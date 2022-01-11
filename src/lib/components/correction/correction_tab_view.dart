import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay_document.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay_page.dart';
import 'package:schoolexam_correction_ui/blocs/remark/correction.dart';
import 'package:schoolexam_correction_ui/components/correction/correction_page_view.dart';

class CorrectionTabView extends StatelessWidget {
  final Correction correction;

  const CorrectionTabView({Key? key, required this.correction})
      : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CorrectionOverlayCubit, CorrectionOverlayState>(
          builder: (context, state) {
        final document = state.overlays.firstWhere(
            (element) => element.path == correction.submissionPath,
            orElse: () => CorrectionOverlayDocument.empty);

        return Container(
          color: null,
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          child: CorrectionPageView(
              correction: correction,
              overlay: document.pages.length <= correction.pageNumber
                  ? CorrectionOverlayPage.empty
                  : document.pages[correction.pageNumber]),
        );
      });
}
