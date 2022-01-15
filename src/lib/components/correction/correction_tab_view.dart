import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/blocs/remark/correction.dart';
import 'package:schoolexam_correction_ui/components/correction/correction_page_view.dart';
import 'package:schoolexam_correction_ui/repositories/correction_overlay/correction_overlay.dart';

import 'correction_input_header.dart';
import 'correction_page_navigation.dart';

class CorrectionTabView extends StatefulWidget {
  final Correction initial;

  const CorrectionTabView({Key? key, required this.initial}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CorrectionTabViewState();
}

class _CorrectionTabViewState extends State<CorrectionTabView> {
  @override
  Widget build(BuildContext context) => Column(
        children: [
          CorrectionInputHeader(
            initial: widget.initial,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Column(
                children: [
                  Container(
                    color: null,
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7),
                    child: CorrectionPageView(
                      initial: widget.initial,
                    ),
                  ),
                  CorrectionPageNavigation(
                    initial: widget.initial,
                  )
                ],
              )),
        ],
      );
}
