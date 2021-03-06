import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schoolexam_correction_ui/components/app_bloc_listener.dart';
import 'package:schoolexam_correction_ui/components/login/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        child: AppBlocListener(builder: (context) {
          return const Material(child: LoginForm());
        }));
  }
}
