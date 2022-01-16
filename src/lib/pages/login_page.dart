import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schoolexam_correction_ui/components/login/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(child: LoginForm());
  }
}
