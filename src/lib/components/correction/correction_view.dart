import 'dart:async';
import 'dart:collection';
import 'dart:developer' as dev;
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';
import 'package:schoolexam_correction_ui/components/correction/input/input_box.dart';
import 'package:should_rebuild/should_rebuild.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'correction_input_header.dart';

/// Given, that at least one correction is currently active, this view is used for correcting.
class CorrectionView extends StatelessWidget {
  const CorrectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<RemarkCubit, RemarkState>(builder: (context, state) {
        if (state.corrections.isEmpty) {
          return const Text("ERROR");
        }

        return Column(
          children: [
            const CorrectionInputHeader(),
            Container(
              color: null,
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7),
              child: AspectRatio(
                  aspectRatio: 1 / sqrt(2),
                  child: Stack(
                    children: [
                      BlocBuilder<RemarkCubit, RemarkState>(
                          buildWhen: (prev, curr) => false,
                          builder: (context, state) =>
                              _PDFViewBuffer(initial: state)),
                      const InputBox(),
                    ],
                  )),
            )
          ],
        );
      });
}

class _PDFViewBuffer extends StatefulWidget {
  final RemarkState initial;

  const _PDFViewBuffer({required this.initial});

  @override
  State<StatefulWidget> createState() => _PDFViewBufferState();
}

class _PDFViewBufferState extends State<_PDFViewBuffer> {
  late Widget _current;
  final Map<Key, Uint8List> _history = <Key, Uint8List>{};

  void _onChildCompletion(Key key, Widget widget) {
    setState(() {
      _current = widget;
      _history.remove(key);
    });
  }

  void _reload(UpdatedRemarks remarks) {
    dev.log("Requested (re-)building of pdf view.");
    setState(() {
      _history.putIfAbsent(UniqueKey(), () => remarks.correction);
    });
  }
  @override
  void initState() {
    _current = _PDFView(
      key: UniqueKey(),
      correction: widget
          .initial.corrections[widget.initial.selectedCorrection].correction,
      onCompletion: _onChildCompletion,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) => BlocListener<RemarkCubit, RemarkState>(
      listener: (context, state) async {
        if (state is UpdatedRemarks) {
          _reload(state);
        }
      },
      child: Stack(
        children: _history
            .map((key, value) => MapEntry(
                key,
                _PDFView(
                  key: key,
                  correction: value,
                  onCompletion: _onChildCompletion,
                )))
            .values
            .toList()
            .cast<Widget>()
          ..add(_current),
      ));
}

typedef WidgetKeyCallback = Function(Key, Widget);

class _PDFView extends StatelessWidget {
  final Uint8List correction;
  final WidgetKeyCallback? onCompletion;

  const _PDFView(
      {required Key key, required this.correction, this.onCompletion})
      : super(key: key);

  @override
  Widget build(BuildContext context) => PDFView(
      // usage of key : allows for the re-rendering, however not buffering
      pdfData: correction,
      onError: (error) {
        dev.log(error.toString());
      },
      onPageError: (page, error) {
        dev.log('$page: ${error.toString()}');
      },
      onRender: (_pages) {
        dev.log("Successfully rendered the pdf view.");

        if (onCompletion != null) {
          onCompletion!(key!, this);
        }
      },
      onViewCreated: (PDFViewController pdfViewController) {
        dev.log("Successfully created the pdf view.");
      });
}
