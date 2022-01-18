import 'package:equatable/equatable.dart';
import 'package:schoolexam/exams/models/person.dart';
import 'package:schoolexam/schoolexam.dart';

class AuthenticationState extends Equatable {
  final AuthenticationStatus status;
  final Person person;

  const AuthenticationState._(
      {this.status = AuthenticationStatus.unknown, this.person = Person.empty});

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(Person person)
      : this._(status: AuthenticationStatus.authenticated, person: person);

  const AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  @override
  List<Object> get props => [status, person];
}


