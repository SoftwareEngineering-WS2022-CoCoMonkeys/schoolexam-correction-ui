import 'package:flutter/material.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;

  const ErrorStateWidget(
      {Key? key, this.message = "Leider ist ein Fehler aufgetreten"})
      : super(key: key);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SizedBox(
          height: constraints.maxHeight,
          width: constraints.maxWidth,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: constraints.maxHeight * 0.15,
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.headline3,
                ),
              )
            ],
          ),
        ),
      );
}
