import 'package:flutter/material.dart';

class ExamCardBase extends StatelessWidget {
  final WidgetBuilder builder;

  const ExamCardBase({Key? key, required this.builder}) : super(key: key);
  @override
  Widget build(BuildContext context) => SizedBox(
      height: 280,
      // TODO : Replace with elevated Container for better cupertino Support
      child: Card(
          child: AspectRatio(
        aspectRatio: 1.3,
        child: builder(context),
      )));
}
