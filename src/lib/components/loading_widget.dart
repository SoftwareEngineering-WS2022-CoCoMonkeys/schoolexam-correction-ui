import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

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
              SizedBox(
                  height: constraints.maxHeight * 0.15,
                  width: constraints.maxHeight * 0.15,
                  child: const CircularProgressIndicator()),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  "Lade Daten",
                  style: Theme.of(context).textTheme.headline3,
                ),
              )
            ],
          ),
        ),
      );
}
