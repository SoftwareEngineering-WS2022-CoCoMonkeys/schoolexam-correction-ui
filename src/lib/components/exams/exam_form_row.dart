import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ExamFormRow extends StatelessWidget {
  final String prefix;
  final bool invalid;
  final String value;
  final Widget child;

  const ExamFormRow(
      {required this.prefix,
      required this.invalid,
      required this.value,
      required this.child,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: InkWell(
        onTap: () => showCupertinoModalBottomSheet(
            context: context,
            builder: (context) => Material(
                child: Container(
                    height: 1000,
                    child: Center(
                        child: Padding(
                            padding: EdgeInsets.all(30), child: child))))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(prefix,
                style: TextStyle(
                  color: invalid ? Colors.red : Colors.black,
                )),
            Text(
              value,
              style: TextStyle(
                color: invalid ? Colors.red : Colors.grey,
              ),
            ),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}
