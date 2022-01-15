import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/remark/correction.dart';
import 'package:schoolexam_correction_ui/blocs/remark/remark.dart';

import 'correction_tab_view.dart';

/// A view over all currently active corrections.
class CorrectionView extends StatefulWidget {
  final int corrections;

  const CorrectionView({Key? key, required this.corrections}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CorrectionViewState();
}

class _CorrectionViewState extends State<CorrectionView>
    with TickerProviderStateMixin {
  TabController? _controller;

  @override
  void initState() {
    _controller = TabController(length: widget.corrections, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<RemarkCubit, RemarkState>(builder: (context, state) {
        return Column(
          children: [
            SizedBox(
              height: 44,
              width: double.infinity,
              child: TabBar(
                  labelPadding: EdgeInsets.zero,
                  isScrollable: true,
                  controller: _controller!,
                  tabs: state.corrections
                      .map((e) => _CorrectionTab(
                            correction: e,
                          ))
                      .toList()),
            ),
            Expanded(
              child: TabBarView(
                controller: _controller!,
                children: state.corrections
                    .map((e) => CorrectionTabView(
                          initial: e,
                        ))
                    .toList(),
              ),
            )
          ],
        );
      });
}

class _CorrectionTab extends StatelessWidget {
  final Correction correction;

  const _CorrectionTab({Key? key, required this.correction}) : super(key: key);

  @override
  Widget build(BuildContext context) => Tab(
        iconMargin: EdgeInsets.zero,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 36,
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8))),
            child: Stack(
              children: [
                IconButton(
                    // TODO : Remove Tab
                    onPressed: () {},
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                    )),
                SizedBox(
                    width: 256,
                    child: Center(
                        child: Text(
                      correction.submission.student.displayName,
                      style: const TextStyle(color: Colors.black),
                    )))
              ],
            ),
          ),
        ),
      );
}
