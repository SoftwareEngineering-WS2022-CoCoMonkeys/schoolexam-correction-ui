import 'package:schoolexam/user/user.dart';

class UserRepository {
  const UserRepository();

  Future<User> current() async {
    // TODO : Schoolexam backend
    // TODO : Take user from logged in account
    return User(id: "TEST");
  }
}
