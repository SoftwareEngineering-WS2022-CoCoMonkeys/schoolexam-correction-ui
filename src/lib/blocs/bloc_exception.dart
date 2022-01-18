abstract class BlocFailure {
  final Exception? exception;

  /// If a non empty [description] is given, the global listener is going to respect this text in the representation to the user.
  /// It is therefore best practice to include a localized string informing the user about the reason for the error.
  final String description;

  const BlocFailure({this.exception, this.description = ""});
}
