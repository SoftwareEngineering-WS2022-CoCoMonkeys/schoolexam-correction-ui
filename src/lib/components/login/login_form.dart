import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:schoolexam_correction_ui/blocs/login/login.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status.isSubmissionFailure) {
          // TODO : Improve errors
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Authentication Failure')),
            );
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "SchoolExam",
              textScaleFactor: 2,
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Willkommen!",
                textScaleFactor: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "Bitte melden Sie sich an, um mit der Korrektur von Prüfungen zu beginnen.",
                  style: TextStyle(fontStyle: FontStyle.italic)),
            ),
            const SizedBox(
              height: 50,
            ),
            _UsernameInput(),
            const Padding(padding: EdgeInsets.all(12)),
            _PasswordInput(),
            const Padding(padding: EdgeInsets.all(12)),
            _LoginButton(),
          ],
        ),
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.username != current.username,
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextField(
            key: const Key('loginForm_usernameInput_textField'),
            onChanged: (username) =>
                context.read<LoginBloc>().add(LoginUsernameChanged(username)),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.person_outline,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
              border:
                  OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              isDense: true,
              labelText: 'Benutzername',
              errorText: state.username.invalid ? 'invalid username' : null,
            ),
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextField(
            key: const Key('loginForm_passwordInput_textField'),
            onChanged: (password) =>
                context.read<LoginBloc>().add(LoginPasswordChanged(password)),
            obscureText: true,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.lock_outline,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
              border:
                  OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              isDense: true,
              labelText: 'Passwort',
              errorText: state.password.invalid ? 'invalid password' : null,
            ),
          ),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : Container(
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: Size(400, 50)),
                  key: const Key('loginForm_continue_raisedButton'),
                  child: const Text(
                    'Login',
                    textScaleFactor: 1.5,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: state.status.isValidated
                      ? () {
                          context.read<LoginBloc>().add(const LoginSubmitted());
                        }
                      : null,
                ),
              );
      },
    );
  }
}
