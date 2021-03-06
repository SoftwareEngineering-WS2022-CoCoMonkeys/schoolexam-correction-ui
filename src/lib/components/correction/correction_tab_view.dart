import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:schoolexam_correction_ui/blocs/remarks/correction.dart';
import 'package:schoolexam_correction_ui/components/correction/correction_page_view.dart';

import 'correction_input_header.dart';
import 'correction_page_navigation.dart';

class CorrectionTabView extends StatefulWidget {
  final Correction initial;

  const CorrectionTabView({Key? key, required this.initial}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CorrectionTabViewState();
}

class _CorrectionTabViewState extends State<CorrectionTabView>
    with AutomaticKeepAliveClientMixin<CorrectionTabView> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        CorrectionInputHeader(
          initial: widget.initial,
        ),
        Expanded(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Stack(
                children: [
                  CorrectionPageView(
                    initial: widget.initial,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: CorrectionPageNavigation(
                      initial: widget.initial,
                    ),
                  ),
                ],
              )),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
