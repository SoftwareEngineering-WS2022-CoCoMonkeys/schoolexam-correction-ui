abstract class BlocSuccess {
  /// If a non empty [description] is given, the global listener is going to respect this text in the representation to the user.
  /// It is therefore best practice to include a localized string informing the user about the successful operation.
  final String description;

  BlocSuccess({this.description = ""});
}
