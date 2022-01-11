import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay.dart';
import 'package:schoolexam_correction_ui/blocs/overlay/correction_overlay_document.dart';

class CorrectionPageNavigation extends StatelessWidget {
  final CorrectionOverlayDocument document;

  const CorrectionPageNavigation({Key? key, required this.document})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (document.pageNumber > 0)
            IconButton(
                onPressed: () =>
                    BlocProvider.of<CorrectionOverlayCubit>(context).jumpToPage(
                        document: document,
                        pageNumber: document.pageNumber - 1),
                icon: const Icon(Icons.keyboard_arrow_left)),
          Text("${document.pageNumber + 1} von ${document.pages.length}"),
          if (document.pageNumber < document.pages.length - 1)
            IconButton(
                onPressed: () =>
                    BlocProvider.of<CorrectionOverlayCubit>(context).jumpToPage(
                        document: document,
                        pageNumber: document.pageNumber + 1),
                icon: const Icon(Icons.keyboard_arrow_right)),
        ],
      );
}