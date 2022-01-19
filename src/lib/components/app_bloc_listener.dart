import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:schoolexam_correction_ui/blocs/bloc_exception.dart';
import 'package:schoolexam_correction_ui/blocs/bloc_loading.dart';
import 'package:schoolexam_correction_ui/blocs/bloc_success.dart';
import 'package:schoolexam_correction_ui/blocs/exam_details/exam_details.dart';
import 'package:schoolexam_correction_ui/blocs/login/login.dart';
import 'package:schoolexam_correction_ui/blocs/remarks/remarks.dart';

const String dialogPath = "/internal/dialogs";
const String loadingDialogPath = "$dialogPath/loading";
const String errorDialogPath = "$dialogPath/error";
const String successDialogPath = "$dialogPath/success";

class AppBlocListener extends StatefulWidget {
  /// Called to obtain the child widget.
  /// This function is called whenever this widget is included in its parent's build and the old widget (if any) that it synchronizes with has a distinct object identity.
  /// Typically the parent's build method will construct a new tree of widgets and so a new Builder child will not be identical to the corresponding old one.
  final WidgetBuilder builder;

  const AppBlocListener({Key? key, required this.builder}) : super(key: key);

  @override
  State<AppBlocListener> createState() => _AppBlocListenerState();
}

typedef ChildWidgetBuilder = Widget Function(
    BuildContext context, Widget child);

class _AppBlocListenerState extends State<AppBlocListener> {
  /// A pseudo-safe popping mechanism.
  void _popInternalDialog(BuildContext context, {String? path}) {
    Navigator.popUntil(context, (route) {
      return route.settings.name == null ||
          (path == null
              ? !route.settings.name!.startsWith(dialogPath)
              : route.settings.name != path);
    });
  }

  void _showLoadingDialog(
      {required BuildContext context,
      required BlocLoading loading,
      required ChildWidgetBuilder builder}) {
    if (loading.description.isEmpty) {
      return;
    }

    _popInternalDialog(context);

    showCupertinoDialog<void>(
        routeSettings: const RouteSettings(name: loadingDialogPath),
        context: context,
        builder: (BuildContext context) => _LoadingDialog(
            builder: (BuildContext context) =>
                builder(context, Text(loading.description))));
  }

  void _showSuccessDialog(
      {required BuildContext context, required BlocSuccess success}) {
    if (success.description.isEmpty) {
      return;
    }

    _popInternalDialog(context);

    showCupertinoDialog<void>(
        routeSettings: const RouteSettings(name: successDialogPath),
        context: context,
        builder: (BuildContext context) => _NotificationDialog(
            path: successDialogPath,
            title: Text(AppLocalizations.of(context)!.successTitle),
            child: Text(success.description)));
  }

  void _showErrorDialog(
      {required BuildContext context, required BlocFailure failure}) {
    _popInternalDialog(context);

    showCupertinoDialog<void>(
        routeSettings: const RouteSettings(name: errorDialogPath),
        context: context,
        // TODO : Empty description : General error message
        builder: (BuildContext context) => _NotificationDialog(
            path: errorDialogPath,
            title: Text(AppLocalizations.of(context)!.errorTitle),
            child: Text(failure.description)));
  }

  @override

  /// Prevent redundant operations through redundant listeners.
  Widget build(BuildContext context) => (!ModalRoute.of(context)!.isCurrent)
      ? widget.builder(context)
      : MultiBlocListener(listeners: [
          BlocListener<RemarksCubit, RemarksState>(listener: (context, state) {
            if (state is BlocFailure) {
              _showErrorDialog(context: context, failure: state as BlocFailure);
            } else if (state is BlocSuccess) {
              _showSuccessDialog(
                  context: context, success: state as BlocSuccess);
            } else if (state is BlocLoading) {
              _showLoadingDialog(
                  context: context,
                  loading: state as BlocLoading,
                  builder: (BuildContext context, Widget child) =>
                      BlocListener<RemarksCubit, RemarksState>(
                        listener: (context, state) {
                          if (state is! BlocLoading) {
                            // If this was not already popped, pop it now.
                            _popInternalDialog(context,
                                path: loadingDialogPath);
                          }
                        },
                        child: child,
                      ));
            }
          }),
          BlocListener<LoginBloc, LoginState>(listener: (context, state) {
            if (state is BlocFailure) {
              _showErrorDialog(context: context, failure: state as BlocFailure);
            } else if (state is BlocSuccess) {
              _showSuccessDialog(
                  context: context, success: state as BlocSuccess);
            }
          }),
          BlocListener<ExamDetailsCubit, ExamDetailsState>(
              listener: (context, state) {
            if (state is BlocFailure) {
              _showErrorDialog(context: context, failure: state as BlocFailure);
            } else if (state is BlocSuccess) {
              _showSuccessDialog(
                  context: context, success: state as BlocSuccess);
            } else if (state is BlocLoading) {
              _showLoadingDialog(
                  context: context,
                  loading: state as BlocLoading,
                  builder: (BuildContext context, Widget child) =>
                      BlocListener<ExamDetailsCubit, ExamDetailsState>(
                        listener: (context, state) {
                          if (state is! BlocLoading) {
                            // If this was not already popped, pop it now.

                            _popInternalDialog(context,
                                path: loadingDialogPath);
                          }
                        },
                        child: child,
                      ));
            }
          }),
        ], child: widget.builder(context));
}

class _LoadingDialog extends StatelessWidget {
  final WidgetBuilder builder;

  const _LoadingDialog({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) => CupertinoAlertDialog(
          content: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
          builder(context)
        ],
      ));
}

class _NotificationDialog extends StatelessWidget {
  final Widget title;
  final Widget child;
  final String path;

  const _NotificationDialog(
      {Key? key, required this.title, required this.child, required this.path})
      : super(key: key);

  @override
  Widget build(BuildContext context) => CupertinoAlertDialog(
        title: title,
        content: child,
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
              child: const Text("Ok"),
              isDefaultAction: true,
              onPressed: () => Navigator.pop(context))
        ],
      );
}
