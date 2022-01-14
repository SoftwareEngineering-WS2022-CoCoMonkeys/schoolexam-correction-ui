import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExamFormRow extends StatelessWidget {
  final String prefix;
  final String value;
  final VoidCallback callback;

  const ExamFormRow({required this.prefix, required this.value, required this.callback, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: InkWell(
        onTap: callback,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(prefix),
            Text(value, style: TextStyle(
              color: Colors.grey,
            ),),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}
