import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:schoolexam_correction_ui/blocs/remarks/correction.dart';
import 'package:schoolexam_correction_ui/blocs/remarks/remarks.dart';

import 'correction_tab_view.dart';

/// A view over all currently active corrections.
class CorrectionView extends StatelessWidget {
  const CorrectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<RemarksCubit, RemarksState>(builder: (context, state) {
        if (state is! RemarksCorrectionInProgress) {
          return Container();
        }

        return _CorrectionViewTabContainer(
          /// Only rebuild when a change to the length occured.
          /// This is necessary for the underlying TabController.
          key: ValueKey<int>(state.corrections.length),
          corrections: state.corrections,
          selected: state.selectedCorrection,
        );
      });
}

class _CorrectionViewTabContainer extends StatefulWidget {
  final int selected;
  final List<Correction> corrections;

  const _CorrectionViewTabContainer(
      {Key? key, required this.corrections, required this.selected})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CorrectionViewTabContainerState();
}

class _CorrectionViewTabContainerState
    extends State<_CorrectionViewTabContainer> with TickerProviderStateMixin {
  TabController? _controller;

  @override
  void initState() {
    _controller = TabController(length: widget.corrections.length, vsync: this);
    _controller!.index = widget.selected;
    _controller!.addListener(_handleTabSelection);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          SizedBox(
            height: kToolbarHeight,
            width: double.infinity,
            child: TabBar(
                labelPadding: EdgeInsets.zero,
                isScrollable: true,
                controller: _controller!,
                tabs: widget.corrections
                    .map((e) => _CorrectionTab(
                          correction: e,
                        ))
                    .toList()),
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _controller!,
              children: widget.corrections
                  .map((e) => CorrectionTabView(
                        initial: e,
                      ))
                  .toList(),
            ),
          )
        ],
      );

  void _handleTabSelection() {
    BlocProvider.of<RemarksCubit>(context).changeTo(
        submission: widget.corrections[_controller!.index].submission);
  }
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
                    onPressed: () {
                      BlocProvider.of<RemarksCubit>(context)
                          .stop(correction.submission);
                    },
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
